#!/usr/bin/env bash
# upgrade-codex.sh — Codex adapter for skillhub-update.
# Sourced by upgrade.sh after lib.sh. Defines run_upgrade().
#
# Codex plugin CLI:
#   codex plugin marketplace upgrade [name]  — refresh marketplace cache(s)
#   codex plugin add <name>@<marketplace>    — install / reinstall from marketplace
#   codex plugin remove <name>@<marketplace> — uninstall
#   codex plugin marketplace list            — list registered marketplaces
#
# NOTE: There is no `codex plugin update` command.
# Upgrade path = marketplace upgrade + remove + re-add.
#
# Installed plugin layout (source of truth):
#   ~/.codex/plugins/cache/<marketplace>/<plugin>/<version>/

run_upgrade() {
  if ! command -v codex >/dev/null 2>&1; then
    echo "❌ 'codex' not found in PATH."
    exit 1
  fi

  local CONFIG_DIR="${CODEX_CONFIG_DIR:-$HOME/.codex}"
  local CACHE_DIR="$CONFIG_DIR/plugins/cache"

  # ── Step 1: Discover installed plugins from cache ─────────────────────────────
  if [ ! -d "$CACHE_DIR" ]; then
    echo "ℹ️  No plugin cache found at $CACHE_DIR"
    echo "    Install plugins first: codex plugin add <name>@<marketplace>"
    exit 0
  fi

  local TMPFILE
  TMPFILE=$(mktemp /tmp/skillhub-upgrade-codex.XXXXXX)
  trap 'rm -f "${TMPFILE:-}"' EXIT

  # Cache layout: $CACHE_DIR/<marketplace>/<plugin>/<version>/
  while IFS= read -r version_dir; do
    local _ver _plugin _mkt
    _ver=$(basename "$version_dir")
    _plugin=$(basename "$(dirname "$version_dir")")
    _mkt=$(basename "$(dirname "$(dirname "$version_dir")")")
    printf '%s@%s %s\n' "$_plugin" "$_mkt" "$_ver"
  done < <(find "$CACHE_DIR" -mindepth 3 -maxdepth 3 -type d 2>/dev/null) >> "$TMPFILE"

  if [ ! -s "$TMPFILE" ]; then
    echo "ℹ️  No installed plugins found in $CACHE_DIR"
    exit 0
  fi

  echo "📦 Installed plugins:"
  while IFS=' ' read -r plugin_key installed_ver; do
    printf '   %-35s %s\n' "$plugin_key" "$installed_ver"
  done < "$TMPFILE"
  echo ""

  # ── Step 2: Refresh marketplace metadata ─────────────────────────────────────
  echo "🔄 Refreshing marketplaces..."
  codex plugin marketplace upgrade 2>&1 || \
    echo "  ⚠️  Marketplace refresh failed or not supported (continuing)"
  echo ""

  # ── Step 3: Reinstall each plugin (remove + re-add) to pull latest ───────────
  echo "⬆️  Reinstalling plugins..."
  local UPGRADED=0 FAILED=0
  while IFS=' ' read -r plugin_key installed_ver; do
    local _plugin _mkt
    _plugin="${plugin_key%@*}"
    _mkt="${plugin_key#*@}"
    printf '  %-35s' "$plugin_key"

    if codex plugin remove "$plugin_key" >/dev/null 2>&1 && \
       codex plugin add "$_plugin" --marketplace "$_mkt" >/dev/null 2>&1; then
      # New version is the directory name in cache after reinstall
      local new_ver_dir new_ver
      new_ver_dir=$(find "$CACHE_DIR/$_mkt/$_plugin" -mindepth 1 -maxdepth 1 \
        -type d 2>/dev/null | sort -V | tail -1)
      new_ver=$(basename "${new_ver_dir:-unknown}")
      if [ "$new_ver" = "$installed_ver" ]; then
        echo "✅ already latest ($new_ver)"
      else
        echo "✅ $installed_ver → $new_ver"
      fi
      UPGRADED=$(( UPGRADED + 1 ))
    else
      echo "❌ failed"
      FAILED=$(( FAILED + 1 ))
    fi
  done < "$TMPFILE"

  echo ""
  if [ "$FAILED" -eq 0 ]; then
    echo "✅ Updated $UPGRADED plugin(s). Restart Codex to apply changes."
  else
    echo "⚠️  Updated $UPGRADED, $FAILED failed."
    echo "    Manual: codex plugin remove <name>@<marketplace> && codex plugin add <name>@<marketplace>"
  fi
}
