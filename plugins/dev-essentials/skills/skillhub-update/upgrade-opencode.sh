#!/usr/bin/env bash
# upgrade-opencode.sh — OpenCode adapter for skillhub-update.
# Sourced by upgrade.sh after lib.sh. Defines run_upgrade().
#
# Updates skillhub by running git pull on ~/.local/share/skillhub and
# creates symlinks in ~/.opencode/skills/ for any new skills.

run_upgrade() {
  local SKILLHUB_DIR="${SKILLHUB_DIR:-$HOME/.local/share/skillhub}"
  local SKILLS_LINK_DIR="$HOME/.opencode/skills"

  echo "🔍 skillhub update check  (OpenCode)"
  echo "$DIVIDER"

  # ── Check repo is cloned ──────────────────────────────────────────────────────
  if [ ! -d "$SKILLHUB_DIR/.git" ]; then
    echo "❌ skillhub not found at $SKILLHUB_DIR"
    echo ""
    echo "Install first:"
    echo "  git clone https://github.com/EmilMachine/skillhub $SKILLHUB_DIR"
    echo ""
    echo "Then symlink all skills:"
    echo "  mkdir -p ~/.opencode/skills"
    echo "  for plugin in $SKILLHUB_DIR/plugins/*/; do"
    echo "    for skill in \"\$plugin\"skills/*/; do"
    echo "      ln -s \"\$skill\" ~/.opencode/skills/"
    echo "    done"
    echo "  done"
    exit 1
  fi

  # ── git pull ──────────────────────────────────────────────────────────────────
  echo "📦 Pulling latest skillhub..."
  git -C "$SKILLHUB_DIR" pull
  echo ""

  # ── Sync symlinks ─────────────────────────────────────────────────────────────
  mkdir -p "$SKILLS_LINK_DIR"

  local new=0 existing=0
  for skill_dir in "$SKILLHUB_DIR"/plugins/*/skills/*/; do
    [ -d "$skill_dir" ] || continue
    local name
    name=$(basename "$skill_dir")
    local target="$SKILLS_LINK_DIR/$name"
    if [ -L "$target" ]; then
      existing=$((existing + 1))
    else
      ln -s "$skill_dir" "$target"
      printf "  + linked %s\n" "$name"
      new=$((new + 1))
    fi
  done

  echo "$DIVIDER"
  echo "✅ $existing skills already linked, $new new symlink(s) created."
}
