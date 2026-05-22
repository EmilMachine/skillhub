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

## Passing LLM-generated content to scripts

**Multi-line body → stdin via quoted heredoc** (prevents variable expansion):
```bash
ISSUE_TITLE="<TITLE>" bash "$0/script.sh" <<'EOF'
<multi-line body>
EOF
```

**Single-line strings with special chars → env var, not positional arg**
- Positional args break if the value contains `"` or unbalanced quotes
- Env var: `ISSUE_TITLE="<TITLE>" bash "$0/script.sh"` → script reads `$ISSUE_TITLE`

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
