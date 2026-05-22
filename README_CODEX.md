# skillhub for OpenAI Codex

Codex uses the same `skills/<name>/SKILL.md` convention as Claude Code. Each plugin in this repo ships both `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` — no adaptation needed.

## Install via Marketplace

```sh
# In Codex CLI
$plugin-marketplace add https://github.com/EmilMachine/skillhub
$plugin install md3step
```

Or in the Codex app: **Plugins → Marketplace → Add Source → GitHub: `EmilMachine/skillhub`**

## Invoke Skills

```sh
# Explicit invocation
$mdresearch
$mdplan

# Or let Codex select based on your prompt
```

## Manual Skill Copy (no marketplace)

```bash
# Clone repo
git clone https://github.com/EmilMachine/skillhub ~/.local/share/codex/skillhub

# Symlink a skill into your global skills dir
mkdir -p ~/.codex/skills
ln -s ~/.local/share/codex/skillhub/plugins/md3step/skills/mdresearch ~/.codex/skills/mdresearch
ln -s ~/.local/share/codex/skillhub/plugins/md3step/skills/mdplan    ~/.codex/skills/mdplan
```

## Project-Local Skills (AGENTS.md)

For project-specific guidance without full plugin install:

```bash
# Copy skill content into AGENTS.md
cat plugins/md3step/skills/mdresearch/SKILL.md >> AGENTS.md
```

Codex reads `AGENTS.md` before starting work, layering global → project-local.

## Resources

- [Codex Skills docs](https://developers.openai.com/codex/skills)
- [Codex Plugins docs](https://developers.openai.com/codex/plugins)
- [openai/skills catalog](https://github.com/openai/skills)
- [AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md)
