#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$PWD}"

mkdir -p "$ROOT/myprompts" "$ROOT/myreports"

[ -f "$ROOT/myprompts/.gitignore" ] || echo '*' > "$ROOT/myprompts/.gitignore"
[ -f "$ROOT/myreports/.gitignore" ] || echo '*' > "$ROOT/myreports/.gitignore"

if ! grep -qxF 'LOCAL_AGENTS.md' "$ROOT/.gitignore" 2>/dev/null; then
  printf '\n\n# LOCAL AGENTS\nLOCAL_AGENTS.md\n' >> "$ROOT/.gitignore"
fi

# Migrate existing CLAUDE.md to AGENTS.md if needed
if [ -f "$ROOT/CLAUDE.md" ] && [ ! -f "$ROOT/AGENTS.md" ]; then
  cp "$ROOT/CLAUDE.md" "$ROOT/AGENTS.md"
fi

[ -f "$ROOT/AGENTS.md" ] || cat > "$ROOT/AGENTS.md" <<'EOF'
# Project Instructions

## Overview
<short project description>

## Commands
- Run tests: `<test command>`
- Lint: `<lint command>`
- Build: `<build command>`

## Conventions
<coding conventions>

## Architecture
<key modules and their responsibilities>

## For local environment settings, see LOCAL_AGENTS.md (gitignored)
EOF

cat > "$ROOT/CLAUDE.md" <<'EOF'
Read AGENTS.md for full project instructions.
If LOCAL_AGENTS.md exists, read it for local environment settings.
EOF

[ -f "$ROOT/opencode.json" ] || cat > "$ROOT/opencode.json" <<'EOF'
{
  "instructions": ["AGENTS.md", "LOCAL_AGENTS.md"]
}
EOF

[ -f "$ROOT/LOCAL_AGENTS.md.example" ] || cat > "$ROOT/LOCAL_AGENTS.md.example" <<'EOF'
# Local Environment (copy this file to LOCAL_AGENTS.md and fill in)

## Runtime
- Language/runtime: <e.g. node 20, python 3.12, go 1.22>
- Run commands as: <e.g. npm run, uv run, go run>
EOF

[ -f "$ROOT/LOCAL_AGENTS.md" ] || cat > "$ROOT/LOCAL_AGENTS.md" <<'EOF'
# Local Environment

## Runtime
- Language/runtime: <fill in>
- Run commands as: <fill in>
EOF
