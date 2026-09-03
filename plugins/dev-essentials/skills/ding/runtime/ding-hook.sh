#!/usr/bin/env bash
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$DIR/config.jsonc"

[[ -f "$CONFIG" ]] || exit 0

strip_jsonc() {
  grep -vE '^[[:space:]]*//' "$CONFIG"
}

enabled=$(strip_jsonc | jq -r '.enabled // false' 2>/dev/null)
threshold=$(strip_jsonc | jq -r '.threshold // 0' 2>/dev/null)
sound=$(strip_jsonc | jq -r '.sound // "a"' 2>/dev/null)

[[ "$enabled" == "true" ]] || exit 0

SOUND=$(ls "$DIR/${sound}-"*.wav 2>/dev/null | head -n1)
[[ -n "$SOUND" ]] || SOUND=$(ls "$DIR"/a-*.wav 2>/dev/null | head -n1)

if [[ "${threshold:-0}" -gt 0 ]]; then
  input=$(cat)
  transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

  if [[ -n "$transcript_path" && -f "$transcript_path" ]]; then
    start_ts=$(jq -c 'select(.type=="user")
      | select((.message.content | type) != "array"
               or (.message.content[0].type != "tool_result"))
      | .timestamp' "$transcript_path" 2>/dev/null | tail -n1 | tr -d '"')

    if [[ -n "$start_ts" ]]; then
      start_epoch=$(echo "$start_ts" | sed -E 's/\.[0-9]+Z$/Z/' | jq -R 'fromdateiso8601' 2>/dev/null)
      now_epoch=$(date -u +%s)
      if [[ -n "$start_epoch" ]]; then
        elapsed=$(( now_epoch - start_epoch ))
        [[ "$elapsed" -ge "$threshold" ]] || exit 0
      fi
    fi
  fi
fi

play_sound() {
  [[ -n "$SOUND" ]] || { printf '\a'; return; }
  if command -v afplay >/dev/null 2>&1; then
    afplay "$SOUND"
  elif command -v paplay >/dev/null 2>&1; then
    paplay "$SOUND"
  elif command -v aplay >/dev/null 2>&1; then
    aplay -q "$SOUND"
  elif command -v ffplay >/dev/null 2>&1; then
    ffplay -nodisp -autoexit -loglevel quiet "$SOUND"
  elif command -v play >/dev/null 2>&1; then
    play -q "$SOUND"
  else
    printf '\a'
  fi
}

( play_sound >/dev/null 2>&1 & disown ) 2>/dev/null

exit 0
