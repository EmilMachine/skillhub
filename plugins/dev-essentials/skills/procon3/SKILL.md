---
name: procon3
description: Find 3 alternatives with pros/cons each
argument-hint: <statement or question>
---

**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` is empty: output "❌ Error: Topic required. Usage: /procon3 <decision or question>" and STOP.

1. Identify 3 distinct alternatives for: `$ARGUMENTS`
2. If local context insufficient: run up to 3 WebSearch queries
3. For each alternative:
   - **Name:** short label
   - **Pros:** 2-4 bullets
   - **Cons:** 2-4 bullets
4. Output terse result directly to user — no file write
