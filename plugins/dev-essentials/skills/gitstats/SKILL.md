---
name: gitstats
description: Git contributor stats — optional filter by filename or contributor name
argument-hint: "[filename | contributor | LINES|FILES|LAST]"
allowed-tools: Bash(if [ -f "*gitstats_all.sh" ]; then bash "*gitstats_all.sh"*)
---

**Script path:** The harness injects `Base directory for this skill: <path>` at the top of these instructions — use that path as `BASE_DIR` for all script references below.

Run this single command and print the output:
```bash
if [ -f "<BASE_DIR>/gitstats_all.sh" ]; then bash "<BASE_DIR>/gitstats_all.sh" $ARGUMENTS; else echo "❌ Script not found — run /skillhub-update to upgrade dev-essentials"; fi
```

Modes (handled entirely by script — no parsing needed here):
- No arg / `LINES` / `FILES` / `LAST` → all contributors ranked by chosen column
- Partial contributor name → top-10 files for matched contributor
- File path with git history → contributor breakdown for that file
- Unrecognized arg → script prints error and exits non-zero; relay the error message
