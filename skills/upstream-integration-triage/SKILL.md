---
name: upstream-integration-triage
description: >-
  Diagnose third-party HTTP/REST API failures evidence-first. Use when
  an external endpoint (vendor API, OAuth/SSO provider, payment
  processor, Cloudflare-fronted service) returns errors your code did
  not introduce — especially "works in browser, fails from our
  service" or "login 200, downstream rejects fresh token". HTTP scope
  only; non-HTTP integrations (DB, queue, SDK-mediated) need different
  tooling — see body for exclusions.
---

# Upstream Integration Triage

A downstream API is failing. The user is asking whether it's our code.
Two failure modes to avoid: (a) shipping a fix to your own code when
the bug is vendor-side, (b) chasing the vendor when the bug is your
credential or environment. This skill keeps you honest by capturing
working-vs-failing evidence *before* you form theories.

## This skill helps if you are

- Calling a **third-party HTTP/REST API** (partner API, vendor API,
  OAuth/SSO provider, payment processor, Cloudflare-fronted service,
  any URL whose source is outside your git repo) and getting
  unexpected 4xx / 5xx / timeouts.
- Seeing the **"works in browser / Postman / staging, fails from our
  service"** pattern.
- Hitting the **"login 200, downstream rejects the fresh token"**
  pattern (auth tier and permission tier disagree).
- Trying to **prove whether a recent deploy caused** an upstream-
  looking failure, before rolling back or shipping a patch.
- Reading a **HAR file** to compare a working flow against a failing
  one.
- Debugging why an **`.env`-driven** service behaves differently from
  a shell that just `source`d the same `.env`.

## What this skill does NOT cover

The diagnostic *ladder* (reachability → auth → permission → payload)
still generalises, but the tools change. Don't apply this skill's
HTTP/HAR procedures literally to these classes — use the right native
tooling instead:

- **Database upstreams** (MySQL/Postgres/MongoDB, Redis, ElasticSearch).
  No HAR, no `curl`. Use `mysql --execute` / `psql` / `redis-cli ping`
  / the DB's own slow-query log. Reachability and auth still matter,
  but transport is the DB wire protocol, not HTTP.
- **Message queues** (SQS, Kafka, RabbitMQ, NATS). Inspect with the
  vendor CLI (`aws sqs`, `kafkactl`, `rabbitmqctl`). "Auth" and
  "permission" map to IAM / ACLs.
- **SDK-mediated calls** (AWS SDK, Stripe SDK, gRPC client libs). You
  can't see the raw wire. Turn on the SDK's debug logging
  (`AWS_DEBUG=1`, `STRIPE_LOG=debug`, gRPC tracing) rather than chasing
  `curl` parity.
- **Non-HTTP protocols** (WebSocket binary frames, MQTT, SMTP, FTP,
  raw TCP). Capture with `tcpdump` / `wireshark` / protocol-specific
  inspectors, not HAR.
- **Webhook receiving** (we are the upstream being called). Inspect
  the inbound request that already arrived; replay it. The framing
  here is "what did the client send us," not "what did we send out."
- **First-time-ever integration** where the wiring has never worked.
  That is *setup*, not *triage* — different skill entirely.
- **Failures inside services you own.** Use normal debugging on your
  own code; this skill is for the unknown side of the boundary.
- **Pure UI bugs.** No external call involved.

## The ladder — answer in order, never skip

You climb until the layer responds correctly, then move up.

1. **Reachability.** Can you resolve the host and open a TCP socket?
   `dig +short <host>` and `curl -v -o /dev/null --connect-timeout 5
   https://<host>/`. If DNS or TCP fails, stop — it is network, not
   the vendor.
2. **Transport.** Does the edge return *anything*? `curl -i
   https://<host>/<known-public-path>`. A `502` in <100 ms is a dead
   origin behind a healthy proxy. A 30 s hang is upstream busy or
   slow-rejecting (note the latency — it is evidence).
3. **Auth tier.** Does login / token-exchange return 200 with a
   well-formed token? If not, your credentials or the auth service
   itself is broken. Decode the JWT (`base64 -d`) to confirm shape and
   `exp`. *Login succeeding ≠ permission to call detail endpoints.*
4. **Permission tier.** Take the freshly-issued token and hit a
   detail endpoint. If detail returns 4xx with messages like "Invalid
   token" / "Forbidden" / "A token is required" despite a valid JWT,
   the auth tier and the permission tier do not share state — this is
   either an account that has been demoted, a permission revoke, or a
   tenant-isolation rule.
5. **Account tier.** Compare the *account* on the failing call with
   the *account* on a working call (a teammate's browser session, a
   working environment, a reference HAR). Different account → permissions
   problem; ask the vendor for an account with the right access.
6. **Payload / contract.** Only after 1–5 succeed: is the request
   shape (method, query params, body, content-type) what the endpoint
   actually expects? Vendors change contracts silently.

## Evidence-first rule

