---
name: dirty-worktree-etiquette
description: >-
  Safely operate inside a dirty git worktree without reverting user changes.
  Use whenever you encounter modified, untracked, or staged files you didn't
  create yourself, before any git destructive operation (reset, checkout,
  clean, restore), and before committing in a workspace where unrelated
  files are dirty. Adopted from Codex's worktree rules — codifies the
  difference between "your work in progress" and "the user's work in
  progress that happens to be in the same tree."
---

# Dirty Worktree Etiquette

You may be sharing a worktree with the user. Treat unfamiliar changes
as theirs unless you have explicit evidence they're yours.

## Core rules

- **Never** revert existing changes you did not make, unless the user
  explicitly requested it.
- **Never** use destructive commands without explicit user instruction:
  - `git reset --hard`
  - `git checkout -- <file>` / `git restore <file>` (to discard local
    edits)
  - `git clean -f` / `git clean -fd`
  - `git stash drop` (without confirmation)
  - `git push --force` to a shared / protected branch
- **Never** silently `git add .` or `git add -A` when unrelated dirty
  files are in the tree. Stage explicitly: `git add path/to/file ...`
- **Never** `git commit -a` or `git commit --all` in a mixed tree.
- If the request is ambiguous about destructive operations, **ask
  before acting**.

## Triage protocol when you see unexpected changes

Before doing anything, classify each modified or untracked file:

1. **You modified it earlier in this turn / chat.** OK to keep working
   on it. Verify with the recent tool history if unsure.
2. **The user modified it (or an external tool / generator did).**
   Treat it as authoritative.
   - If it's in a file relevant to your task: read it carefully and
     work *with* the change. Do not undo it. Re-plan around it if
     necessary.
   - If it's in a file unrelated to your task: ignore it entirely.
     Do not stage it. Do not mention it as needing cleanup unless the
     user asks.
3. **You can't tell which.** Default to (2) — assume it's the user's.

## Staging discipline for commits

- Stage **only** the files that belong to the change you're committing.
  List them explicitly: `git add path/a path/b path/c`.
- Verify with `git status --short` after staging — confirm the staged
  set matches the change you described, no more.
- If there are dirty files outside the change, leave them in the
  working tree. Don't `git stash` them unless the user asked.
- When the user later commits or stashes those unrelated changes
  themselves, that's their responsibility, not yours.

## Submodules

- Submodule "modified content" status is almost always not yours.
  Leave it alone. Do not run `git submodule update --remote` or
  similar without an explicit ask.

## When the user is ambiguous

If asked to "commit this" or "save my work" in a mixed tree, confirm
the scope before staging:

> "Tree has changes in `[your-files]` plus unrelated edits in
> `[other-files]` — I'll stage only the first set. Sound right?"

This is faster than reverting an over-eager commit.

## When force-push is genuinely needed

Force-push is allowed only when:

- The user explicitly asks for it, **and**
- The branch is **not** `main` / `master` / `release/*` / a shared
  protected branch, **and**
- The reason is one of: amended commit on your own feature branch
  before review, rebase to a new base, history rewrite the user
  authorised.

If pushing to a shared branch with force, **warn the user explicitly**
before doing it, even if they appeared to ask. Confirm.

## Amend rules (compatible with Cursor's existing constraints)

Amend only when **all** of:

1. User explicitly requested amend, **or** the previous commit
   succeeded but a pre-commit hook auto-modified files that need
   including.
2. The HEAD commit was created by you in this conversation (verify:
   `git log -1 --format='%an %ae'`).
3. The commit has not been pushed (verify: `git status` shows
   `Your branch is ahead of … by N commits`).

If the previous commit was rejected or failed, **never** amend —
create a new commit instead.

## Recovery if you slipped

If you accidentally reverted user work:

1. Stop. Don't push.
2. Check `git reflog` for the pre-revert state.
3. Surface the issue to the user immediately. Don't paper over it.
4. Restore from the reflog with their approval.

---

## When to invoke

Read this at the start of any of:

- A turn that includes git commands beyond `git status` / `git diff`.
- A turn where `git status` shows unexpected modifications or
  untracked files.
- Any explicit destructive request (so you can verify scope).
- Before opening / updating a PR in a tree that may not be clean.

Skip for: pure read operations (`git log`, `git diff`, `git show`),
or sandboxes you definitely created from scratch.
