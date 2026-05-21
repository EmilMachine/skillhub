---
name: cleanup
description: Analyse a codebase path for dead code, unused tests, redundant logic, refactor opportunities, and outdated docs; write terse report to myreports/
argument-hint: <path> (optional, defaults to .)
---

**IMMEDIATE EXIT if path invalid:**
- If `$ARGUMENTS` is non-empty and the path does not exist: output "❌ Path not found: $ARGUMENTS" and STOP.

Target: `$ARGUMENTS` (default `.`)

1. Map the codebase — `find <target> -type f` excluding `node_modules`, `.git`, `build`, `dist`, `__pycache__`, `.venv`
2. For each category, use `grep` + `Read` to find issues — cite `file:line`:
   - **Dead Code:** defined symbols (functions, classes, exports) with zero references elsewhere
   - **Unused Tests:** test cases referencing deleted, renamed, or missing code
   - **Redundant:** near-duplicate helpers, copy-pasted logic blocks
   - **Refactor:** functions >70 lines, nesting depth >3, magic literals, large switch/if chains
   - **Docs:** comments/docstrings that contradict code, outdated param names, stale TODOs, READMEs describing removed features
3. Determine label: basename of the resolved target path, with file extension stripped
4. `mkdir -p myreports` and create `myreports/.gitignore` (`*`) if it doesn't exist
5. Write report to `myreports/cleanup-<label>.md`:
   - Header: `# Cleanup: <target> — <YYYY-MM-DD>`
   - Five sections with terse bullet items (`file:line` — one-line description)
   - If a category has no findings write "None found"
6. Output: "✅ Cleanup report written to myreports/cleanup-<label>.md"
