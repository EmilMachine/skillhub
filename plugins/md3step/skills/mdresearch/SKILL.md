---
name: mdresearch
description: Research codebase state from context file
argument-hint: path/to/0_context.md
---

**TERSE MODE:** Minimal output. Bullet points. Technical language.

**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` is empty/missing: output "❌ Error: Path to 0_context.md required. Usage: /mdresearch <path/to/0_context.md>" and STOP immediately.

1. **Read `$ARGUMENTS`** - Abort if not found: "❌ Error: Context file not found at $ARGUMENTS"
2. **Extract directives**: scan the context file for meta-instructions about scope/process (e.g. "do not implement", "plan only", "output to [PATH]", "do not commit") - verbatim, distinct from technical requirements
3. Research codebase (Task/Explore for broad, Grep/Glob/Read for specific, websearch if needed - max 3/topic)
4. Write `1_research.md` in same directory:
   - Start with `# Directives` at the very TOP of document (above everything) - verbatim bullets from step 2, or `- None.` if none found
   - Below it, `# Research Report: [Topic]` with Current State, Gaps, Relevant Files (`path:line`), Recommendations
   - **After completing all research sections**, add `# Open Questions` above the title (below Directives) - write this section LAST with full context
5. Output: "🔍 Research complete 🔍. Created 1_research.md"

**All content terse.** Facts only. `path:line` refs mandatory.
