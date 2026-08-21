---
name: pysetup
description: Bootstrap a Python project via dev-essentials setup, then add uv/ruff conventions to AGENTS.md
argument-hint: <project-root-path> (optional)
---

1. Invoke the setup skill (dev-essentials plugin) with `$ARGUMENTS`. If that skill is unavailable or fails to invoke: output "❌ Error: dev-essentials plugin not installed. Run: /plugin install dev-essentials@skillhub" and STOP.
2. Determine `GIT_ROOT`: `git rev-parse --show-toplevel` (fallback to `pwd` if not a git repo).
3. Ensure `GIT_ROOT/AGENTS.md` exists (it will, from step 1's `setup` invocation).
4. Under a `## Commands` section in `GIT_ROOT/AGENTS.md` (create the section near the top, after the title, if absent), append these two lines — skip any line already present (idempotent):
   ```
   - **Run**: for python use uv
   - **After editing any `.py` file**: run `uv run ruff format <file>` and `uv run ruff check --fix <file>` on the changed file before finishing.
   ```
5. Output which lines were added vs. already present.
