---
name: codereview
description: Fetch a branch and write a terse major/minor/nit code review to mycodereviews/
argument-hint: <branch>
allowed-tools: Bash(bash *codereview.sh*)
---

**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` is empty: output "❌ Error: Branch name required. Usage: /codereview <branch>" and STOP.

1. Run `bash "$(dirname "$0")/codereview.sh" $ARGUMENTS` — captures diff or error message
2. If script exits non-zero: print the suggested git command and STOP
3. Review the diff output — terse format:
   - **Major:** breaking/correctness issues
   - **Minor:** code quality, naming, tests
   - **Nit:** style, cosmetic
4. Write review to `mycodereviews/$ARGUMENTS.md` (create dir if needed)
5. Output: "✅ Review written to mycodereviews/$ARGUMENTS.md"
