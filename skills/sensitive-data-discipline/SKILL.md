---
name: sensitive-data-discipline
description: >-
  Handling rules for secrets and personal data: env files,
  certificates, keys, tokens, passwords, and personal identifiers
  (phone numbers, national IDs, IMSI/IMEI, emails). Use whenever the
  work touches, displays, logs, commits, or transmits any of these —
  reading configs, debugging auth, writing log lines, sharing
  evidence, or running tests against real systems.
---

# Sensitive Data Discipline

Two categories, one rule each: **secrets** must never leave their
storage, and **personal identifiers** must never appear whole where
they don't have to.

## Secrets (env files, keys, certs, tokens, passwords)

- **Never print secret values.** When displaying an env file or
  config, redact values: `API_KEY=***` (keep the key names — they're
  the useful part). Same for tokens in headers, connection strings,
  and JWT payload dumps.
- **Never commit them, never ship them.** `.env` / `.env.local`,
  `.pem`, private keys have no business in a repo or an artifact.
  Ignore rules are not proof — files tracked before being ignored
  stay tracked. Verify with `git ls-files`, and preflight artifacts
  (see `production-operations-discipline`).
- **Keep secrets off command lines.** Arguments land in shell
  history and the process list. Pass via env, files with tight
  permissions, or the tool's stdin/prompt.
- **A secret pasted into chat is compromised.** It sits in
  transcripts, context windows, maybe provider logs. Use it if the
  user gave it for the task, but say so and recommend rotating or
  disabling it when the task is done.
- Files that bundle secrets (host backups with env inside, HAR files
  with auth headers) inherit the rules: tight permissions, no
  casual sharing, strip before attaching anywhere.

## Personal identifiers (phones, national IDs, IMSI/IMEI, emails)

- **Mask by default** in logs, error messages, test output, tickets,
  and chat: keep enough to correlate (last 3–4 digits), drop the
  rest. A raw phone number in a log line is a leak with a timestamp.
- Masking belongs **in the code path**, not in your habits — if the
  service logs an identifier, fix the log line, don't just avoid
  looking at it.
- **Test with synthetic identifiers**, never a real person's. A fake
  number that exercises the failure path proves the same thing with
  none of the exposure.
- Exception traces count: `str(e)` from an upstream client often
  embeds the request — and the identifier — verbatim. Mask before
  logging exceptions in identifier-handling paths.

## Evidence sharing (reviews, vendor tickets, screenshots)

- Strip auth headers, cookies, and tokens from HARs / curls before
  sharing — and remember browser HAR exports may *already* be
  stripped, which cuts both ways (see
  `upstream-integration-triage`'s references on sanitised HARs).
- Vendor evidence packs get account **IDs** and timestamps, not
  credentials.

## When you slip

Printed a secret, logged a raw identifier, committed an env file:
say so immediately, then fix it — rotate the secret, scrub or
rewrite the history *with the user's explicit go-ahead*, patch the
log line. Quietly deleting the message is not remediation.

## When NOT to fire

Work that never touches config, auth, logging, or user data — pure
algorithm or UI-copy changes don't need this pass.
