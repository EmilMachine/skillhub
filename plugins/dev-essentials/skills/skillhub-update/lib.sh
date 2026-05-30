#!/usr/bin/env bash
# lib.sh — shared utilities for skillhub upgrade adapters.
# Sourced by upgrade.sh (and optionally by standalone adapter scripts).
# Do NOT run directly.

DIVIDER="────────────────────────────────────────────────"

# ── Version comparison ─────────────────────────────────────────────────────────
# Usage: _compare_versions <a> <b>
# Prints: lt | eq | gt
_compare_versions() {
  local a="$1" b="$2"
  [ "$a" = "$b" ] && { echo "eq"; return; }
  # Try sort -V (GNU coreutils / macOS 12+); pipefail catches BSD sort failure
  if lower=$(printf '%s\n%s' "$a" "$b" | sort -V 2>/dev/null | head -1); then
    [ "$lower" = "$a" ] && echo "lt" || echo "gt"
    return
  fi
  # Portable numeric fallback: compare major.minor.patch fields
  local a1 a2 a3 b1 b2 b3
  IFS='.' read -r a1 a2 a3 <<< "$a"; IFS='.' read -r b1 b2 b3 <<< "$b"
  a1=${a1:-0}; a2=${a2:-0}; a3=${a3:-0}
  b1=${b1:-0}; b2=${b2:-0}; b3=${b3:-0}
  if   (( a1 < b1 )) \
    || (( a1 == b1 && a2 < b2 )) \
    || (( a1 == b1 && a2 == b2 && a3 < b3 )); then echo "lt"
  elif (( a1 == b1 && a2 == b2 && a3 == b3 ));   then echo "eq"
  else                                                  echo "gt"
  fi
}

# ── Table printer ──────────────────────────────────────────────────────────────
# Usage: _print_table <tmpfile> [title]
# tmpfile columns (space-separated): plugin_key installed available STATUS marketplace
_print_table() {
  local tmpfile="$1"
  local title="${2:-Plugin upgrade check}"
  echo ""
  echo "🔍 $title"
  echo "$DIVIDER"
  while IFS=' ' read -r plugin_key installed available status marketplace; do
    case "$status" in
      OUTDATED)   printf "  %-32s %s → %-8s ⬆ outdated\n"       "$plugin_key" "$installed" "$available" ;;
      UP_TO_DATE) printf "  %-32s %s = %-8s ✅ up to date\n"    "$plugin_key" "$installed" "$available" ;;
      AHEAD)      printf "  %-32s %s > %-8s 🔼 ahead (dev)\n"   "$plugin_key" "$installed" "$available" ;;
      UNKNOWN)    printf "  %-32s %s → ?          ⚠️  unknown\n" "$plugin_key" "$installed" ;;
    esac
  done < "$tmpfile"
  echo "$DIVIDER"
}

# ── Count lines matching STATUS ────────────────────────────────────────────────
# Usage: _count_status <tmpfile> <STATUS>
# Prints the integer count.
_count_status() {
  local tmpfile="$1" target="$2" count=0
  while IFS=' ' read -r plugin_key installed available status marketplace; do
    [ "$status" = "$target" ] && count=$(( count + 1 )) || true
  done < "$tmpfile"
  echo "$count"
}
