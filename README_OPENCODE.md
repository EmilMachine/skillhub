# skillhub for OpenCode

How to install skills for OpenCode

## Via .claude/skills (zero-config if using Claude Code too)

OpenCode also reads `.claude/skills/*/SKILL.md`. If you already have Claude Code skills installed, OpenCode picks them up automatically.

## Global Install (all projects - manual)

This repo ships `.opencode/skills/` with all skills pre-wired — clone once, then point your global or project config at it.


```bash
git clone https://github.com/EmilMachine/skillhub ~/.local/share/skillhub

# Symlink all skills from all plugins into your global opencode config
mkdir -p ~/.opencode/skills
for plugin in ~/.local/share/skillhub/plugins/*/; do
  for skill in "$plugin"skills/*/; do
    ln -s "$skill" ~/.opencode/skills/
  done
done
```

Skills are discovered on-demand — OpenCode sees available names and loads content when needed.

## Project-Local Install

```bash
# Run from your project root (repo must already be cloned as above)
mkdir -p .opencode/skills
for plugin in ~/.local/share/skillhub/plugins/*/; do
  for skill in "$plugin"skills/*/; do
    ln -s "$skill" .opencode/skills/
  done
done
```

Or selectively:

```bash
ln -s ~/.local/share/skillhub/plugins/md3step/skills/mdresearch .opencode/skills/mdresearch
ln -s ~/.local/share/skillhub/plugins/md3step/skills/mdplan     .opencode/skills/mdplan
```


## Update

Run the built-in skill (handles pull + new symlinks automatically):

```
/skillhub-update
```

Or manually:

```bash
cd ~/.local/share/skillhub && git pull

# Re-link any new skills added since install
for plugin in ~/.local/share/skillhub/plugins/*/; do
  for skill in "$plugin"skills/*/; do
    ln -sfn "$skill" ~/.opencode/skills/
  done
done
```

## Project Rules (AGENTS.md)

For lightweight integration without symlinking:

```bash
# Append a skill's instructions to your project rules
cat ~/.local/share/skillhub/plugins/md3step/skills/mdresearch/SKILL.md >> .opencode/AGENTS.md

# Or global rules
cat ~/.local/share/skillhub/plugins/md3step/skills/mdresearch/SKILL.md >> ~/.config/opencode/AGENTS.md
```

## Resources

- [OpenCode Skills docs](https://opencode.ai/docs/skills/)
- [OpenCode Agents docs](https://opencode.ai/docs/agents/)
- [OpenCode Config](https://opencode.ai/docs/config/)
- [awesome-opencode](https://github.com/awesome-opencode/awesome-opencode)
