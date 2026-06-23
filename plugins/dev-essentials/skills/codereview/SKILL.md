---
name: codereview
description: Fetch a branch and write a terse major/minor/nit code review to myreports/
argument-hint: <branch>
allowed-tools: Bash(bash *codereview.sh*)
---

**Script path:** The harness injects `Base directory for this skill: <path>` at the very top of these instructions. That full path is `BASE_DIR` — it already ends in `.../skills/codereview`. Do not trim or modify it.

**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` is empty: output "❌ Error: Branch name required. Usage: /codereview <branch>" and STOP.

1. Run `bash "<BASE_DIR>/codereview.sh" $ARGUMENTS` — captures diff or error message (substitute the actual BASE_DIR path)
2. If script exits non-zero: print the suggested git command and STOP
3. Review the diff output — terse format:
   - **Major:** breaking/correctness issues
   - **Minor:** code quality, naming, tests
   - **Nit:** style, cosmetic
4. Write review to `myreports/codereview-$ARGUMENTS.md` (create dir if needed)
5. Output: "✅ Review written to myreports/codereview-$ARGUMENTS.md"
