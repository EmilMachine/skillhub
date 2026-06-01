#!/usr/bin/env bash
# upgrade-claude.sh — Claude Code adapter for skillhub-update.
# Sourced by upgrade.sh after lib.sh. Defines run_upgrade().
# Expects: SCRIPT_DIR, DIVIDER, _compare_versions, _print_table, _count_status

# ── Diff plugins → space-separated temp file ───────────────────────────────────
# Columns: plugin_key  installed  available  STATUS  marketplace
# plugin_key is already "name@marketplace" from installed_plugins.json.
_diff_plugins() {
  local out_file="$1"
  : > "$out_file"
  jq -r '.plugins | to_entries[] | .key + " " + .value[0].version' "$INSTALLED_FILE" | \
  while IFS=' ' read -r plugin_key installed_version; do
    local plugin_name="${plugin_key%@*}"
    local marketplace="${plugin_key#*@}"

    local marketplace_path
    marketplace_path=$(jq -r --arg m "$marketplace" \
      '.[$m].installLocation // empty' "$MARKETPLACES_FILE" 2>/dev/null || true)

    if [ -z "${marketplace_path:-}" ]; then
      printf '%s %s unknown UNKNOWN %s\n' \
        "$plugin_key" "$installed_version" "$marketplace" >> "$out_file"
      continue
    fi

    local plugin_json=""
    for _c in \
      "$marketplace_path/plugins/$plugin_name/.claude-plugin/plugin.json" \
      "$marketplace_path/plugins/$plugin_name/plugin.json"; do
      [ -f "$_c" ] && { plugin_json="$_c"; break; }
    done

    if [ -z "${plugin_json:-}" ]; then
      printf '%s %s unknown UNKNOWN %s\n' \
        "$plugin_key" "$installed_version" "$marketplace" >> "$out_file"
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
      "$plugin_key" "$installed_version" "$available_version" "$STATUS" "$marketplace" >> "$out_file"
  done
}

run_upgrade() {
  # ── Locate state files ───────────────────────────────────────────────────────
  local CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  local PLUGIN_DIR="$CONFIG_DIR/plugins"
  local INSTALLED_FILE="$PLUGIN_DIR/installed_plugins.json"
  local MARKETPLACES_FILE="$PLUGIN_DIR/known_marketplaces.json"

  for _f in "$INSTALLED_FILE" "$MARKETPLACES_FILE"; do
    if [ ! -f "$_f" ]; then
      echo "❌ Missing $_f — no plugins installed yet, or CLAUDE_CONFIG_DIR is non-standard"
      exit 1
    fi
  done

  # Not declared local — trap fires after run_upgrade() returns, so TMPFILE
  # must remain visible at shell scope for the EXIT trap to clean it up.
  TMPFILE=$(mktemp /tmp/skillhub-upgrade.XXXXXX)
  trap 'rm -f "${TMPFILE:-}"' EXIT

  # ── Step 1: Initial diff ─────────────────────────────────────────────────────
  _diff_plugins "$TMPFILE"

  # ── Step 2: Refresh marketplaces (deduplicated) ──────────────────────────────
  local seen_mkts="|"
  while IFS=' ' read -r plugin_key installed available status marketplace; do
    case "$seen_mkts" in
      *"|${marketplace}|"*) ;;
      *)
        seen_mkts="${seen_mkts}${marketplace}|"
        echo "🔄 Refreshing marketplace: $marketplace"
        claude plugin marketplace update "$marketplace" 2>&1 || \
          echo "  ⚠️  Could not refresh $marketplace (continuing)"
        ;;
    esac
  done < "$TMPFILE"

  # ── Step 3: Re-diff after refresh ────────────────────────────────────────────
  _diff_plugins "$TMPFILE"

  # ── Step 4: Summary table ─────────────────────────────────────────────────────
  _print_table "$TMPFILE" "Plugin upgrade check  (Claude Code)"

  # ── Step 5: Early exit if nothing to do ──────────────────────────────────────
  local OUTDATED_COUNT
  OUTDATED_COUNT=$(_count_status "$TMPFILE" "OUTDATED")

  if [ "$OUTDATED_COUNT" -eq 0 ]; then
    echo "✅ All plugins up to date."
    exit 0
  fi

  # ── Step 6: Update stale plugins ─────────────────────────────────────────────
  echo ""
  echo "⬆️  Upgrading $OUTDATED_COUNT plugin(s)..."
  local UPGRADED=0 FAILED=0
  while IFS=' ' read -r plugin_key installed available status marketplace; do
    [ "$status" != "OUTDATED" ] && continue
    echo ""
    printf "  Updating %s  %s → %s\n" "$plugin_key" "$installed" "$available"
    if claude plugin update "$plugin_key" 2>&1; then
      echo "  ✅ Done"
      UPGRADED=$(( UPGRADED + 1 ))
    else
      echo "  ⚠️  Update failed — trying uninstall + reinstall..."
      if claude plugin uninstall "$plugin_key" 2>&1 && \
         claude plugin install  "$plugin_key" 2>&1; then
        echo "  ✅ Reinstalled"
        UPGRADED=$(( UPGRADED + 1 ))
      else
        echo "  ❌ Failed to upgrade $plugin_key"
        FAILED=$(( FAILED + 1 ))
      fi
    fi
  done < "$TMPFILE"

  # ── Step 7: Final report ──────────────────────────────────────────────────────
  echo ""
  if [ "$FAILED" -eq 0 ]; then
    echo "✅ Upgraded $UPGRADED plugin(s). Restart Claude Code to apply changes."
  else
    echo "⚠️  Upgraded $UPGRADED plugin(s), $FAILED failed. Restart Claude Code to apply changes."
  fi
}
