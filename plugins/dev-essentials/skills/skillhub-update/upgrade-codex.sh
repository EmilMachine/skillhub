#!/usr/bin/env bash
# upgrade-codex.sh — Codex adapter for skillhub-update.
# Sourced by upgrade.sh after lib.sh. Defines run_upgrade().
#
# Codex plugin CLI (v0.121.0+):
#   codex plugin marketplace upgrade [name]  — refresh marketplace cache(s)
#   codex plugin add <name>                  — install from marketplace
#   codex plugin list                        — list installed plugins
#   codex plugin remove <name>               — uninstall
#   /plugins                                 — interactive TUI for browsing/toggling
#
# NOTE: There is no `codex plugin update` command.
# Upgrade path = remove + re-add (or use the /plugins TUI).
#
# State files mirror Claude Code structure under ~/.codex/plugins/:
#   installed_plugins.json
#   known_marketplaces.json

run_upgrade() {
  if ! command -v codex >/dev/null 2>&1; then
    echo "❌ 'codex' not found in PATH."
    exit 1
  fi

  local CONFIG_DIR="${CODEX_CONFIG_DIR:-$HOME/.codex}"
  local PLUGIN_DIR="$CONFIG_DIR/plugins"
  local INSTALLED_FILE="$PLUGIN_DIR/installed_plugins.json"
  local MARKETPLACES_FILE="$PLUGIN_DIR/known_marketplaces.json"

  # ── Step 1: Refresh all marketplaces ──────────────────────────────────────────
  echo "🔄 Refreshing all marketplaces..."
  codex plugin marketplace upgrade 2>&1 || \
    echo "  ⚠️  Marketplace refresh failed or not supported (continuing)"

  # ── Step 2: Diff if state files exist (mirrors Claude structure) ──────────────
  if [ ! -f "$INSTALLED_FILE" ] || [ ! -f "$MARKETPLACES_FILE" ]; then
    echo ""
    echo "ℹ️  State files not found at $PLUGIN_DIR"
    echo "    Cannot determine outdated plugins automatically."
    echo "    Use the interactive /plugins TUI inside Codex to update plugins."
    exit 0
  fi

  TMPFILE=$(mktemp /tmp/skillhub-upgrade-codex.XXXXXX)
  trap 'rm -f "${TMPFILE:-}"' EXIT

  # Diff using same logic as Claude adapter (state file schema is identical)
  : > "$TMPFILE"
  jq -r '.plugins | to_entries[] | .key + " " + .value[0].version' "$INSTALLED_FILE" | \
  while IFS=' ' read -r plugin_key installed_version; do
    local plugin_name="${plugin_key%@*}"
    local marketplace="${plugin_key#*@}"

    local marketplace_path
    marketplace_path=$(jq -r --arg m "$marketplace" \
      '.[$m].installLocation // empty' "$MARKETPLACES_FILE" 2>/dev/null || true)

    if [ -z "${marketplace_path:-}" ]; then
      printf '%s %s unknown UNKNOWN %s\n' \
        "$plugin_key" "$installed_version" "$marketplace" >> "$TMPFILE"
      continue
    fi

    local plugin_json=""
    for _c in \
      "$marketplace_path/plugins/$plugin_name/.codex-plugin/plugin.json" \
      "$marketplace_path/plugins/$plugin_name/.claude-plugin/plugin.json" \
      "$marketplace_path/plugins/$plugin_name/plugin.json"; do
      [ -f "$_c" ] && { plugin_json="$_c"; break; }
    done

    if [ -z "${plugin_json:-}" ]; then
      printf '%s %s unknown UNKNOWN %s\n' \
        "$plugin_key" "$installed_version" "$marketplace" >> "$TMPFILE"
      continue
    fi

    local available_version
    available_version=$(jq -r '.version // "unknown"' "$plugin_json")

    local STATUS
    if [ "$available_version" = "unknown" ]; then
      STATUS="UNKNOWN"
    else
      local cmp
      cmp=$(_compare_versions "$installed_version" "$available_version")
      case "$cmp" in
        lt) STATUS="OUTDATED" ;;
        eq) STATUS="UP_TO_DATE" ;;
        gt) STATUS="AHEAD" ;;
      esac
    fi

    printf '%s %s %s %s %s\n' \
      "$plugin_key" "$installed_version" "$available_version" "$STATUS" "$marketplace" >> "$TMPFILE"
  done

  # ── Step 3: Summary table ─────────────────────────────────────────────────────
  _print_table "$TMPFILE" "Plugin upgrade check  (Codex)"

  local OUTDATED_COUNT
  OUTDATED_COUNT=$(_count_status "$TMPFILE" "OUTDATED")

  if [ "$OUTDATED_COUNT" -eq 0 ]; then
    echo "✅ All plugins up to date."
    exit 0
  fi

  # ── Step 4: Upgrade via remove + re-add (no `codex plugin update` command) ────
  echo ""
  echo "⬆️  Upgrading $OUTDATED_COUNT plugin(s) (remove → re-add)..."
  local UPGRADED=0 FAILED=0
  while IFS=' ' read -r plugin_key installed available status marketplace; do
    [ "$status" != "OUTDATED" ] && continue
    echo ""
    printf "  Updating %s  %s → %s\n" "$plugin_key" "$installed" "$available"
    if codex plugin remove "$plugin_key" 2>&1 && \
       codex plugin add   "$plugin_key" 2>&1; then
      echo "  ✅ Done"
      UPGRADED=$(( UPGRADED + 1 ))
    else
      echo "  ❌ Failed — try manually: /plugins TUI inside Codex"
      FAILED=$(( FAILED + 1 ))
    fi
  done < "$TMPFILE"

  echo ""
  if [ "$FAILED" -eq 0 ]; then
    echo "✅ Upgraded $UPGRADED plugin(s). Restart Codex to apply changes."
  else
    echo "⚠️  Upgraded $UPGRADED plugin(s), $FAILED failed."
    echo "    Use the interactive /plugins TUI inside Codex for manual updates."
  fi
}
