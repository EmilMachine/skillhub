# Dev Essentials Plugin

Dev workflow essentials: project setup, code review, cleanup analysis, pro/con, and sandboxed dev environments.

## Skills

### `/setup`
Bootstrap a project with agent config files and private prompt dirs.
- **Input:** `<project-root-path>` (optional)
- **Usage:** `/setup [path]`

### `/codereview`
Fetch a branch and write a terse major/minor/nit code review to `myreports/`.
- **Input:** `<branch>`
- **Usage:** `/codereview <branch>`

### `/procon3`
Find 3 alternatives with pros/cons each.
- **Input:** `<statement or question>`
- **Usage:** `/procon3 <statement or question>`

### `/pc3`
Shortcut alias for `/procon3`.
- **Input:** `<statement or question>`
- **Usage:** `/pc3 <statement or question>`

### `/issue`
Create a GitHub issue from conversation context; auto-labels `bug-agentmade`.
- **Input:** `"[optional user summary]"`
- **Usage:** `/issue ["summary"]`

### `/cleanup`
Analyse a codebase path for dead code, unused tests, redundant logic, refactor opportunities, and outdated docs; write terse report to `myreports/`.
- **Input:** `<path>` (optional, defaults to `.`)
- **Usage:** `/cleanup [path]`

### `/secure`
Security audit a codebase path — OWASP Top 10 (2025), secrets, dependency CVEs, misconfigs; write severity-ranked report to `myreports/`.
- **Input:** `<path>` (optional, defaults to `.`)
- **Usage:** `/secure [path]`

### `/skillhub-update`
Update all installed plugins to latest — detects tool, diffs versions, updates stale.
- **Usage:** `/skillhub-update`

### `/gitstats`
Git contributor stats — optional filter by filename or contributor name.
- **Input:** `"[filename | contributor | LINES|FILES|LAST]"`
- **Usage:** `/gitstats ["filter"]`

### `/learn`
Extract learnings from conversation history, a file, or freetext and save them to `AGENTS.md` / `AGENTS/` files.
- **Input:** `"[topic | file-path]"`
- **Usage:** `/learn ["topic"]`

### `/devcontainer`
Stamp out a `.devcontainer` folder (claude-slim Docker setup) into the current directory or a given path.
- **Input:** `[-f] [path]`
- **Usage:** `/devcontainer [-f] [path]`

### `/nono`
Stamp out a `.nono` folder (sandboxed Claude Code profiles for [nono](https://nono.sh)) into the current directory or a given path.
- **Input:** `[-f] [path]`
- **Usage:** `/nono [-f] [path]`

### `/changelog`
Append a terse entry to `CHANGELOG.md` from a source file, a branch diff, or freetext instructions.
- **Input:** `<path-to-source-changelog> | "branch <name>" | "<freetext instructions>"`

## Features

- Terse, report-driven outputs (`myreports/`) for review/cleanup/security skills
- Stamping skills (`devcontainer`, `nono`) copy bundled templates into a target dir, with `-f` to overwrite
- No automatic git commits or destructive actions

## Installation

```
/plugin install dev-essentials@skillhub
```
