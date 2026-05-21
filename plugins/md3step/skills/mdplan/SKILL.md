---
name: mdplan
description: Generate step-by-step implementation plan from research
argument-hint: path/to/1_research.md
---

**TERSE MODE:** Minimal output. Bullet points. Technical language.

**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` is empty/missing: output "❌ Error: Path to 1_research.md required. Usage: /mdplan <path/to/1_research.md>" and STOP immediately.

1. **Read `$ARGUMENTS`** - Abort if not found: "❌ Error: Research file not found at $ARGUMENTS"
2. Break into sequential, testable steps
3. Write `2_plan.md` in same directory:
   - Start with: `# Implementation Plan: [Topic]` with Overview
   - Numbered steps: each with Actions, Files, Verify
   - Success Criteria
   - **After completing all plan sections**, add `# Open Questions` at the TOP of document (above title) - write this section LAST with full context
4. Output: "🛠️ Plan complete 🛠️. Created 2_plan.md"

**All content terse.** Each step atomic. Clear verification criteria.
