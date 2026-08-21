---
name: changelog
description: Append a terse entry to CHANGELOG.md from a source file, a branch diff, or freetext instructions
argument-hint: <path-to-source-changelog> | "branch <name>" | "<freetext instructions>"
allowed-tools: Bash(git diff*), Bash(git log*), Bash(git rev-parse*)
---

**IMMEDIATE EXIT if no argument:**
- If `$ARGUMENTS` empty/missing: output "❌ Error: Source required. Usage: /changelog <path> | branch <name> | <freetext>" and STOP.

**Locate target file:**
- Run `git rev-parse --show-toplevel` (fallback: `pwd` if not a git repo) → this is `ROOT`.
- Target is `ROOT/CHANGELOG.md`. If missing, create it with a minimal header (`# Changelog\n`) before inserting the first entry.

**Determine mode from `$ARGUMENTS`:**
- Single token, no spaces, resolves to an existing file → **file mode**.
- Starts with literal `branch ` → **branch mode** (rest of string = `<branch-name>`).
- Anything else (multi-line or multi-word) → **freetext mode**.

**File mode:**
- Read the file. Extract: date (file content if stated, else file mtime), branch name (if stated), one-sentence summary, ≤2 notable gotchas.
- Scan content for a version bump (e.g. `"version": "X.Y.Z"`, `version = "X.Y.Z"`) — use as `<VERSION>` if found.

**Branch mode:**
- Run `git diff origin/main...<branch-name> --stat --unified=0` and `git log origin/main..<branch-name> --oneline`.
- Derive title and bullets from the diff + log (one bullet per distinct subject: CI, docs, bug fix, etc.).
- Date = today. Branch = `<branch-name>`.
- Scan the diff for a version bump in `plugin.json`, `package.json`, `Cargo.toml`, `pyproject.toml`, or `VERSION` (changed `"version"` / `version =` line) — use the new value as `<VERSION>` if found.

**Freetext mode:**
- Treat `$ARGUMENTS` as authoring instructions/context. Compose the entry directly from it.
- Use a `<VERSION>` only if one is explicitly stated in the text — never invent one.

**Compose entry** (omit `[<VERSION>] ` prefix when no version was found; omit "Notable gotchas" block when there are none; keep entry under ~10 lines total):
```
## [<VERSION>] <DATE> — <TITLE> (`<BRANCH>`)

- <change 1>
- <change 2>
- <change 3>

Notable gotchas:
- <gotcha 1>
```

**Write:**
- Prepend the new entry immediately after the header block, before the first existing `## ` entry (or right after `# Changelog` if the file is new/empty).
- Never alter existing entries.

**Output:** `"✅ Added entry to CHANGELOG.md: <title>"`
