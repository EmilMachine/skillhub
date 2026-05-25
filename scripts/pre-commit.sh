#!/usr/bin/env bash
# scripts/pre-commit.sh — skillhub plugin consistency checker + auto-fixer
#
# Strategy (Option C): fix what's mechanical on disk, fail if anything changed
# so the developer reviews. Re-commit after staging the fixes — second run passes.
#
# Install:
#   ln -sf "$(git rev-parse --show-toplevel)/scripts/pre-commit.sh" .git/hooks/pre-commit
#   chmod +x .git/hooks/pre-commit
#
# Bash 3.2 compatible (macOS default).
set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

ERRORS=()   # structural problems that require human intervention
FIXED=()    # things this script auto-corrected on disk

err()   { ERRORS+=("$*"); }
fixed() { FIXED+=("$*"); }

# ── Require jq ─────────────────────────────────────────────────────────────────
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ Pre-commit: jq not found — install with: brew install jq" >&2
  exit 1
fi

MARKETPLACE=".claude-plugin/marketplace.json"

# ══════════════════════════════════════════════════════════════════════════════
# Phase 1 — Validate .claude-plugin ↔ plugins/  (never auto-fixed; fail fast)
# ══════════════════════════════════════════════════════════════════════════════

if [ ! -f "$MARKETPLACE" ]; then
  echo "❌ Pre-commit: missing $MARKETPLACE — cannot proceed" >&2
  exit 1
fi

if ! jq empty "$MARKETPLACE" 2>/dev/null; then
  echo "❌ Pre-commit: $MARKETPLACE is invalid JSON" >&2
  exit 1
fi

# 1a. Every plugin listed in marketplace.json has a plugins/<name>/ directory
while IFS= read -r name; do
  [ -d "plugins/$name" ] || err "marketplace.json lists '$name' but plugins/$name/ does not exist"
done < <(jq -r '.plugins[].name' "$MARKETPLACE")

# 1b. Marketplace version matches each plugin's own plugin.json version
while IFS=$'\t' read -r name mkt_version; do
  pjson="plugins/$name/.claude-plugin/plugin.json"
  if [ ! -f "$pjson" ]; then
    err "plugins/$name/.claude-plugin/plugin.json missing"
    continue
  fi
  if ! jq empty "$pjson" 2>/dev/null; then
    err "$pjson is invalid JSON"
    continue
  fi
  actual=$(jq -r '.version' "$pjson")
  [ "$actual" = "$mkt_version" ] || \
    err "version mismatch: marketplace.json says $name@$mkt_version, plugin.json says $actual"
done < <(jq -r '.plugins[] | [.name, .version] | @tsv' "$MARKETPLACE")

# 1c. Each plugin's skills[] entries point to existing directories
while IFS= read -r name; do
  pjson="plugins/$name/.claude-plugin/plugin.json"
  [ -f "$pjson" ] || continue
  while IFS= read -r skill_path; do
    skill_path="${skill_path#./}"   # strip leading ./
    full="plugins/$name/$skill_path"
    [ -d "$full" ] || err "plugin '$name': skills entry '$skill_path' → $full/ does not exist"
  done < <(jq -r '.skills[]' "$pjson")
done < <(jq -r '.plugins[].name' "$MARKETPLACE")

# Bail before auto-fixing if there are structural errors
if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "❌ Pre-commit FAILED — .claude-plugin is inconsistent (fix by hand):"
  for e in "${ERRORS[@]}"; do echo "   • $e"; done
  echo ""
  exit 1
fi

# ══════════════════════════════════════════════════════════════════════════════
# Phase 2 — Auto-fix: .codex-plugin/marketplace.json  (exact copy of .claude-plugin)
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p ".codex-plugin"
CODEX_MKT=".codex-plugin/marketplace.json"

if [ ! -f "$CODEX_MKT" ] || ! diff -q "$MARKETPLACE" "$CODEX_MKT" >/dev/null 2>&1; then
  cp "$MARKETPLACE" "$CODEX_MKT"
  fixed "synced $CODEX_MKT ← $MARKETPLACE"
fi

# ══════════════════════════════════════════════════════════════════════════════
# Phase 3 — Auto-fix: .codex-plugin/plugin.json per plugin  (exact copy)
# ══════════════════════════════════════════════════════════════════════════════

while IFS= read -r name; do
  src="plugins/$name/.claude-plugin/plugin.json"
  dst="plugins/$name/.codex-plugin/plugin.json"
  [ -f "$src" ] || continue
  mkdir -p "plugins/$name/.codex-plugin"
  if [ ! -f "$dst" ] || ! diff -q "$src" "$dst" >/dev/null 2>&1; then
    cp "$src" "$dst"
    fixed "synced $dst ← $src"
  fi
done < <(jq -r '.plugins[].name' "$MARKETPLACE")

# ══════════════════════════════════════════════════════════════════════════════
# Phase 4 — Auto-fix: .opencode/skills/ symlinks
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p ".opencode/skills"

# Build newline-separated list of expected skill names (bash 3.2: no declare -A)
EXPECTED_SKILLS=""
while IFS= read -r name; do
  pjson="plugins/$name/.claude-plugin/plugin.json"
  [ -f "$pjson" ] || continue
  while IFS= read -r skill_path; do
    skill_name=$(basename "$skill_path")
    EXPECTED_SKILLS="$EXPECTED_SKILLS
$skill_name"
  done < <(jq -r '.skills[]' "$pjson")
done < <(jq -r '.plugins[].name' "$MARKETPLACE")

# 4a. Create / fix symlinks for every skill in every plugin
while IFS= read -r name; do
  pjson="plugins/$name/.claude-plugin/plugin.json"
  [ -f "$pjson" ] || continue
  while IFS= read -r skill_path; do
    skill_name=$(basename "$skill_path")
    link=".opencode/skills/$skill_name"
    expected_target="../../plugins/$name/skills/$skill_name"

    if [ -L "$link" ]; then
      actual_target=$(readlink "$link")
      if [ "$actual_target" != "$expected_target" ]; then
        rm "$link"
        ln -s "$expected_target" "$link"
        fixed "updated symlink $link → $expected_target  (was: $actual_target)"
      fi
    elif [ -e "$link" ]; then
      err "$link exists as a real file/dir — expected a symlink; remove it manually"
    else
      ln -s "$expected_target" "$link"
      fixed "created symlink $link → $expected_target"
    fi
  done < <(jq -r '.skills[]' "$pjson")
done < <(jq -r '.plugins[].name' "$MARKETPLACE")

# 4b. Remove stale symlinks (skill no longer listed in any plugin)
while IFS= read -r link; do
  skill_name=$(basename "$link")
  if ! printf '%s' "$EXPECTED_SKILLS" | grep -qx "$skill_name"; then
    rm "$link"
    fixed "removed stale symlink $link"
  fi
done < <(find ".opencode/skills" -maxdepth 1 -type l 2>/dev/null)

# ══════════════════════════════════════════════════════════════════════════════
# Phase 5 — Report
# ══════════════════════════════════════════════════════════════════════════════

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "❌ Pre-commit FAILED:"
  for e in "${ERRORS[@]}"; do echo "   • $e"; done
  echo ""
  exit 1
fi

if [ ${#FIXED[@]} -gt 0 ]; then
  echo ""
  echo "🔧 Pre-commit auto-fixed ${#FIXED[@]} issue(s) — review and re-commit:"
  for f in "${FIXED[@]}"; do echo "   • $f"; done
  echo ""
  echo "   git add -A && git commit"
  echo ""
  exit 1
fi

echo "✅ Pre-commit: all plugin consistency checks passed."
exit 0
