---
name: construction-discipline
description: >-
  Five-check pre-commit gate (loop trace, deletion audit, symmetry audit,
  intent modeling, regression check) for multi-layer / multi-step changes.
  Use after any feature crossing ≥2 layers (BFF↔state↔UI,
  schema↔migration↔access), new persistence paths, exclusive→additive
  refactors, new user-intent UI controls, or commits/PRs spanning multiple
  distinct concerns.
---

# Construction Discipline Gate

Before declaring any multi-layer change done, run all five checks in order.
A check is **not satisfied** until you can complete its sentence out loud
without lying. If you can't, you're not done.

## 1. Loop trace

Pick the single most important data point introduced by the feature
(e.g. `activeSourceId`, `selectedTenantId`, `lastEvictionToken`).

> "It is **set** at `<file:line>`, **carried** through `<response/event/state>`,
> **read** at `<file:line>`, **applied** at `<file:line>`, **reflected** in
> the UI / stored value at `<file:line>`."

If any of those slots is "I'll trust the default" or "I think the store
handles it" — the loop is open. Forwarding the value explicitly is the
fix; defaults that disagree with the upstream decision are a bug, not a
feature.

## 2. Deletion audit

For every new write / persistence / mutation path you added, list every
*existing* path that wrote to the same shared bucket / slice / table.

For each existing path, mark one of:
- **Deleted** in this change.
- **Kept, deferring to the new path** — and the deferral is enforced in
  code (single owner), not by hope.

"I'll leave the old code, it can't hurt" is the trap. Two writers + one
truth = silent blending.

## 3. Symmetry audit

For every new piece of state introduced (a field, a slice, a flag),
enumerate every layer that round-trips state in this codebase. For
each layer, mark **Covered** or **Intentionally not covered**.

Default layer list to audit (extend per project):
- Server / DB persistence
- Snapshot / archive payloads
- Local cache (history, IndexedDB, localStorage)
- URL / route state
- Auto-save / dirty-tracking fingerprints
- Restore-from-cache paths
- Cross-tab / multi-window sync (if applicable)

Anything you don't list, you haven't thought about.

## 4. Intent-state modeling

If the change adds any UI control that lets the user express intent
(pin, override, chip selector, manual reorder, "stick this choice"):

> "User intent is stored as a **first-class state field** named `<x>`,
> distinct from system-set values, and async / system updates check
> this field before overriding the user's choice."

Implicit intent ("the active value happens to be the one the user
clicked") is a regression waiting to happen the next time something
async lands.

## 5. Mental-model regression check

If this change shifts a paradigm — exclusive→additive, single→multi,
sync→async, single-tenant→multi-tenant, single-source-of-truth→federated:

`grep` for every direct write / read of the previously-shared field
(e.g. `setSourceData`, `updateUser`, `commitTransaction`). For each
hit, audit whether that call still belongs in the new world or is
the old paradigm leaking through.

Old code shape inside a refactored boundary is the most common source
of "but it works in isolation!" bugs.

---

## When you've finished the gate

State the result explicitly to the user before declaring done:

> "Construction discipline gate run: loop ✓, deletion ✓, symmetry ✓,
> intent ✓, regression ✓ — ready for commit."

If any check fails, fix it before commit. If a check is *intentionally*
not applicable (e.g. no new UI intent in this change), say so by name —
don't silently skip.

## When NOT to invoke

- One-line bug fixes inside a single file.
- Pure documentation edits.
- Renaming or formatting that doesn't move state.

Otherwise: invoke.
