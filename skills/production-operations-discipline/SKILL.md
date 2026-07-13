---
name: production-operations-discipline
description: >-
  Safety rules for touching live systems: deploys, restarts, database
  migrations, file sync/deletion on hosts, service config changes.
  Use before running anything on a production or shared server —
  including "just checking" sessions that could turn mutating. Built
  from real incidents; the core loop is stage → validate → backup →
  apply → verify, with a proven rollback at every step.
---

# Production Operations Discipline

A workstation mistake costs an undo. A production mistake costs an
outage. Every rule here exists because skipping it has actually
broken something.

## Before touching anything

- **Explicit user intent controls production mutations.** "Look at
  the server" is read-only. Deploy, restart, delete, migrate — each
  needs the user to have asked for *that thing*.
- **Verify the host matches your assumptions before acting.** Wrong
  SSH user, missing git checkout, unexpected directory layout —
  when reality contradicts the plan, stop and ask; don't improvise a
  new plan on a live box.
- Know your rollback *before* you apply. If you can't say how to get
  back, you're not ready to go forward.

## Artifacts, not working trees

- Deploy from an **immutable, checksummed artifact** built from a
  tag — never `git pull` on the host, never ad-hoc rsync of a
  working tree. Verify the checksum on the host before extracting.
- **Preflight the tag's tree for runtime junk.** Ignore rules don't
  protect you: files tracked *before* being ignored stay tracked, and
  archives package the tree, not the ignore file. A tracked `.venv/`,
  `.env`, key, or `__pycache__/` in the tag means ABORT — a stale
  committed venv shipped over a host's real one has caused a
  near-outage. Check: `git ls-tree -r --name-only <tag>` grepped for
  junk paths, in CI and again at build time.
- Extract to a **staging directory**, never straight onto the live
  tree.

## Validate against the live runtime

- Prove the staged code runs with the host's *actual* interpreter /
  runtime and env **before** it reaches the live path (import check,
  boot check, config parse — whatever "would it start?" means here).
- **Never restart a service you haven't proven can start.** A
  running process survives a broken tree until the moment you
  restart it; the restart is when a latent break becomes an outage.

## Backup = matched rollback unit

- Back up code **plus** runtime state (venv, env files, anything the
  service needs) as one unit, before syncing. A code-only backup
  can't roll back a runtime break.
- Restrict backup permissions (it contains env/secrets), note its
  path, and keep it until the new release has survived real traffic.

## Apply

- Sync with explicit excludes for runtime state (`.venv`, env files,
  logs) and *with* deletion of orphans — stale modules from old
  releases stay importable forever under plain overlay extracts.
- **The sync itself is a destructive command.** Preview it first
  (`rsync -n` / the tool's list mode) and *read the deletion list* —
  every planned delete must be explainable as an orphan of an old
  release. One runtime path in that list means an exclude is wrong:
  stop.
- **Destructive commands get a dry run and a cap.** Before any bulk
  delete/prune: print the exact targets, count them, and sanity-check
  the count against expectation. A cleanup that wants to delete 10×
  more than estimated is a wrong pattern, not a big cleanup.
- **Env changes are a deploy step of their own.** If the release
  needs new variables, apply them to the host env explicitly, record
  what changed, and only then restart. The artifact must not carry
  env (see `sensitive-data-discipline`).
- Migrations: dry-run first where supported (and know what the
  dry-run itself writes), apply one migration explicitly by id, not
  "whatever is pending". **Order matters:** additive migrations (new
  tables/columns) go in *before* the new code that reads them goes
  live; destructive ones (drops, renames) are a separate later
  deploy, after the code that stopped using the old schema has proven
  itself — never bundled into the same step.

## Verify like you mean it

- Health endpoint ≠ verified. Also run: one authenticated real flow
  (dedicated **test account** — never a real user's or an admin
  account), one malformed-input request (expect 4xx, not 500), one
  failure-path request using **non-real identifiers**, then read the
  service logs for the window.
- Check logs by message text as well as priority — services often
  log errors to stderr at default priority, so severity filters
  miss them.

## Rollback

- Rollback = restore the matched backup (code + runtime + env
  together), not `git checkout` archaeology. If the deploy changed
  env variables, rolling back code *without* reversing those changes
  is a new, untested combination — the record from the apply step is
  the reversal list.
- Additive migrations (new tables/columns behind a dark flag) may
  stay through a code rollback; reverse schema only if old code
  can't run against it.

## After

- Record what was deployed (tag, checksum, time) and anything
  learned the hard way — in the runbook, not just the chat.
- If the incident revealed a missing guard, file the follow-up now
  (see the self-improvement loop in `agent-operating-manual`).

## Cross-references

- `sensitive-data-discipline` — env files, keys, and identifiers
  handled during ops work.
- `failure-surfacing` — a deploy step failing twice is a stop-and-
  report, not a retry loop.
- `upstream-integration-triage` — when "the deploy broke it" might
  actually be the vendor.
