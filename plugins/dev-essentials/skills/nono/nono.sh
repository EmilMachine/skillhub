#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORCE=false
TARGET="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f) FORCE=true; shift ;;
    *)  TARGET="$1"; shift ;;
  esac
done

TARGET="$(realpath "$TARGET")"
DEST="$TARGET/.nono"

if [[ -d "$DEST" ]] && [[ "$FORCE" == false ]]; then
  echo "❌ .nono already exists at $DEST"
  echo "   Use -f to overwrite."
  exit 1
fi

if [[ "$FORCE" == true ]]; then
  cp -rf "$SCRIPT_DIR/.nono" "$TARGET/"
else
  cp -r "$SCRIPT_DIR/.nono" "$TARGET/"
fi
echo "✅ .nono copied to $DEST"
echo ""
echo "Files:"
find "$DEST" -type f | sed "s|$TARGET/||"
