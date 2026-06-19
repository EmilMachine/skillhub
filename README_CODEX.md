# skillhub for OpenAI Codex

Codex uses the same `skills/<name>/SKILL.md` convention as Claude Code. Each plugin in this repo ships both `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` — no adaptation needed.

## Install via Marketplace

Run from your terminal (not inside the Codex chat):

```bash
# 1. Register the skillhub marketplace (once)
codex plugin marketplace add EmilMachine/skillhub --ref main --sparse .agents/plugins

# 2. Install plugins
codex plugin add md3step --marketplace skillhub
codex plugin add dev-essentials --marketplace skillhub
```

Or in the Codex app: **Plugins → Marketplace → Add Source → GitHub: `EmilMachine/skillhub`**

## Invoke Skills

Skills are invoked inside the Codex chat using `@skill-name`:

```
@mdresearch
@mdplan
```

Or just describe what you want — Codex selects the matching skill automatically.

## Update Installed Plugins

```bash
# Refresh marketplace metadata and reinstall all plugins to latest
codex plugin marketplace upgrade skillhub
codex plugin remove dev-essentials@skillhub && codex plugin add dev-essentials --marketplace skillhub
codex plugin remove md3step@skillhub        && codex plugin add md3step --marketplace skillhub
```

Or use the `@skillhub-update` skill inside Codex to do this automatically.

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

- [Codex Plugins docs](https://developers.openai.com/codex/plugins)
- [Codex Build Plugins docs](https://developers.openai.com/codex/build-plugins)
- [openai/skills catalog](https://github.com/openai/skills)
- [AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md)
