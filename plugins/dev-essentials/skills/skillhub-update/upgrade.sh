#!/usr/bin/env bash
# upgrade.sh — dispatcher for skillhub plugin upgrade adapters.
# Detects the running agent tool and delegates to the appropriate adapter:
#   upgrade-claude.sh   Claude Code
#   upgrade-codex.sh    Codex CLI
#   upgrade-opencode.sh OpenCode
#
# Shared utilities (version comparison, table formatting) live in lib.sh.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── jq check ──────────────────────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ jq is required but not found. Install with: brew install jq"
  exit 1
fi

# ── Tool detection ─────────────────────────────────────────────────────────────
# Priority 1: env vars (reliable inside a running session)
TOOL="unknown"
if [ "${CLAUDECODE:-}" = "1" ] || [ -n "${CLAUDE_CODE_SESSION_ID:-}" ]; then
  TOOL="claude"
elif [ -n "${OPENCODE:-}" ] || [ -n "${OPENCODE_DATA_HOME:-}" ] || [ -n "${OPENCODE_SESSION:-}" ]; then
  TOOL="opencode"
elif [ -n "${CODEX_HOME:-}" ] || [ -n "${CODEX:-}" ] || \
     [ -n "${CODEX_SESSION_ID:-}" ] || [ -n "${OPENAI_CODEX_SESSION:-}" ]; then
  TOOL="codex"
fi

# Priority 2: parent process name (fallback)
if [ "$TOOL" = "unknown" ] && command -v ps >/dev/null 2>&1; then
  _parent=$(ps -p "${PPID:-0}" -o comm= 2>/dev/null | tr '[:upper:]' '[:lower:]' || true)
  case "$_parent" in
    *claude*)   TOOL="claude" ;;
    *opencode*) TOOL="opencode" ;;
    *codex*)    TOOL="codex" ;;
  esac
fi

if [ "$TOOL" = "unknown" ]; then
  echo "ℹ️  Tool not detected (CLAUDECODE env var not set)."
  echo "    Running inside a supported agent? Restart the session and retry."
  exit 0
fi

# ── Load shared utilities ──────────────────────────────────────────────────────
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

# ── Dispatch to tool adapter ───────────────────────────────────────────────────
ADAPTER="$SCRIPT_DIR/upgrade-${TOOL}.sh"

if [ ! -f "$ADAPTER" ]; then
  echo "⚠️  No upgrade adapter found for tool: $TOOL"
  echo "    Supported adapters: $(ls "$SCRIPT_DIR"/upgrade-*.sh 2>/dev/null \
    | sed 's|.*/upgrade-||;s|\.sh||' | tr '\n' ' ' || echo 'none')"
  exit 1
fi

# shellcheck source=/dev/null
source "$ADAPTER"
run_upgrade
