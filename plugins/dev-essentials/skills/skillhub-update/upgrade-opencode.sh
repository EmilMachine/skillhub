#!/usr/bin/env bash
# upgrade-opencode.sh — OpenCode adapter for skillhub-update.
# Sourced by upgrade.sh after lib.sh. Defines run_upgrade().
#
# OpenCode plugin architecture (as of 2026):
#   - Local plugins: JS/TS files in .opencode/plugins/ (project) or
#                    ~/.config/opencode/plugins/ (global) — auto-loaded, no update needed
#   - npm plugins:   listed in config.json "plugin" array; installed via Bun at startup
#                    cached at ~/.cache/opencode/node_modules/
#
# There is NO `opencode plugin update` or `opencode plugin list` command.
# `opencode plugin <module>` installs a new plugin only.
# `opencode upgrade` updates the OpenCode binary, not plugins (known bug #10441).
#
# Correct update path for npm plugins:
#   cd ~/.config/opencode && bun update
# Or for a specific package:
#   cd ~/.config/opencode && bun add <pkg>@latest

run_upgrade() {
  if ! command -v opencode >/dev/null 2>&1; then
    echo "❌ 'opencode' not found in PATH."
    exit 1
  fi

  local CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
  local PACKAGE_JSON="$CONFIG_DIR/package.json"
  local PLUGIN_DIR="$CONFIG_DIR/plugins"

  echo "🔍 Plugin upgrade check  (OpenCode)"
  echo "$DIVIDER"

  # ── Local file plugins ────────────────────────────────────────────────────────
  local local_count=0
  if [ -d "$PLUGIN_DIR" ]; then
    local_count=$(find "$PLUGIN_DIR" -maxdepth 1 \( -name "*.js" -o -name "*.ts" \) 2>/dev/null | wc -l | tr -d ' ')
  fi
  if [ "$local_count" -gt 0 ]; then
    printf "  %-32s %s local file(s)   ✅ auto-loaded\n" "local plugins" "$local_count"
  fi

  # ── npm plugins ───────────────────────────────────────────────────────────────
  if [ ! -f "$PACKAGE_JSON" ]; then
    if [ "$local_count" -eq 0 ]; then
      echo "  (no plugins installed)"
    fi
    echo "$DIVIDER"
    echo "✅ Nothing to update."
    exit 0
  fi

  # List npm plugins from package.json dependencies/devDependencies
  local npm_plugins
  npm_plugins=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) | keys[]' \
    "$PACKAGE_JSON" 2>/dev/null || true)

  if [ -z "${npm_plugins:-}" ]; then
    echo "  (no npm plugins in $PACKAGE_JSON)"
    echo "$DIVIDER"
    echo "✅ Nothing to update."
    exit 0
  fi

  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    printf "  %-32s npm package\n" "$pkg"
  done <<< "$npm_plugins"

  echo "$DIVIDER"

  # ── Update via bun ────────────────────────────────────────────────────────────
  if ! command -v bun >/dev/null 2>&1; then
    echo ""
    echo "⚠️  'bun' not found — cannot auto-update npm plugins."
    echo "    Install bun (https://bun.sh) then run:"
    echo "      cd $CONFIG_DIR && bun update"
    exit 1
  fi

  echo ""
  echo "📦 Updating npm plugins via bun..."
  if ( cd "$CONFIG_DIR" && bun update 2>&1 ); then
    echo ""
    echo "✅ npm plugins updated. Restart OpenCode to apply changes."
  else
    echo ""
    echo "❌ bun update failed."
    echo "    Try manually: cd $CONFIG_DIR && bun update"
    exit 1
  fi
}
