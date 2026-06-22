---
name: learn
description: Extract learnings from conversation history, a file, or freetext and save them to AGENTS.md / AGENTS/ files
argument-hint: "[topic | file-path]"
---

**Determine mode from `$ARGUMENTS`:**
- Empty → **history mode**
- No spaces AND file exists at path → **file mode**
- Otherwise → **freetext mode**

---

**History mode:** Review the current conversation context. Identify facts, rules, constraints, or patterns that future agents running in this project would benefit from knowing. Focus on non-obvious decisions, corrections, and constraints surfaced during the conversation.

**File mode:** Read `$ARGUMENTS`. Extract agent-relevant learnings from its content (treat the file as the source, ignore conversation history).

**Freetext mode:**
- Short directive (≤6 words, imperative, e.g. "never do git commits"): treat as a single rule bullet directly — minimal history scan needed.
- Longer phrase: use as topic filter — review conversation context for related decisions and compose targeted learning bullets.

---

**Compose learning bullets** (all modes):
- Terse, imperative bullets — one idea per bullet
- Focus: rules, constraints, conventions, non-obvious decisions
- Exclude: things already obvious from code or docs

---

**Confirm with user:**

Output:
```
Proposed learnings:
- <bullet 1>
- <bullet 2>
...

1. Proceed  2. Modify  3. Stop
```

- If **2**: ask for clarification, revise bullets, show updated list, repeat prompt.
- If **3**: output "Stopped. No changes made." and STOP immediately.
- If **1**: continue.

---

**Write learnings to AGENTS files:**

0. **Locate git root (run first):**
   ```bash
   git rev-parse --show-toplevel && pwd
   ```
   - `GIT_ROOT` = output of `--show-toplevel` (fallback to `pwd` if not a git repo)
   - `SUBPATH` = relative path from GIT_ROOT to cwd (empty if already at root)
   - All file operations below use `GIT_ROOT` as the base — never cwd.

1. Ensure `GIT_ROOT/AGENTS/` exists (`mkdir -p "$GIT_ROOT/AGENTS"`)
2. Read `GIT_ROOT/AGENTS.md` if it exists; create if missing:
   ```markdown
   # Agent Instructions

   ## Conventions
   ```
3. For each learning bullet:
   - Scan `GIT_ROOT/AGENTS.md` for references to existing `AGENTS/*.md` files
   - Read referenced files to find the most relevant topic match
   - If a relevant file found: append bullet to that file under the appropriate section
   - If no relevant file found: derive a short `<topic>` slug, create `GIT_ROOT/AGENTS/<topic>.md` with `# <Topic>` header and the bullet, then add a reference line to `GIT_ROOT/AGENTS.md`: `- <topic>: SUBPATH/AGENTS/<topic>.md` (omit `SUBPATH/` prefix if SUBPATH is empty)
4. If AGENTS.md itself is the best home: append bullet directly to `GIT_ROOT/AGENTS.md`.

---

**Output summary:**
```
Learnings saved:
- "<bullet>" → AGENTS/<file>.md
- "<bullet>" → AGENTS.md
```
