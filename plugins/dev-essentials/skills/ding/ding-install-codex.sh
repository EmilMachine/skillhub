#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SCOPE="global"
ACTION="on"
THRESHOLD=0
SOUND=""

args=("$@")
i=0
if [[ "${args[0]:-}" == "local" ]]; then
  SCOPE="local"
  i=1
fi

for tok in "${args[@]:$i}"; do
  if [[ "$tok" == "off" ]]; then
    ACTION="off"
  elif [[ "$tok" =~ ^([0-9]+)s?$ ]]; then
    THRESHOLD="${BASH_REMATCH[1]}"
  elif [[ "$tok" =~ ^[a-eA-E]$ ]]; then
    SOUND="$(tr '[:upper:]' '[:lower:]' <<< "$tok")"
  else
    echo "❌ Error: invalid argument '$tok'. Usage: /ding [local] [off|<seconds>[s]] [a|b|c|d|e]"
    exit 1
  fi
done

if [[ "$SCOPE" == "local" ]]; then
  PROJECT_DIR="$(pwd)"
  TARGET_DIR="$PROJECT_DIR/.codex/ding"
  HOOKS_FILE="$PROJECT_DIR/.codex/hooks.json"
else
  TARGET_DIR="$HOME/.codex/ding"
  HOOKS_FILE="$HOME/.codex/hooks.json"
fi

mkdir -p "$TARGET_DIR"
cp "$SCRIPT_DIR/runtime/ding-hook.sh" "$TARGET_DIR/ding-hook.sh"
cp "$SCRIPT_DIR/runtime/"*-*.wav "$TARGET_DIR/"
chmod +x "$TARGET_DIR/ding-hook.sh"
rm -f "$TARGET_DIR/config.json" "$TARGET_DIR/ding.wav"

if [[ -z "$SOUND" ]]; then
  if [[ -f "$TARGET_DIR/config.jsonc" ]]; then
    SOUND=$(grep -vE '^[[:space:]]*//' "$TARGET_DIR/config.jsonc" | jq -r '.sound // "a"' 2>/dev/null)
  fi
  [[ -n "$SOUND" && "$SOUND" != "null" ]] || SOUND="a"
fi

if [[ "$ACTION" == "off" ]]; then
  ENABLED="false"
else
  ENABLED="true"
fi

sound_list=$(cd "$SCRIPT_DIR/runtime" && ls *-*.wav | sed -E 's/^([a-e])-(.*)\.wav$/\1 = \2/' | paste -sd, - | sed 's/,/, /g')

cat > "$TARGET_DIR/config.jsonc" <<EOF
// ding sound config — edit "sound" to one of: ${sound_list}
// to use a custom sound: get any short .wav file, save it in this folder as <name>-<label>.wav, then set "sound" to <name>
{
  "enabled": $ENABLED,
  "threshold": $THRESHOLD,
  "sound": "$SOUND"
}
EOF

[[ -f "$HOOKS_FILE" ]] || echo '{}' > "$HOOKS_FILE"

HOOK_CMD="bash \"$TARGET_DIR/ding-hook.sh\""

already_present=$(jq --arg cmd "$HOOK_CMD" \
  '[.hooks.Stop // [] | .[].hooks[]? | select(.command == $cmd)] | length > 0' \
  "$HOOKS_FILE" 2>/dev/null)

if [[ "$already_present" != "true" ]]; then
  tmp=$(mktemp)
  jq --arg cmd "$HOOK_CMD" \
    '.hooks = (.hooks // {}) |
     .hooks.Stop = (.hooks.Stop // []) + [{"matcher": "*", "hooks": [{"type": "command", "command": $cmd, "timeout": 30}]}]' \
    "$HOOKS_FILE" > "$tmp" && mv "$tmp" "$HOOKS_FILE"
fi

CONFIG_TOML="$HOME/.codex/config.toml"
FLAG_ADDED="false"
if [[ -f "$CONFIG_TOML" ]] && grep -qE '^\s*codex_hooks\s*=\s*true' "$CONFIG_TOML"; then
  : # already enabled
else
  mkdir -p "$HOME/.codex"
  touch "$CONFIG_TOML"
  if grep -qE '^\[features\]' "$CONFIG_TOML"; then
    tmp=$(mktemp)
    awk '/^\[features\]/ && !done { print; print "codex_hooks = true"; done=1; next } { print }' "$CONFIG_TOML" > "$tmp" && mv "$tmp" "$CONFIG_TOML"
  else
    printf '\n[features]\ncodex_hooks = true\n' >> "$CONFIG_TOML"
  fi
  FLAG_ADDED="true"
fi

echo "✅ ding ($SCOPE, codex): enabled=$ENABLED threshold=${THRESHOLD}s sound=$SOUND"
echo "   hooks: $HOOKS_FILE"
echo "   files: $TARGET_DIR"
if [[ "$FLAG_ADDED" == "true" ]]; then
  echo "   enabled codex_hooks feature flag in $CONFIG_TOML"
fi
echo "⚠️  Restart the Codex session for hook changes to take effect."
