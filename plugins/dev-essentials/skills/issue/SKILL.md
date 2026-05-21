---
name: issue
description: Create a GitHub issue from conversation context; auto-labels skillhub-bug
argument-hint: "[optional user summary]"
allowed-tools: Bash(bash *create_issue.sh*)
---

**Phase 1 — Populate fields (Claude):**
1. Capture `$ARGUMENTS` as `user_summary` (omit field if empty)
2. Scan conversation for most recent failure: plugin name, skill name, command run, verbatim error
3. Construct:
   - `TITLE`: `[issue] <skill>: <one-line error>`
   - `BODY` (one line each):
     ```
     plugin: <name>
     skill: <name>
     user_summary: <$ARGUMENTS>
     situation: <one-line: what was attempted>
     complication: <one-line: exact error or failure>
     trace: <relevant raw extracts; mark gaps between sections with ...>
     ```

**Phase 2 — Create issue (Bash):**

Pass TITLE via env var (safe for quotes/special chars), BODY via stdin heredoc:
```bash
ISSUE_TITLE="<TITLE>" bash "$0/create_issue.sh" <<'BODYEOF'
<BODY content>
BODYEOF
```

**If exit code is 2 (FORMAT ERROR):**
- Read the error output — each `- body missing required field: '<field>:'` line names a missing field
- Fix TITLE and/or BODY to satisfy all listed fields
- Retry Phase 2 immediately with the corrected values — max 2 retries
- If still exit 2 after 2 retries: output the raw error and STOP — do not proceed to URL fallback

**If exit code is 0:** output `Issue: <url>` and STOP.
**If exit code is 1:** output the error and STOP.
