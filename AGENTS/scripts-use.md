# Using Scripts in Claude Code Skills

## Structure
- **Required:** `SKILL.md` (YAML frontmatter + markdown body)
- **Optional:** `.py`, `.sh`, templates, helpers in same directory

## Methods

**1. Bash tool reference**
```markdown
allowed-tools: Bash(bash *myscript.sh*)
```
Add to YAML frontmatter to auto-approve specific Bash invocations (no permission prompts). Use command patterns — not bare `Bash` — to express intent and limit blast radius:
- `Bash(bash *setup.sh*)` — only this script
- `Bash(git fetch*)` — only git fetch
- `Bash(bash *), Read` — CSV for multiple tools

**Caveats:**
- Restriction of unlisted tools is not currently enforced — treat as an approval hint, not a security boundary ([#18837](https://github.com/anthropics/claude-code/issues/18837))
- The built-in SKILL.md validator incorrectly flags `allowed-tools` as unsupported — known false positive ([#25380](https://github.com/anthropics/claude-code/issues/25380))

**UX Tip — Permission prompts:**
Add a "Permission note" after the YAML frontmatter to explain why the skill needs elevated permissions and how users can configure their settings to skip prompts:
```markdown
**Permission note:** This skill runs Bash to create issues. You may be prompted to allow Bash execution. To skip future prompts, add to `.claude/settings.json`: `"Bash(bash *create_issue.sh*)"`
```
This improves discoverability and helps users understand the permission model.

**2. Shell snippets**
```markdown
!`command` - runs before Claude sees prompt
```

**3. Bundle in skill folder**
- Scripts live alongside SKILL.md
- Lazy-loaded only when explicitly needed

## Best Practices
- Default to markdown (easier maintenance)
- Use scripts only for deterministic work
- Performance: dozens of skills OK (on-demand loading)

## Script path resolution

**Never use `$0` or `$(dirname "$0")` in SKILL.md instructions.** When Claude runs a Bash command, `$0` is the shell interpreter name (`bash`), not the SKILL.md path — so `dirname "$0"` resolves to `.`, not the skill directory.

**Correct pattern:** The harness prepends a `Base directory for this skill: <path>` header to every skill before Claude reads it. Instruct Claude to use that path:

```markdown
**Script path:** The harness injects `Base directory for this skill: <path>` at the top of these
instructions — use that path as `BASE_DIR` for all script references below.
```

Then reference scripts as `"<BASE_DIR>/script.sh"` (Claude substitutes the actual path at runtime).

**Preventing path truncation:** Claude sometimes drops the last segment of BASE_DIR (e.g. resolves `.../skills/gitstats/script.sh` as `.../skills/script.sh`). Add an explicit note in SKILL.md:
```markdown
BASE_DIR already ends in `.../skills/<skillname>` — do not trim or modify it.
```
When the path is wrong, Claude falls back to `ls` exploration; each `ls` is not auto-approved and generates a prompt.

**Run scripts directly — no existence guard:** Prefer `bash "<BASE_DIR>/script.sh" $ARGUMENTS` over a two-step verify-then-run pattern. Fewer Bash calls = fewer prompts. Pair with `allowed-tools: Bash(bash *script.sh*)` so the direct invocation auto-approves. Keep the glob in sync with the command form — `Bash(bash *script.sh*)` only matches commands that start with `bash`.

## Passing LLM-generated content to scripts

**Multi-line body → stdin via quoted heredoc** (prevents variable expansion):
```bash
ISSUE_TITLE="<TITLE>" bash "<BASE_DIR>/script.sh" <<'EOF'
<multi-line body>
EOF
```

**Single-line strings with special chars → env var, not positional arg**
- Positional args break if the value contains `"` or unbalanced quotes
- Env var: `ISSUE_TITLE="<TITLE>" bash "<BASE_DIR>/script.sh"` → script reads `$ISSUE_TITLE`

**Build JSON in script → `jq --arg`** (handles all escaping, no injection risk):
```bash
jq -n --arg title "$TITLE" --arg body "$BODY" \
  '{"title":$title,"body":$body}'
```

**Parse JSON → `jq -r`**, not python3: `jq -r '.html_url'`

**URL-encode → `jq @uri`**:
```bash
jq -rn --arg t "$TITLE" '"title=" + ($t|@uri)'
```

**`head -n -1` is GNU-only** — use `sed '$d'` to strip last line on macOS/BSD.

## Sources
- [Official Docs](https://code.claude.com/docs/en/skills)
- [Practical Guide 2026](https://dev.to/muhammad_moeed/claude-code-skills-a-practical-guide-for-2026-3f6p)
