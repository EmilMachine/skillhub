---
name: mdupdate
description: Refine plan by integrating user's inline answers
argument-hint: path/to/2_plan.md
---

**TERSE MODE:** Minimal output. Bullet points. Technical language.

**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` is empty/missing: output "❌ Error: Path to 2_plan.md required. Usage: /mdupdate <path/to/2_plan.md>" and STOP immediately.

1. **Read `$ARGUMENTS`** - Abort if not found: "❌ Error: Plan file not found at $ARGUMENTS"
2. Find inline answers (A:, Answer:, user comments, edits)
3. Work into relevant sections (Overview, Steps, etc.)
4. Update Open Questions: keep unresolved or "None currently."
5. Write updated `$ARGUMENTS` in place
6. Output: "♻️ Plan refined ♻️. [X answers integrated, Y questions remaining]"

**Preserve structure. Keep terse.** If no edits, inform user.
