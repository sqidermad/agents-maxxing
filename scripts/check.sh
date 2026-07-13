#!/usr/bin/env bash
# check.sh — structural validation for the skills in this repo.
#
# Usage:
#   scripts/check.sh           run all checks (exit 1 on any FAIL)
#   scripts/check.sh --table   print the README token-table rows and exit
#
# Checks:
#   - every skills/<dir>/ contains a SKILL.md with YAML frontmatter
#   - frontmatter `name:` exists, equals the folder name, and is a valid
#     skill name (lowercase letters, digits, hyphens — per the Agent
#     Skills spec, no underscores)
#   - frontmatter `description:` exists, is non-empty, and is <= 1024
#     characters
#   - body stays at or under the 200-line ceiling (warning only)
#   - the README token table matches reality (regenerate rows with
#     `scripts/check.sh --table` when a skill changes)
#   - relative markdown links in README.md and docs/ resolve to real files

set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LINE_CEILING=200
DESC_CHAR_CAP=1024

# Print the description text of a SKILL.md (handles `description: >-`
# block scalars).
description_of() {
  awk '
    /^---$/ { fence++; next }
    fence >= 2 { exit }
    fence == 1 && /^description:/ {
      d = 1
      line = $0
      sub(/^description:[[:space:]]*(>-|>|\|-?)?[[:space:]]*/, "", line)
      if (line != "") print line
      next
    }
    fence == 1 && d && /^[[:space:]]/ { sub(/^[[:space:]]+/, ""); print; next }
    fence == 1 && d { d = 0 }
  ' "$1"
}

table_row() {
  local dir="$1" name words lines
  name="$(basename "$dir")"
  words="$(description_of "$dir/SKILL.md" | wc -w | tr -d ' ')"
  lines="$(wc -l < "$dir/SKILL.md" | tr -d ' ')"
  printf '| `%s` | %s words | %s lines |\n' "$name" "$words" "$lines"
}

if [[ "${1:-}" == "--table" ]]; then
  for dir in skills/*/; do
    table_row "${dir%/}"
  done
  exit 0
fi

FAIL=0
err()  { echo "FAIL: $*"; FAIL=1; }
wrn()  { echo "warn: $*"; }

for dir in skills/*/; do
  dir="${dir%/}"
  name="$(basename "$dir")"
  f="$dir/SKILL.md"

  if [[ ! -f "$f" ]]; then
    err "$name: missing SKILL.md"
    continue
  fi

  if [[ "$(head -1 "$f")" != "---" ]]; then
    err "$name: SKILL.md must start with '---' frontmatter"
    continue
  fi
  if [[ "$(awk '/^---$/{n++} END{print n}' "$f")" -lt 2 ]]; then
    err "$name: frontmatter never closed with '---'"
    continue
  fi

  fm_name="$(awk '/^---$/{n++; next} n==1' "$f" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
  if [[ -z "$fm_name" ]]; then
    err "$name: frontmatter missing 'name:'"
  elif [[ "$fm_name" != "$name" ]]; then
    err "$name: frontmatter name '$fm_name' does not equal the folder name"
  fi
  if [[ ! "$name" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
    err "$name: invalid skill name (allowed: lowercase letters, digits, hyphens)"
  fi

  desc="$(description_of "$f")"
  if [[ -z "$desc" ]]; then
    err "$name: frontmatter missing or empty 'description:'"
  else
    chars="$(printf '%s' "$desc" | wc -c | tr -d ' ')"
    if (( chars > DESC_CHAR_CAP )); then
      err "$name: description is $chars chars (cap: $DESC_CHAR_CAP)"
    fi
  fi

  lines="$(wc -l < "$f" | tr -d ' ')"
  if (( lines > LINE_CEILING )); then
    wrn "$name: body is $lines lines (ceiling: $LINE_CEILING)"
  fi
done

# README token table must match reality.
for dir in skills/*/; do
  row="$(table_row "${dir%/}")"
  if ! grep -qF "$row" README.md; then
    name="$(basename "${dir%/}")"
    err "README token table row for '$name' is stale — expected: $row (regenerate with scripts/check.sh --table)"
  fi
done

# ...and must not keep rows for skills that no longer exist (a rename
# or deletion would otherwise leave a stale row that passes silently).
while IFS= read -r tname; do
  [[ -z "$tname" ]] && continue
  if [[ ! -d "skills/$tname" ]]; then
    err "README token table has a row for '$tname' but skills/$tname does not exist"
  fi
done < <(grep -oE '^\| `[a-z0-9-]+` \| [0-9]+ words \| [0-9]+ lines \|' README.md \
         | sed -E 's/^\| `([a-z0-9-]+)`.*/\1/')

# Relative markdown links must resolve — in the README, docs, and the
# skill bodies themselves (a skill may link to its references/ files).
for f in README.md docs/*.md skills/*/SKILL.md skills/*/references/*.md; do
  [[ -e "$f" ]] || continue
  base="$(dirname "$f")"
  links="$(grep -oE '\[[^]]*\]\([^)]+\)' "$f" | sed -E 's/.*\(([^)]+)\)$/\1/' || true)"
  while IFS= read -r link; do
    [[ -z "$link" ]] && continue
    case "$link" in
      http://*|https://*|mailto:*|\#*) continue ;;
    esac
    path="${link%%#*}"
    if [[ ! -e "$base/$path" ]]; then
      err "$f: broken relative link '$link'"
    fi
  done <<< "$links"
done

if (( FAIL )); then
  echo
  echo "check: FAILED"
  exit 1
fi
echo "check: OK"
