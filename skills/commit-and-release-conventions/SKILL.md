---
name: commit-and-release-conventions
description: >-
  Conventions for commits, tags, releases, and PRs. Use before any git
  commit, when creating or annotating a version tag or release, when
  writing a PR title/body, or when linking a PR to an issue. Covers
  attribution, tag naming, issue-close semantics, and pre-release
  hygiene.
---

# Commit and Release Conventions

The user's name goes on this work. Every commit, tag, and release is
part of a permanent record other people read later — make that record
clean, honest, and free of tooling noise.

## Commits

- **No AI attribution. Ever.** No `Co-Authored-By` trailers naming an
  AI, no "Generated with ..." lines, no assistant sign-offs — in
  commits, PR bodies, release notes, or any other artifact. The
  user's tooling choices are not part of the project record.
- **Don't commit or push unless asked.** Finishing an edit is not
  permission to commit it. If asked to commit on the default branch,
  branch first.
- Message shape: lowercase `type(scope): summary` where the repo
  already uses it; otherwise match the repo's own log style. Read
  `git log --oneline -10` before writing the message.
- The body answers *why*, not just *what*. A future reader has the
  diff; they don't have the reasoning.
- Stage explicitly (see `dirty-worktree-etiquette`); never sweep up
  unrelated dirty files into your commit.

## Version tags

- **Plain numbers only.** `1.2.0`, never `v1.2.0`. Pre-releases:
  `1.2.0-alpha1`, `1.2.0-rc1`.
- Tag only after the repo's checks pass on the exact commit being
  tagged.
- Mark pre-releases as pre-releases in the forge UI
  (`gh release create --prerelease`).
- **Tags are immutable history.** If a tag turns out to be broken or
  unsafe (bad artifact, tracked junk, security issue), don't delete
  or move it — annotate its release notes with a clear warning ("do
  not deploy this tag; first safe tag is X") and cut a new one.

## Linking PRs to issues

- `Closes #N` auto-closes the issue **only when the PR merges into
  the default branch.** On a release or feature branch it does
  nothing — and worse, it *looks* like it will. Track and close
  manually in that case.
- Partial work never says `Closes`. Use `Part of #N` — an issue
  closed by a PR that solved a third of it is a lie in the tracker.
- Check what a PR will actually close before merging (the forge shows
  linked issues); fix the body *and* the commit message if wording
  slipped in.

## PR bodies

- Lead with **what** changed and **why**; keep "how" for the diff.
- State what was verified and how — and what was *not* verified,
  honestly.
- For stacked PRs, name the base and the merge order in the first
  line.

## Release notes / changelogs

- Write for the person deciding whether to upgrade: behaviour
  changes, migration steps, flags, known-unsafe paths.
- Keep an `[Unreleased]` section current as PRs merge; promote it at
  tag time instead of reconstructing history from the log.

## When NOT to fire

Reading git state (`status` / `diff` / `log`) — nothing here applies
until you're about to *write* history.