Before forming any theory, capture three artefacts:

1. The **failing request** from our side: full URL, method, headers
   (`curl -v` or `curl -i`), response status, response body, total
   latency.
2. A **working request** from any other source: HAR from a browser
   session, a teammate's `curl`, a Postman export, a working env.
3. The **diff** between them across this matrix:

| Axis | Working | Failing |
| --- | --- | --- |
| Host + scheme | | |
| Path | | |
| HTTP method | | |
| Auth *header name* (Authorization vs X-Token vs Cookie) | | |
| Account / credential identity | | |
| Response status + body | | |
| Latency | | |

The diff usually tells you the answer before you have to theorise.

## HAR gotchas you must know

- **Chrome 109+ strips `Authorization` and `Cookie` from HAR exports
  by default.** Settings → Network → "Allow to generate HAR with
  sensitive data" must be on, otherwise the export looks unauth'd
  even when the live request was authenticated. Do *not* conclude
  "the working call uses no auth" from a sanitised HAR.
- **Safari WebInspector** (`creator.name == "WebInspector"`) strips
  even more aggressively. Suspect any HAR whose creator field is
  Safari/WebInspector.
- Useful underscored fields Chrome adds: `_initiator`,
  `_resourceType`, `_priority`, `_transferSize`. They tell you which
  JS code initiated the call and whether the response was cached.
- `cf-ray`, `cf-cache-status`, `alt-svc: h3=` headers prove the
  request actually crossed Cloudflare. Their absence on the failing
  call means you might be bypassing the edge.

## .env-file shell hygiene

The number-one false-positive when reproducing failures from a shell:

- `set -a; source .env.local; set +a` parses each line **as a bash
  command**. Values containing spaces, `=`, or quotes get truncated
  or lost. `KEY=Basic abc=` becomes `KEY=Basic`.
- **Systemd's `EnvironmentFile=`** reads the whole line as the value,
  no shell parsing. So a service running under systemd may see the
  full value while your interactive `source` sees a broken one. *Do
  not* conclude "the env is wrong for the service" from your shell.
- **Python's `python-dotenv`** behaves like systemd, full line.
- Fix: quote values with spaces in the .env file
  (`KEY='Basic abc='`). Then `source` and `EnvironmentFile=` agree.
- Diagnostic: `echo "len=${#KEY}"` — if the length is suspiciously
  short, you've been truncated.

## Decision rules

Map symptoms to causes before deciding what to change:

| Symptom | Most likely cause | What to change |
| --- | --- | --- |
| Login 200, detail 4xx with valid fresh token | Account lacks permission for that endpoint | Credentials, not code |
| Login 200, detail hangs 30 s then 4xx | Vendor slow-rejecting auth | Vendor ticket; add 400-with-"Invalid token" to refresh triggers |
| Origin returns 502 in 50 ms | Upstream behind nginx is dead | Wait / vendor ticket |
| Works on host A, fails on host B (same creds) | Different edge / different deployment | Switch to host A |
| Works for teammate, fails for us | Account difference | New credential |
| Worked yesterday, fails today, no deploy | Vendor or account-side change | Evidence pack to vendor |
| Worked before deploy X, fails after | Maybe you. Roll back to prior tag and re-test before further theorising |

## When you conclude "vendor side"

Do *not* close the loop with "wait for them." Produce a vendor evidence
pack:

1. **One-sentence summary** of what's broken.
2. **Account ID** and timestamp range.
3. **Two curls**: the working flow (login 200, what data came back) and
   the failing flow (detail call, headers, status, body, total time).
4. **Ask explicitly** what you need: detail-tier access for this
   account / a working service account / a fixed ETA.

If the same vendor breaks repeatedly, also file a follow-up ticket on
**your** side: a small retry/cache-invalidation hardening so the next
incident does not last 23 hours of cached bad token (see
`resilience-bulkhead-discipline`).

## What NOT to do

- **Don't theorise without evidence.** "Probably IP allowlist" /
  "probably token expired" without a curl to back it is wasted turns.
- **Don't conflate "vendor down" with "this account is broken."**
  They have completely different fixes.
- **Don't propose a code patch when the failure is per-account.** That
  is an env / credential change, not a deploy.
- **Don't restart the service hoping it is transient** unless you
  have evidence of a process-local cache that the restart will flush.
- **Don't trust a HAR's auth headers** unless you confirmed the
  creator + DevTools setting.

## Cross-references

- `failure-surfacing` — after 3 unsuccessful theories, *stop* and tell
  the user what you've ruled out before they ask.
- `resilience-bulkhead-discipline` — the *after* of an outage: make
  our service tolerate this when it happens next.
- `dirty-worktree-etiquette` — if you do roll back to prove a prior
  tag reproduces, respect any local changes the user already made.
- `_agent-operating-manual` Phase 2 (Investigate) — this skill is the
  vendor-flavoured specialisation of "let the existing system teach
  you how to move."
