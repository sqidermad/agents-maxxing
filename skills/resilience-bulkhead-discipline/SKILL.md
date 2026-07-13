---
name: resilience-bulkhead-discipline
description: >-
  Apply resilience bulkheading for multi-user systems: separate control-plane
  and heavy data-plane behavior, enforce auth-state consistently across API
  surfaces, preserve error contracts, and add anti-lockout admin guards. Use
  when adding auth/roles, mission limits, long-running search/jobs, queueing,
  or failure handling under load. Derived from cross-model benchmark
  findings (provenance in docs/credits.md).
---

# Resilience Bulkhead Discipline

Use this when a feature touches auth, multi-user role boundaries, mission/
resource limits, or long-running/high-volume search workflows.

## Why this exists

A system can be "functionally correct" and still fail in production because:

- deactivated users are blocked in some endpoints but not others,
- control-plane endpoints hang behind heavy requests,
- important business errors are collapsed into generic codes,
- admin changes can accidentally remove the last active admin.

This skill enforces a portable reliability baseline across models and toolchains.

## 1) Split control-plane vs heavy-plane behavior

Define endpoint classes explicitly:

- **Control-plane:** auth, users, permissions, mission list, settings.
- **Heavy-plane:** big search, enrichment, fan-out providers, async jobs.

Rules:

1. Control-plane must fail fast (short timeout, clear 5xx/503 path).
2. Heavy-plane may run longer, but must be bounded (queue/caps/timeouts).
3. Heavy-plane saturation must not freeze control-plane.

If both classes still share one pool/process, add guardrails now and queue/job
separation next.

## 2) Enforce auth state on every protected API surface

Do not rely on JWT decode alone for "active user" or role validity.

Checklist:

- Validate token signature/expiry.
- Re-check user state from source of truth (DB/cache) for protected routes.
- Apply same policy across route groups (`/api/search`, `/api/missions`,
  `/api/users`, utilities) unless explicitly exempted.
- Re-check user state on refresh-token flow.

If deactivation is a product-level control, deactivation should take effect
immediately (next request), not only after token expiry.

## 3) Preserve semantic error contracts end-to-end

When backend returns structured business errors (e.g., limit reached), preserve
that semantic code through BFF/client layers.

Bad: always mapping to `REQUEST_FAILED`.
Good: map known patterns to stable codes such as `LIMIT_REACHED` while keeping
status/details.

Required checks:

- Does UI branch on specific code?
- Does middleware/BFF preserve details and status?
- Are generic fallbacks used only for unknown/unclassified errors?

## 4) Add anti-lockout admin safety invariants

When user management can change role/active state:

- Prevent self-deactivation for currently active account.
- Prevent demoting/deactivating the final active admin.
- Prefer transactional/atomic guard if concurrent writes are possible.

A "correct" CRUD UI is unsafe without these invariants.

## 5) Limit semantics must be both hard and visible

For constraints like "max 20 missions per user" and "max 20 targets/mission":

- Enforce server-side as source of truth.
- Mirror in UI validation for fast feedback.
- Ensure backend limit errors become user-facing explanatory messages,
  not generic failures.

## 6) Recovery and boundedness for long-running work

If jobs/queues exist:

- stale RUNNING recovery,
- max active per user,
- max active global,
- timeout per job,
- oversized result guard,
- explicit terminal states (`COMPLETED/FAILED/CANCELLED`).

## 7) Verification gate before merge

Run and state these checks explicitly:

1. **Auth-surface sweep:** list protected routes and show active-user
   enforcement path.
2. **Refresh-path check:** inactive user cannot refresh into new access token.
3. **Limit UX check:** mission/target caps return semantic code and correct toast.
4. **Admin-safety check:** cannot deactivate self or last active admin.
5. **Load behavior check:** control-plane remains responsive while heavy jobs run.

## When to invoke

- adding roles/permissions/user management,
- introducing queue/job endpoints,
- changing mission/target limits,
- adding middleware affecting auth,
- hardening APIs after timeout/overload incidents,
- preparing multi-model benchmark baselines for production behavior.

## When NOT to invoke

- pure UI copy updates,
- static docs-only edits,
- single-file logic fixes unrelated to auth/load/limits.
