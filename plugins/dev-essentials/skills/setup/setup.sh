#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$PWD}"

mkdir -p "$ROOT/myprompts" "$ROOT/mycodereviews"

[ -f "$ROOT/myprompts/.gitignore" ] || echo '*' > "$ROOT/myprompts/.gitignore"
[ -f "$ROOT/mycodereviews/.gitignore" ] || echo '*' > "$ROOT/mycodereviews/.gitignore"

grep -qxF 'LOCAL_AGENTS.md' "$ROOT/.gitignore" 2>/dev/null || echo 'LOCAL_AGENTS.md' >> "$ROOT/.gitignore"

[ -f "$ROOT/AGENTS.md" ] || cat > "$ROOT/AGENTS.md" <<'EOF'
# Project Instructions

## Overview
<short project description>

## Commands
- Run tests: `uv run pytest`
- Lint: `uv run ruff check`
- Format: `uv run ruff format`

## Conventions
- Use `uv run` to execute Python — never call `python` or `pip` directly
- All new code goes through `src/`; tests mirror the structure under `tests/`
- Prefer `polars` over `pandas` for dataframe work

## Architecture
<key modules and their responsibilities>

## For local environment settings, see LOCAL_AGENTS.md (gitignored)
EOF

[ -f "$ROOT/CLAUDE.md" ] || cat > "$ROOT/CLAUDE.md" <<'EOF'
Read AGENTS.md for full project instructions.
If LOCAL_AGENTS.md exists, read it for local environment settings (Python interpreter, paths).
EOF

[ -f "$ROOT/opencode.json" ] || cat > "$ROOT/opencode.json" <<'EOF'
{
  "instructions": ["AGENTS.md", "LOCAL_AGENTS.md"]
}
EOF

[ -f "$ROOT/LOCAL_AGENTS.md.example" ] || cat > "$ROOT/LOCAL_AGENTS.md.example" <<'EOF'
# Local Environment (copy this file to LOCAL_AGENTS.md and fill in)

## Python
- Package manager: uv | poetry | conda | pip
- Run Python as: `uv run python` | `conda run -n <env> python` | `python`
- Conda env (if applicable): <env name or n/a>

## Paths
- Repo root: /path/to/repo
- Data dir: /path/to/data  (or n/a)

## Personal preferences
- (optional — IDE, debug flags, etc.)
EOF

[ -f "$ROOT/LOCAL_AGENTS.md" ] || cat > "$ROOT/LOCAL_AGENTS.md" <<'EOF'
# Local Environment

## Python
- Package manager: uv
- Run Python as: `uv run python`
- Run scripts as: `uv run <script>`
- Conda env (if applicable): n/a

## Paths
- Repo root: /Users/<you>/code/<project>
- Data dir: /data/<project>

## Personal preferences
- <anything machine-specific>
EOF
