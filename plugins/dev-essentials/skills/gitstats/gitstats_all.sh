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
upper=$(printf '%s' "$arg" | tr '[:lower:]' '[:upper:]')

# ── 1. Sort flag ──────────────────────────────────────────────────────────────
if [[ "$upper" == "LINES" || "$upper" == "FILES" || "$upper" == "LAST" ]]; then
  case "$upper" in
    LINES) sort_key="-k1 -rn" ;;
    FILES) sort_key="-k2 -rn" ;;
    LAST)  sort_key="-k3 -r"  ;;
  esac

  {
    printf "AUTHOR\tLINES\tFILES\tLAST\n"

    git log --format='%aN%x09%ad' --date=short --numstat | awk '
      BEGIN { FS = "\t" }
      NF == 2 && $2 ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ {
        cur = $1
        if (!(cur in last)) last[cur] = $2
        next
      }
      NF == 3 && $1 ~ /^[0-9-]+$/ && $2 ~ /^[0-9-]+$/ {
        if ($1 != "-") lines[cur] += $1
        if ($2 != "-") lines[cur] += $2
        files[cur]++
      }
      END {
        for (a in files) print (lines[a]+0) "\t" files[a] "\t" last[a] "\t" a
      }
    ' | sort -t"$tab" $sort_key | awk -F'\t' '{ print $4 "\t" $1 "\t" $2 "\t" $3 }'

  } | column -t -s$'\t' | awk '
    NR == 1 { print; sep = $0; gsub(/[^ ]/, "-", sep); print sep; next }
    { print }
  '
  exit 0
fi

# ── 2. Author prefix match ────────────────────────────────────────────────────
matches=()
while IFS= read -r line; do
  matches=("${matches[@]}" "$line")
done < <(git log --format='%aN' | sort -u | grep -i "^$arg")

author=""
if [ ${#matches[@]} -eq 1 ]; then
  author="${matches[0]}"
elif [ ${#matches[@]} -gt 1 ]; then
  # Prefer exact match (case-insensitive) over ambiguous prefix
  for m in "${matches[@]}"; do
    [[ "$(printf '%s' "$m" | tr '[:upper:]' '[:lower:]')" == "$(printf '%s' "$arg" | tr '[:upper:]' '[:lower:]')" ]] && author="$m" && break
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
