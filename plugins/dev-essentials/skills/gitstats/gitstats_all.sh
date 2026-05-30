#!/usr/bin/env bash
# gitstats_all.sh — unified git contributor/file stats
#
# Usage:
#   gitstats_all.sh                    # contributors ranked by lines changed (default)
#   gitstats_all.sh LINES|FILES|LAST   # contributors ranked by chosen column
#   gitstats_all.sh <partial-name>     # top files for a contributor (prefix match)
#   gitstats_all.sh <relative-path>    # contributor breakdown for a specific file

cd "$(git rev-parse --show-toplevel)" || exit 1

tab=$'\t'
arg="${1:-LINES}"
upper="${arg^^}"

# ── 1. Sort flag ──────────────────────────────────────────────────────────────
if [[ "$upper" == "LINES" || "$upper" == "FILES" || "$upper" == "LAST" ]]; then
  case "$upper" in
    LINES) sort_key="-k1 -rn" ;;
    FILES) sort_key="-k2 -rn" ;;
    LAST)  sort_key="-k3 -r"  ;;
  esac

  {
    printf "AUTHOR\tLINES\tFILES\tLAST\n"

    git log --format='%aN' | sort -u | while IFS= read -r author; do
      last=$(git log --author="$author" --format="%ad" --date=short -1)
      git log --author="$author" --pretty=tformat: --numstat | awk \
        -v author="$author" -v last="$last" '
        NF==3 { added+=$1; removed+=$2; files++ }
        END { print (added+removed) "\t" files "\t" last "\t" author }
      '
    done | sort -t"$tab" $sort_key | awk -F'\t' '{ print $4 "\t" $1 "\t" $2 "\t" $3 }'

  } | column -t -s$'\t' | awk '
    NR == 1 { print; sep = $0; gsub(/[^ ]/, "-", sep); print sep; next }
    { print }
  '
  exit 0
fi

# ── 2. Author prefix match ────────────────────────────────────────────────────
mapfile -t matches < <(git log --format='%aN' | sort -u | grep -i "^$arg")

author=""
if [ ${#matches[@]} -eq 1 ]; then
  author="${matches[0]}"
elif [ ${#matches[@]} -gt 1 ]; then
  # Prefer exact match (case-insensitive) over ambiguous prefix
  for m in "${matches[@]}"; do
    [[ "${m,,}" == "${arg,,}" ]] && author="$m" && break
  done
  if [ -z "$author" ]; then
    echo "Multiple contributors match '$arg' (prefix), please be more specific:" >&2
    printf '  %s\n' "${matches[@]}" >&2
    exit 1
  fi
fi

if [ -n "$author" ]; then
  escaped=$(printf '%s' "$author" | sed 's/[[\.*^$()+?{|]/\\&/g')

  echo "Contributor: $author"
  echo ""

  {
    printf "FILE\tLINES\n"

    git log --author="$escaped" --pretty=tformat: --numstat | awk '
      NF==3 { lines[$3] += $1 + $2 }
      END { for (f in lines) print lines[f] "\t" f }
    ' | sort -rn | head -10 | awk -F'\t' '{ print $2 "\t" $1 }'

  } | column -t -s$'\t' | awk '
    NR == 1 { print; sep = $0; gsub(/[^ ]/, "-", sep); print sep; next }
    { print }
  '
  exit 0
fi

# ── 3. File path ──────────────────────────────────────────────────────────────
file="$arg"
count=$(git log --oneline -- "$file" | wc -l | tr -d ' ')
if [ "$count" -eq 0 ]; then
  echo "No git history found for: $file" >&2
  echo "Hint: not a sort flag, no author prefix matches, and no git history for this path." >&2
  exit 1
fi

echo "File: $file"
echo ""

{
  printf "AUTHOR\tLINES\tCOMMITS\tLAST\n"

  git log --format='%aN' -- "$file" | sort -u | while IFS= read -r author; do
    escaped=$(printf '%s' "$author" | sed 's/[[\.*^$()+?{|]/\\&/g')
    last=$(git log --author="$escaped" --format="%ad" --date=short -1 -- "$file")
    commits=$(git log --author="$escaped" --oneline -- "$file" | wc -l | tr -d ' ')
    git log --author="$escaped" --pretty=tformat: --numstat -- "$file" | awk \
      -v author="$author" -v last="$last" -v commits="$commits" '
      NF==3 { lines += $1 + $2 }
      END { print (lines+0) "\t" commits "\t" last "\t" author }
    '
  done | sort -rn | awk -F'\t' '{ print $4 "\t" $1 "\t" $2 "\t" $3 }'

} | column -t -s$'\t' | awk '
  NR == 1 { print; sep = $0; gsub(/[^ ]/, "-", sep); print sep; next }
  { print }
'
