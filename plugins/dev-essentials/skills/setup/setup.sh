#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$PWD}"

mkdir -p "$ROOT/myprompts" "$ROOT/myreports" "$ROOT/AGENTS"

[ -f "$ROOT/myprompts/.gitignore" ] || echo '*' > "$ROOT/myprompts/.gitignore"
[ -f "$ROOT/myreports/.gitignore" ] || echo '*' > "$ROOT/myreports/.gitignore"

[ -f "$ROOT/AGENTS.md" ] || cat > "$ROOT/AGENTS.md" <<'EOF'
# Agent Instructions

## Commands
- **Run**: `<run command>`

## Conventions
- **<topic>**: <reference to .md files in AGENTS folder>

## Constraints
- Don't <refrence to .md files in AGENTS folder>
EOF

[ -f "$ROOT/CLAUDE.md" ] || cat > "$ROOT/CLAUDE.md" <<'EOF'
Read AGENTS.md
EOF

[ -f "$ROOT/opencode.json" ] || cat > "$ROOT/opencode.json" <<'EOF'
{
  "instructions": ["AGENTS.md"]
}
EOF
