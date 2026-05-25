#!/usr/bin/env bash
# upgrade.sh — detect tool context + version diff for installed plugins
# Output: KEY=VALUE lines. One PLUGIN= line per installed plugin.
set -uo pipefail

# ── jq check ──────────────────────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR=jq is required but not found. Install with: brew install jq"
  exit 1
fi

# ── Tool detection ─────────────────────────────────────────────────────────────
# Priority 1: env vars (reliable inside a running session)
TOOL="unknown"

if [ "${CLAUDECODE:-}" = "1" ] || [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then
  TOOL="claude"
elif [ -n "${OPENCODE:-}" ] || [ -n "${OPENCODE_DATA_HOME:-}" ] || [ -n "${OPENCODE_SESSION:-}" ]; then
  TOOL="opencode"
elif [ -n "${CODEX:-}" ] || [ -n "${CODEX_SESSION_ID:-}" ] || [ -n "${OPENAI_CODEX_SESSION:-}" ]; then
  TOOL="codex"
fi

# Priority 2: parent process name (fallback when env vars not set)
if [ "$TOOL" = "unknown" ] && command -v ps >/dev/null 2>&1; then
  _parent=$(ps -p "${PPID:-0}" -o comm= 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)
  case "$_parent" in
    *claude*)   TOOL="claude" ;;
    *opencode*) TOOL="opencode" ;;
    *codex*)    TOOL="codex" ;;
  esac
fi

echo "TOOL=$TOOL"

# ── Non-Claude tools: guidance + exit ─────────────────────────────────────────
if [ "$TOOL" != "claude" ]; then
  case "$TOOL" in
    opencode)
      echo "HINT=OpenCode detected. Check OpenCode docs for plugin update commands (opencode --help)." ;;
    codex)
      echo "HINT=Codex CLI detected. Check Codex docs for plugin update commands (codex --help)." ;;
    *)
      echo "HINT=Tool not detected (CLAUDECODE env var not set). Running inside Claude Code? Restart the session and retry." ;;
  esac
  exit 0
fi

# ── Claude Code: locate state files ───────────────────────────────────────────
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
PLUGIN_DIR="$CONFIG_DIR/plugins"
INSTALLED_FILE="$PLUGIN_DIR/installed_plugins.json"
MARKETPLACES_FILE="$PLUGIN_DIR/known_marketplaces.json"

for _f in "$INSTALLED_FILE" "$MARKETPLACES_FILE"; do
  if [ ! -f "$_f" ]; then
    echo "ERROR=Missing $_f — no plugins installed yet, or CLAUDE_CONFIG_DIR is non-standard"
    exit 1
  fi
done

echo "---"

# ── Version comparison helper ──────────────────────────────────────────────────
_compare_versions() {
  # Returns: lt | eq | gt
  local a="$1" b="$2"
  [ "$a" = "$b" ] && { echo "eq"; return; }
  # Try sort -V (available on macOS 12+ and GNU/Linux)
  if lower=$(printf '%s\n%s' "$a" "$b" | sort -V 2>/dev/null | head -1); then
    [ "$lower" = "$a" ] && echo "lt" || echo "gt"
    return
  fi
  # Portable numeric fallback: compare major.minor.patch fields
  local a1 a2 a3 b1 b2 b3
  IFS='.' read -r a1 a2 a3 <<< "$a"; IFS='.' read -r b1 b2 b3 <<< "$b"
  a1=${a1:-0}; a2=${a2:-0}; a3=${a3:-0}
  b1=${b1:-0}; b2=${b2:-0}; b3=${b3:-0}
  if   (( a1 < b1 )) \
    || (( a1 == b1 && a2 < b2 )) \
    || (( a1 == b1 && a2 == b2 && a3 < b3 )); then echo "lt"
  elif (( a1 == b1 && a2 == b2 && a3 == b3 ));   then echo "eq"
  else                                                  echo "gt"
  fi
}

# ── Version diff ───────────────────────────────────────────────────────────────
# installed_plugins.json: { "plugins": { "<name>@<mkt>": [{ "version": "x" }] } }
jq -r '.plugins | to_entries[] | .key + " " + .value[0].version' "$INSTALLED_FILE" | \
while IFS=' ' read -r plugin_key installed_version; do
  plugin_name="${plugin_key%@*}"
  marketplace="${plugin_key#*@}"

  # Resolve marketplace install path from known_marketplaces.json
  marketplace_path=$(jq -r --arg m "$marketplace" \
    '.[$m].installLocation // empty' "$MARKETPLACES_FILE" 2>/dev/null || true)

  if [ -z "${marketplace_path:-}" ]; then
    printf 'PLUGIN=%s INSTALLED=%s AVAILABLE=unknown STATUS=UNKNOWN MARKETPLACE=%s\n' \
      "$plugin_key" "$installed_version" "$marketplace"
    continue
  fi

  # Find plugin manifest in marketplace cache (prefer .claude-plugin/plugin.json)
  plugin_json=""
  for _c in \
    "$marketplace_path/plugins/$plugin_name/.claude-plugin/plugin.json" \
    "$marketplace_path/plugins/$plugin_name/plugin.json"; do
    [ -f "$_c" ] && { plugin_json="$_c"; break; }
  done

  if [ -z "${plugin_json:-}" ]; then
    printf 'PLUGIN=%s INSTALLED=%s AVAILABLE=unknown STATUS=UNKNOWN MARKETPLACE=%s\n' \
      "$plugin_key" "$installed_version" "$marketplace"
    continue
  fi

  available_version=$(jq -r '.version // "unknown"' "$plugin_json")

  if [ "$available_version" = "unknown" ]; then
    STATUS="UNKNOWN"
  else
    cmp=$(_compare_versions "$installed_version" "$available_version")
    case "$cmp" in
      lt) STATUS="OUTDATED" ;;
      eq) STATUS="UP_TO_DATE" ;;
      gt) STATUS="AHEAD" ;;
    esac
  fi

  printf 'PLUGIN=%s INSTALLED=%s AVAILABLE=%s STATUS=%s MARKETPLACE=%s\n' \
    "$plugin_key" "$installed_version" "$available_version" "$STATUS" "$marketplace"
done
