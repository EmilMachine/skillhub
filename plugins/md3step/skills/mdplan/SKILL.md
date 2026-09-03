---
name: mdplan
description: Generate step-by-step implementation plan from research
argument-hint: path/to/1_research.md
---

**TERSE MODE:** Minimal output. Bullet points. Technical language.

**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` is empty/missing: output "❌ Error: Path to 1_research.md required. Usage: /mdplan <path/to/1_research.md>" and STOP immediately.

1. **Read `$ARGUMENTS`** - Abort if not found: "❌ Error: Research file not found at $ARGUMENTS"
2. **Carry forward `# Directives`** if present in `$ARGUMENTS`: copy verbatim, unchanged - do not reinterpret or drop them
3. Break into sequential, testable steps
4. Write `2_plan.md` in same directory:
   - Start with `# Directives` at the very TOP of document (above everything) - verbatim from step 2, or `- None.` if none found
   - Below it, `# Implementation Plan: [Topic]` with Overview
   - Numbered steps: each with Actions, Files, Verify
   - Success Criteria
   - **After completing all plan sections**, add `# Open Questions` above the title (below Directives) — write this section LAST:
     - Format each as: `- [ ] <specific question> — needed for: <which step>`
     - Only include blockers or ambiguities that affect implementation choices
     - If none: `- None.`
   - **FINAL REFINE**: scan sibling `*.md` files in same dir (exclude `2_plan.md`) — if answers found, fold into relevant steps and remove resolved questions
5. Output: "🛠️ Plan complete 🛠️. Created 2_plan.md"

**All content terse.** Each step atomic. Clear verification criteria.
