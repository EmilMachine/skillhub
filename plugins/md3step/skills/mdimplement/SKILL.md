---
name: mdimplement
description: Execute implementation plan with testing and verification
args:
  - name: path
    description: Path to 2_plan.md file
    required: true
---

**TERSE MODE:** Minimal output. Bullet points. Technical language.

**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` is empty/missing: output "❌ Error: Path to 2_plan.md required. Usage: /mdimplement <path/to/2_plan.md>" and STOP immediately.

1. **Read `$ARGUMENTS`** - Abort if not found: "❌ Error: Plan file not found at $ARGUMENTS". Warn if Open Questions unresolved.
2. Check prerequisites
3. Execute each step: Read files, make changes (Edit/Write), run verification, document. If fail: fix/document/alert.
4. Run final tests
5. Write `3_changelog.md` in same directory as `$ARGUMENTS`:
   - `# Implementation Changelog: [Topic]` with date, Summary
   - Per-step: Status (✓/⚠/✗), Files (`path:line`), Verify output
   - Test Results, Known Issues
   - at the top put a `# Gothas` section if issues arose with terse "- <title>:\n  - challenge: ... \n  - solution: ..." format.
6. Compact the 3_changelog.md try making it ~50% of length.
7. Output: "✨ Implementation complete ✨. Created 3_changelog.md [X/Y steps, Z tests passed]"

**NO git commits.** Verify before proceeding. **Changelog ultra-terse:** facts, statuses, `path:line` refs only.
