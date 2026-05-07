#!/usr/bin/env bash
# uninstall.sh — remove symlinks created by install.sh.
#
# Usage:
#   ./uninstall.sh           # remove from both Cursor and Codex (default)
#   ./uninstall.sh --cursor  # only Cursor
#   ./uninstall.sh --codex   # only Codex
#   ./uninstall.sh --dry-run # show what would happen
#
# Only removes symlinks that point into THIS repo. Won't touch real
# directories, vendor-shipped skills, or symlinks pointing elsewhere.
# Does not delete the agents-maxxing repo itself.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

CURSOR_SKILLS="$HOME/.cursor/skills-cursor"
CODEX_SKILLS="$HOME/.codex/skills"

UNINSTALL_CURSOR=true
UNINSTALL_CODEX=true
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --cursor)  UNINSTALL_CURSOR=true; UNINSTALL_CODEX=false ;;
    --codex)   UNINSTALL_CURSOR=false; UNINSTALL_CODEX=true ;;
    --all)     UNINSTALL_CURSOR=true; UNINSTALL_CODEX=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown flag: $arg" >&2
      exit 2
      ;;
  esac
done

run() {
  if $DRY_RUN; then
    echo "  - $*"
  else
    eval "$*"
  fi
}

unlink_from() {
  local target_root="$1"
  local label="$2"

  if [[ ! -d "$target_root" ]]; then
    echo "skip $label: $target_root does not exist"
    return 0
  fi

  echo "→ uninstalling from $label ($target_root)"

  for skill_path in "$SKILLS_DIR"/*; do
    [[ -d "$skill_path" ]] || continue
    local skill_name
    skill_name="$(basename "$skill_path")"
    local target="$target_root/$skill_name"

    if [[ -L "$target" ]]; then
      local current_target
      current_target="$(readlink "$target")"
      if [[ "$current_target" == "$skill_path" ]]; then
        echo "  - $skill_name"
        run "rm '$target'"
      else
        echo "  ! $skill_name skipped (symlink points elsewhere: $current_target)"
      fi
    elif [[ -e "$target" ]]; then
      echo "  ! $skill_name skipped (real directory, not our symlink)"
    fi
  done
}

if $UNINSTALL_CURSOR; then
  unlink_from "$CURSOR_SKILLS" "Cursor"
fi

if $UNINSTALL_CODEX; then
  unlink_from "$CODEX_SKILLS" "Codex"
fi

if $DRY_RUN; then
  echo
  echo "(dry run — no changes made)"
else
  echo
  echo "done. backups (if any) remain at <name>.backup-<timestamp>."
fi
