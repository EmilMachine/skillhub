---
name: issue
description: Create a GitHub issue from conversation context; auto-labels bug-agentmade
argument-hint: "[optional user summary]"
allowed-tools: Bash(bash *create_issue.sh*)
---

**Permission note:** This skill runs Bash to create issues. You may be prompted to allow Bash execution. To skip future prompts, add to `.claude/settings.json`: `"Bash(bash *create_issue.sh*)"`

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

**Script path:** The harness injects `Base directory for this skill: <path>` at the top of these instructions — use that path as `BASE_DIR` for all script references below.

**Phase 2 — Create issue (Bash):**

Pass TITLE and BODY via env vars (safe for quotes/special chars):
```bash
ISSUE_TITLE="<TITLE>" ISSUE_TEXT="<BODY content>" bash "<BASE_DIR>/create_issue.sh"
```
(substitute the actual BASE_DIR path)

**If exit code is 2 (FORMAT ERROR):**
- Read the error output — each `- body missing required field: '<field>:'` line names a missing field
- Fix TITLE and/or BODY to satisfy all listed fields
- Retry Phase 2 immediately with the corrected values — max 2 retries
- If still exit 2 after 2 retries: output the raw error and STOP — do not proceed to URL fallback

**If exit code is 0:** output `Issue: <url>` and STOP.
**If exit code is 1:** output the error and STOP.
