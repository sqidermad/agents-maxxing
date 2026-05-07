#!/usr/bin/env bash
# install.sh — symlink agents-maxxing skills into Cursor and/or Codex.
#
# Usage:
#   ./install.sh             # install into both Cursor and Codex (default)
#   ./install.sh --cursor    # only Cursor
#   ./install.sh --codex     # only Codex
#   ./install.sh --all       # explicit both
#   ./install.sh --dry-run   # show what would happen without doing it
#
# Behaviour:
#   - For each skill in skills/, create a symlink at the target location.
#   - If the target already exists and is NOT already a symlink to this
#     repo, move it aside to <name>.backup-<timestamp> before linking.
#   - Skips Cursor/Codex if the parent skills folder doesn't exist.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

CURSOR_SKILLS="$HOME/.cursor/skills-cursor"
CODEX_SKILLS="$HOME/.codex/skills"

INSTALL_CURSOR=true
INSTALL_CODEX=true
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --cursor)  INSTALL_CURSOR=true; INSTALL_CODEX=false ;;
    --codex)   INSTALL_CURSOR=false; INSTALL_CODEX=true ;;
    --all)     INSTALL_CURSOR=true; INSTALL_CODEX=true ;;
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

stamp() { date +%Y%m%d-%H%M%S; }

run() {
  if $DRY_RUN; then
    echo "  + $*"
  else
    eval "$*"
  fi
}

link_into() {
  local target_root="$1"
  local label="$2"

  if [[ ! -d "$target_root" ]]; then
    echo "skip $label: $target_root does not exist (is the tool installed?)"
    return 0
  fi

  echo "→ installing into $label ($target_root)"

  for skill_path in "$SKILLS_DIR"/*; do
    [[ -d "$skill_path" ]] || continue
    local skill_name
    skill_name="$(basename "$skill_path")"
    local target="$target_root/$skill_name"

    if [[ -L "$target" ]]; then
      local current_target
      current_target="$(readlink "$target")"
      if [[ "$current_target" == "$skill_path" ]]; then
        echo "  = $skill_name already linked"
        continue
      fi
      echo "  ~ $skill_name (replacing existing symlink)"
      run "rm '$target'"
    elif [[ -e "$target" ]]; then
      local backup="$target.backup-$(stamp)"
      echo "  ~ $skill_name (moving existing dir to $(basename "$backup"))"
      run "mv '$target' '$backup'"
    else
      echo "  + $skill_name"
    fi

    run "ln -s '$skill_path' '$target'"
  done
}

if $INSTALL_CURSOR; then
  link_into "$CURSOR_SKILLS" "Cursor"
fi

if $INSTALL_CODEX; then
  link_into "$CODEX_SKILLS" "Codex"
fi

if $DRY_RUN; then
  echo
  echo "(dry run — no changes made)"
else
  echo
  echo "done. run 'make doctor' to verify."
fi
