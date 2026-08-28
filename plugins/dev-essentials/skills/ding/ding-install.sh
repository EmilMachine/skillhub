#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCOPE="global"
ACTION="on"
THRESHOLD=0

args=("$@")
i=0
if [[ "${args[0]:-}" == "local" ]]; then
  SCOPE="local"
  i=1
fi

rest="${args[@]:$i}"
if [[ -n "$rest" ]]; then
  if [[ "$rest" == "off" ]]; then
    ACTION="off"
  elif [[ "$rest" =~ ^([0-9]+)s?$ ]]; then
    THRESHOLD="${BASH_REMATCH[1]}"
  else
    echo "❌ Error: invalid argument '$rest'. Usage: /ding [local] [off|<seconds>[s]]"
    exit 1
  fi
fi

if [[ "$SCOPE" == "local" ]]; then
  if [[ -z "${CLAUDE_PROJECT_DIR:-}" ]]; then
    echo "❌ Error: CLAUDE_PROJECT_DIR not set, cannot install local hook."
    exit 1
  fi
  TARGET_DIR="$CLAUDE_PROJECT_DIR/.claude/ding"
  SETTINGS_FILE="$CLAUDE_PROJECT_DIR/.claude/settings.local.json"
else
  TARGET_DIR="$HOME/.claude/ding"
  SETTINGS_FILE="$HOME/.claude/settings.json"
fi

mkdir -p "$TARGET_DIR"
cp "$SCRIPT_DIR/runtime/ding-hook.sh" "$TARGET_DIR/ding-hook.sh"
cp "$SCRIPT_DIR/runtime/ding.wav" "$TARGET_DIR/ding.wav"
chmod +x "$TARGET_DIR/ding-hook.sh"

if [[ "$ACTION" == "off" ]]; then
  ENABLED="false"
else
  ENABLED="true"
fi

jq -n --argjson enabled "$ENABLED" --argjson threshold "$THRESHOLD" \
  '{enabled: $enabled, threshold: $threshold}' > "$TARGET_DIR/config.json"

[[ -f "$SETTINGS_FILE" ]] || echo '{}' > "$SETTINGS_FILE"

HOOK_CMD="bash \"$TARGET_DIR/ding-hook.sh\""

already_present=$(jq --arg cmd "$HOOK_CMD" \
  '[.hooks.Stop // [] | .[].hooks[]? | select(.command == $cmd)] | length > 0' \
  "$SETTINGS_FILE" 2>/dev/null)

if [[ "$already_present" != "true" ]]; then
  tmp=$(mktemp)
  jq --arg cmd "$HOOK_CMD" \
    '.hooks = (.hooks // {}) |
     .hooks.Stop = (.hooks.Stop // []) + [{"matcher": "*", "hooks": [{"type": "command", "command": $cmd}]}]' \
    "$SETTINGS_FILE" > "$tmp" && mv "$tmp" "$SETTINGS_FILE"
fi

echo "✅ ding ($SCOPE): enabled=$ENABLED threshold=${THRESHOLD}s"
echo "   hook: $SETTINGS_FILE"
echo "   files: $TARGET_DIR"
echo "⚠️  Restart the Claude Code session for hook changes to take effect."
