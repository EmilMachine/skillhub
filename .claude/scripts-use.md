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

## Sources
- [Official Docs](https://code.claude.com/docs/en/skills)
- [Practical Guide 2026](https://dev.to/muhammad_moeed/claude-code-skills-a-practical-guide-for-2026-3f6p)
