#!/usr/bin/env bash
# install.sh — symlink agents-maxxing skills into Cursor, Codex, and/or
# Claude Code.
#
# Usage:
#   ./install.sh             # install into every tool found on this machine
#   ./install.sh --cursor    # only Cursor
#   ./install.sh --codex     # only Codex
#   ./install.sh --claude    # only Claude Code
#   ./install.sh --all       # explicit all
#   ./install.sh --dry-run   # show what would happen without doing it
#   (selector flags combine: --cursor --claude installs into those two)
#
# Behaviour:
#   - For each skill in skills/, create a symlink at the target location.
#   - If the target already exists and is NOT already a symlink to this
#     repo, move it aside to <name>.backup-<timestamp> before linking.
#     Backups are never deleted or restored automatically — see README.
#   - Removes dangling symlinks that point into this repo (left behind
#     when a skill here is renamed or deleted).
#   - Skips a tool if its home folder doesn't exist (not installed).
#     Claude Code doesn't pre-create ~/.claude/skills, so that folder is
#     created when ~/.claude exists.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

CURSOR_SKILLS="$HOME/.cursor/skills-cursor"
CODEX_SKILLS="$HOME/.codex/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"

INSTALL_CURSOR=false
INSTALL_CODEX=false
INSTALL_CLAUDE=false
SELECTED=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --cursor)  SELECTED=true; INSTALL_CURSOR=true ;;
    --codex)   SELECTED=true; INSTALL_CODEX=true ;;
    --claude)  SELECTED=true; INSTALL_CLAUDE=true ;;
    --all)     SELECTED=true; INSTALL_CURSOR=true; INSTALL_CODEX=true; INSTALL_CLAUDE=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help)
      sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown flag: $arg" >&2
      exit 2
      ;;
  esac
done

if ! $SELECTED; then
  INSTALL_CURSOR=true
  INSTALL_CODEX=true
  INSTALL_CLAUDE=true
fi

stamp() { date +%Y%m%d-%H%M%S; }

# Run a command directly (no eval — arguments are passed as-is, so paths
# with spaces or quotes can't be re-interpreted by the shell).
run() {
  if $DRY_RUN; then
    printf '  +'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
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

  # Clean up dangling symlinks that point into this repo — left behind
  # when a skill was renamed or deleted here.
  local existing dest
  for existing in "$target_root"/*; do
    [[ -L "$existing" ]] || continue
    dest="$(readlink "$existing")"
    if [[ "$dest" == "$SKILLS_DIR"/* && ! -e "$existing" ]]; then
      echo "  - $(basename "$existing") (removing dangling link to renamed/deleted skill)"
      run rm "$existing"
    fi
  done

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
      run rm "$target"
    elif [[ -e "$target" ]]; then
      local backup="$target.backup-$(stamp)"
      echo "  ~ $skill_name (moving existing dir to $(basename "$backup"))"
      run mv "$target" "$backup"
    else
      echo "  + $skill_name"
    fi

    run ln -s "$skill_path" "$target"
  done
}

if $INSTALL_CURSOR; then
  link_into "$CURSOR_SKILLS" "Cursor"
fi

if $INSTALL_CODEX; then
  link_into "$CODEX_SKILLS" "Codex"
fi

if $INSTALL_CLAUDE; then
  # Claude Code stores personal skills in ~/.claude/skills but doesn't
  # create the folder by itself. Create it if Claude Code is installed
  # (~/.claude exists); skip entirely if it isn't.
  if [[ -d "$HOME/.claude" && ! -d "$CLAUDE_SKILLS" ]]; then
    echo "→ creating $CLAUDE_SKILLS (Claude Code doesn't pre-create it)"
    run mkdir -p "$CLAUDE_SKILLS"
  fi
  if $DRY_RUN && [[ -d "$HOME/.claude" && ! -d "$CLAUDE_SKILLS" ]]; then
    echo "→ would install into Claude Code ($CLAUDE_SKILLS) after creating it"
  else
    link_into "$CLAUDE_SKILLS" "Claude Code"
  fi
fi

if $DRY_RUN; then
  echo
  echo "(dry run — no changes made)"
else
  echo
  echo "done. run 'make doctor' to verify."
fi
