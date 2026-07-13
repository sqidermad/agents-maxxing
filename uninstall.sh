#!/usr/bin/env bash
# uninstall.sh — remove symlinks created by install.sh.
#
# Usage:
#   ./uninstall.sh           # remove from every tool found on this machine
#   ./uninstall.sh --cursor  # only Cursor
#   ./uninstall.sh --codex   # only Codex
#   ./uninstall.sh --claude  # only Claude Code
#   ./uninstall.sh --dry-run # show what would happen
#
# Only removes symlinks that point into THIS repo. Won't touch real
# directories, vendor-shipped skills, or symlinks pointing elsewhere.
# Does not delete the agents-maxxing repo itself.
#
# Backups made by install.sh (<name>.backup-<timestamp>) are NOT
# restored automatically — move them back by hand if you want the
# pre-install skill back: mv <name>.backup-<timestamp> <name>

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

CURSOR_SKILLS="$HOME/.cursor/skills-cursor"
CODEX_SKILLS="$HOME/.codex/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"

UNINSTALL_CURSOR=false
UNINSTALL_CODEX=false
UNINSTALL_CLAUDE=false
SELECTED=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --cursor)  SELECTED=true; UNINSTALL_CURSOR=true ;;
    --codex)   SELECTED=true; UNINSTALL_CODEX=true ;;
    --claude)  SELECTED=true; UNINSTALL_CLAUDE=true ;;
    --all)     SELECTED=true; UNINSTALL_CURSOR=true; UNINSTALL_CODEX=true; UNINSTALL_CLAUDE=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown flag: $arg" >&2
      exit 2
      ;;
  esac
done

if ! $SELECTED; then
  UNINSTALL_CURSOR=true
  UNINSTALL_CODEX=true
  UNINSTALL_CLAUDE=true
fi

# Run a command directly (no eval — arguments are passed as-is, so paths
# with spaces or quotes can't be re-interpreted by the shell).
run() {
  if $DRY_RUN; then
    printf '  -'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
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

  # Remove links for current skills, plus any dangling links that point
  # into this repo (left behind by renamed or deleted skills).
  local entry dest name
  for entry in "$target_root"/*; do
    [[ -L "$entry" ]] || continue
    dest="$(readlink "$entry")"
    name="$(basename "$entry")"
    if [[ "$dest" == "$SKILLS_DIR"/* ]]; then
      echo "  - $name"
      run rm "$entry"
    fi
  done

  for skill_path in "$SKILLS_DIR"/*; do
    [[ -d "$skill_path" ]] || continue
    local skill_name target
    skill_name="$(basename "$skill_path")"
    target="$target_root/$skill_name"
    if [[ -e "$target" && ! -L "$target" ]]; then
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

if $UNINSTALL_CLAUDE; then
  unlink_from "$CLAUDE_SKILLS" "Claude Code"
fi

if $DRY_RUN; then
  echo
  echo "(dry run — no changes made)"
else
  echo
  echo "done. backups (if any) remain at <name>.backup-<timestamp>;"
  echo "restore one with: mv <name>.backup-<timestamp> <name>"
fi
