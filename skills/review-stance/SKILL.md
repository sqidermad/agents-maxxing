---
name: review-stance
description: >-
  Restructure the response when the user asks for a review, audit, or
  critical look at code, a PR, a design, or an approach. Findings lead,
  summary follows, severity-ordered, file/line grounded. Use whenever the
  user uses words like "review", "audit", "look over", "check", "any
  issues with", "what's wrong with", or asks for a critical assessment.
  Also use when the user pastes another model's or reviewer's findings
  to act on — verify each claim before implementing any of it.
---

# Review Stance

When the user asks for a review, the answer's first content is the
findings, not a summary.

## Response structure (in order)

1. **Findings**, ordered by severity (Critical → High → Medium → Low).
   Each finding has:
   - One-line statement of the issue.
   - File / line reference using clickable code-reference format.
   - Why it matters in one sentence (runtime impact, risk, or invariant
     violated).
   - Suggested fix, or "needs investigation" if you can't propose one
     confidently.
2. **Open questions / assumptions** — things you couldn't verify, or
   places where intent was ambiguous.
3. **Change summary** as secondary context, only after findings.

## Severity calibration

- **Critical**: data loss, security regression, broken invariant in a
  production path, race condition, broken auth/permissions.
- **High**: behavioural regression, user-visible bug, API contract
  violation, missing tests on a public surface.
- **Medium**: performance regression, edge-case incorrectness, internal
  test gap, code-smell that will rot.
- **Low**: naming, formatting, doc nits, consistency drift.

## When you find no issues

Say so explicitly:

> "No blocking issues. Residual risk: <list>. Test gaps: <list>."

Don't pad with summary to fill space.

## Anti-patterns

- Burying findings under a friendly recap.
- Mixing severities ("there are some things...").
- Findings without file/line references.
- "Looks good!" without naming residual risks.

## Triaging someone else's review

When the user pastes findings from another model, a colleague, or a
tool, the job is **verification, not implementation**:

1. **Check every factual claim against the actual code** — file
   contents, line counts, git state, runtime behaviour. Reviews sound
   authoritative and are routinely partly wrong.
2. Classify each item: **confirmed** (evidence found — fix if asked),
   **refuted** (state the evidence that contradicts it — respectfully,
   concretely), or **judgment call** (both positions defensible —
   give a recommendation and let the user decide).
3. If the external review catches an error in *your* earlier work,
   say so plainly and own it. Credibility comes from the admission.
4. Never implement a pasted review wholesale. Even a mostly-right
   review usually contains one item that would make things worse.

## When to invoke

User says any of: "review", "audit", "look over", "check this", "what's
wrong with", "any issues", "critical assessment", "go through and
verify" — or pastes another reviewer's findings for you to act on.

Skip when the user asks an open-ended "what do you think?" — that's
brainstorming, not review.
