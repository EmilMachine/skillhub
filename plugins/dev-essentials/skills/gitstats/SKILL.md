---
name: gitstats
description: Git contributor stats — optional filter by filename or contributor name
argument-hint: "[filename | contributor | LINES|FILES|LAST]"
allowed-tools: Bash(bash *gitstats_all.sh*)
---

**Script path:** The harness injects `Base directory for this skill: <path>` at the top of these instructions — use that path as `BASE_DIR` for all script references below.

First verify the script exists:
```bash
test -f "<BASE_DIR>/gitstats_all.sh" || { echo "❌ Script not found — run /skillhub-update to upgrade dev-essentials"; exit 1; }
```
If that fails, STOP and relay the error message.

Run `bash "<BASE_DIR>/gitstats_all.sh" $ARGUMENTS` and print the output.

Modes (handled entirely by script — no parsing needed here):
- No arg / `LINES` / `FILES` / `LAST` → all contributors ranked by chosen column
- Partial contributor name → top-10 files for matched contributor
- File path with git history → contributor breakdown for that file
- Unrecognized arg → script prints error and exits non-zero; relay the error message
