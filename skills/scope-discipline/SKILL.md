---
name: scope-discipline
description: >-
  Keep edits scoped to what the user asked, read existing patterns
  before introducing new ones, and let test coverage scale with risk.
  Use before any code edits. Adopted from Codex's engineering judgment
  block — the "don't drift, don't over-abstract, don't churn" rule.
---

# Scope Discipline

Stay inside the modules, ownership boundaries, and behavioural surface
implied by the request and the surrounding code.

## Before editing

1. **Read the existing code.** Use Grep / SemanticSearch / Read to
   find relevant files, helpers, conventions. Don't write before you've
   read.
2. **Match repo patterns.** If the project uses framework X for a
   concern, use framework X. Don't introduce framework Y because you
   prefer it.
3. **Use local helpers.** Before writing `parseDateString`, check if a
   `parseDate` helper already exists in `lib/utils/`.
4. **Use structured APIs.** For JSON / YAML / database / RPC, use the
   right parser or client. Don't string-manipulate structured data.

## Scope boundaries

- Edit only the files the request implies. If a fix needs to touch a
  helper, fine. If you find yourself "while I'm here, let me also
  refactor Y" — **stop**. That's a separate change.
- Don't touch metadata churn: timestamps, version bumps, formatting,
  unrelated import sorting. They belong in their own commits.
- Don't reorganise directory layout while doing a bug fix.
- Don't rewrite comments while fixing logic.
- Don't bump dependency versions while implementing a feature.

## When you really need to expand scope

If a fix genuinely requires touching adjacent code (e.g., a type
signature change ripples), name the ripple explicitly to the user
before doing it:

> "This needs to also update <file:line> because the type signature
> propagates. Doing it as part of this change."

## Abstractions

Add an abstraction only when it:

- Removes real complexity, not imagined future complexity.
- Reduces meaningful duplication (3+ instances, not 2).
- Clearly matches an established local pattern.

If you're inventing a new abstraction "for cleanliness" or "for future
use", it's almost always premature. Defer.

## Test coverage

Test coverage scales with risk and blast radius:

- **Narrow change inside one file**: tests focused on that file.
- **Cross-module contract change**: broaden tests to the consumers.
- **User-facing workflow**: add or update integration / e2e tests.
- **Pure refactor (no behaviour change)**: existing tests should
  still pass — don't add new ones unless you discovered a coverage
  gap.

## When to invoke

Before any code edit, especially in an area of the codebase you
haven't touched in this session. Read this once per turn, then
proceed.

Skip for: pure documentation edits, formatting commands the user
explicitly requested, mechanical rewrites the user explicitly asked
for.
