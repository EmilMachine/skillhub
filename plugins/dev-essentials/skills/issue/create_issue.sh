#!/usr/bin/env bash
set -uo pipefail

TITLE="${ISSUE_TITLE:?ISSUE_TITLE env var required}"
BODY="${ISSUE_TEXT:?ISSUE_TEXT env var required}"
REPO="EmilMachine/skillhub"
LABEL="bug-agentmade"

# --- Input validation (failures are directed at Claude, not the end user) ---
ERRORS=()

[[ -z "${TITLE// }" ]] && ERRORS+=("ISSUE_TITLE is blank")

REQUIRED_FIELDS=(plugin skill situation complication error_type steps_to_reproduce)
for field in "${REQUIRED_FIELDS[@]}"; do
  grep -qE "^${field}:" <<< "$BODY" || ERRORS+=("body missing required field: '${field}:'")
done

if [[ ${#ERRORS[@]} -gt 0 ]]; then
  echo "❌ [FORMAT ERROR — must retry with corrected input]"
  for err in "${ERRORS[@]}"; do
    echo "  - $err"
  done
  echo ""
  echo "Expected ISSUE_TITLE: non-empty string"
  echo "Expected BODY fields (one per line, colon-separated):"
  echo "  plugin: <name>"
  echo "  skill: <name>"
  echo "  situation: <one-line>"
  echo "  complication: <one-line>"
  echo "  error_type: <category>"
  echo "  steps_to_reproduce: <numbered steps>"
  exit 2
fi
# ---------------------------------------------------------------------------

# --- SCRUB — strip known secret shapes before posting ---
scrub() {
  local s="$1"
  # Key=value credentials (Bearer, token=, api_key=, secret=, password=, Authorization:)
  s=$(echo "$s" | sed -E "s/(Bearer |token=|api_?key=|secret=|password=|Authorization: )[^[:space:]\"'&,)]+/\1[REDACTED]/gi")
  # Known token prefixes: GitHub (ghp/ghs/gho), OpenAI (sk-), Slack (xoxb/xoxp), AWS (AKIA)
  s=$(echo "$s" | sed -E 's/\b(ghp|ghs|gho|sk-|xoxb|xoxp|AKIA)[A-Za-z0-9_-]{16,}/[TOKEN]/g')
  # Emails
  s=$(echo "$s" | sed -E 's/[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/[EMAIL]/g')
  # IPv4 addresses
  s=$(echo "$s" | sed -E 's/\b([0-9]{1,3}\.){3}[0-9]{1,3}\b/[IP]/g')
  # Absolute paths
  s=$(echo "$s" | sed -E 's|/Users/[^[:space:]",]+|[PATH]|g')
  s=$(echo "$s" | sed -E 's|/home/[^[:space:]",]+|[PATH]|g')
  s=$(echo "$s" | sed -E 's|/root/[^[:space:]",]+|[PATH]|g')
  # UUIDs
  s=$(echo "$s" | sed -E 's/\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b/[UUID]/gi')
  # Relative path segments not inside URLs (e.g. org/repo, folder/subdir/file)
  s=$(printf '%s' "$s" | perl -pe 's|(?<![:/\w])([a-zA-Z0-9_-]{2,}/[a-zA-Z0-9_-]{2,}(?:/[a-zA-Z0-9_-]{2,})*)|basepath/subpath|g')
  echo "$s"
}
BODY=$(scrub "$BODY")
# -------------------------------------------------------

BODY_FILE=$(mktemp)
printf '%s' "$BODY" > "$BODY_FILE"
trap 'rm -f "$BODY_FILE"; echo ""; echo "- Want to write your own issue?"; echo "  https://github.com/EmilMachine/skillhub/issues/new"' EXIT

# Try gh
if ! command -v gh >/dev/null 2>&1; then
  echo "⚠️ gh CLI not found, trying curl..."
elif RESULT=$(gh issue create --title "$TITLE" --body-file "$BODY_FILE" --label "$LABEL" --repo "$REPO" 2>&1); then
  echo "Issue: $RESULT"
  exit 0
else
  echo "⚠️ gh failed: $RESULT, trying curl..."
fi

# Try curl
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "⚠️ GITHUB_TOKEN not set, falling back to URL"
else
  PAYLOAD=$(jq -n --arg title "$TITLE" --arg body "$BODY" \
    '{"title":$title,"body":$body,"labels":["bug-agentmade"]}')
  RESULT=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" \
    "https://api.github.com/repos/$REPO/issues")
  CODE=$(printf '%s' "$RESULT" | tail -1)
  RESP=$(printf '%s' "$RESULT" | sed '$d')
  if [[ "$CODE" =~ ^2 ]]; then
    echo "Issue: $(printf '%s' "$RESP" | jq -r '.html_url')"
    exit 0
  fi
  echo "⚠️ curl failed: $CODE, falling back to URL"
fi

# URL fallback
# Note: /issues/new ignores the `labels` query param — it only works via issue templates.
URL="https://github.com/EmilMachine/skillhub/issues/new?$(
  jq -rn --arg t "$TITLE" --arg b "$BODY" \
    '"title=" + ($t|@uri) + "&body=" + ($b|@uri)'
)"
echo "⚠️ Could not create issue automatically. Open manually:"
echo "$URL"
if open "$URL" 2>/dev/null || xdg-open "$URL" 2>/dev/null; then
  echo "✓ Opened in browser"
else
  echo "⚠️ Could not open browser automatically"
fi
