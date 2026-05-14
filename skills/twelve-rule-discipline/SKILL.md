---
name: twelve-rule-discipline
description: >-
  Twelve-rule template for production agent work — caution over speed,
  explicit budgets, intent-encoded tests. Use as a project-wide default
  before any non-trivial change, or when the user says "rule N" /
  "Mnilax rules" / "twelve-rule template". Owns three concepts not
  covered elsewhere (model-vs-code split, hard token budgets, test
  intent) and cross-references existing discipline skills for the
  other nine rules.
---

# Twelve-Rule Discipline

A project-wide rule template applied to every task in this workspace
unless explicitly overridden. Bias: **caution over speed** on non-
trivial work. Use judgment on trivial tasks.

CLAUDE.md is a **behavioral contract, not a wishlist.** Every rule
must answer one question: *what mistake does this prevent?* If a rule
in your project's CLAUDE.md can't name a specific failure mode from
your actual work, drop it. Compliance scales with relevance.

**The 200-line ceiling.** Past ~200 lines, Claude (and most current
agents) start pattern-matching to "rules exist" without actually
reading them. Compliance has been measured to drop from ~76% at 12
rules to ~52% at 18 rules. Keep your CLAUDE.md tight. This skill is
also kept short for the same reason.

## Attribution

Rules 1–4 (the floor) — origin: **Andrej Karpathy**'s January 26, 2026
complaint thread; packaged into the canonical 4-rule CLAUDE.md by
**Forrest Chang** at
[`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills)
(the fastest-growing single-file repo of 2026: 120K+ stars).

Rules 5–12 (the extension) — by **Mnilax / Mnimiy**, derived from 6
weeks of testing across 30 codebases and 50 representative tasks. See
[the source article](https://x.com/Mnilax/status/2053116311132155938).
Reported result: mistake rate 41% (vanilla) → 11% (Karpathy 4) → 3%
(extended 12).

The wording here is adopted with minor edits; cross-referenced to
existing discipline skills where coverage already existed in this repo
so the system stays lean.

## The twelve rules — index

| # | Rule | Home |
| --- | --- | --- |
| 1 | Think before coding | `_agent-operating-manual` Phase 1, `continuation-sanity-check` |
| 2 | Simplicity first | `scope-discipline` |
| 3 | Surgical changes | `scope-discipline` |
| 4 | Goal-driven execution | `_agent-operating-manual` Phase 4 |
| 5 | Use the model only for judgment calls | **This skill, below** |
| 6 | Token budgets are not advisory | **This skill, below** |
| 7 | Surface conflicts, don't average them | `_agent-operating-manual` Cross-cutting ethos |
| 8 | Read before you write | `scope-discipline`, `_agent-operating-manual` Phase 2 |
| 9 | Tests verify intent, not just behavior | **This skill, below** |
| 10 | Checkpoint after every significant step | `_agent-operating-manual` Phase 5, `continuation-sanity-check` |
| 11 | Match the codebase's conventions | `scope-discipline` |
| 12 | Fail loud | `failure-surfacing`, ethos "Honesty over confidence" |

For rules 1–4, 7, 8, 10–12: invoke the home skill — they already
encode the operational behaviour. Rules 5, 6, and 9 below are not
covered elsewhere.

## Rule 5 — Use the model only for judgment calls

The LLM is an expensive, non-deterministic component. Use it where
deterministic code cannot answer; do not use it where code can.

**Use the model for:**

- Classification of ambiguous input (intent, sentiment, fuzzy match).
- Drafting prose, summarising long text, extracting fields from
  unstructured documents.
- Judgement on trade-offs, design alternatives, code review.

**Do NOT use the model for:**

- Routing (a switch / lookup table answers this).
- Retries on transient errors (exponential backoff is code).
- Deterministic transforms (uppercase, date format, JSON parse).
- Comparing two known values for equality.

If a code path can answer, code answers. The model's job is the
ambiguous middle, not the deterministic edges.

## Rule 6 — Token budgets are not advisory

Set explicit budgets before starting work. Default budgets (override
per project):

- **Per task: 4,000 tokens** of agent work (read, write, reason).
- **Per session: 30,000 tokens** before forced compaction.

If approaching budget:

- Summarise current state explicitly, then start a fresh task.
- **Surface the breach to the user** — name the rule, name why, offer
  to scope down or split.
- Do not silently overrun. Token-overrun without acknowledgement is
  the same failure mode `failure-surfacing` covers for tool errors.

## Rule 9 — Tests verify intent, not just behavior

A test that can't fail when the business logic changes is wrong.

**Anti-patterns:**

- Snapshot tests on opaque blobs nobody ever re-reads.
- Mock-only tests that re-implement the production logic inside the
  mock, then assert the mock was called.
- Coverage-driven tests written to turn a line green, not because the
  line's intent matters.

**A good test encodes WHY, not just WHAT:**

- The assertion captures a business invariant (e.g. "an inactive
  admin cannot demote the last active admin"), not just a return
  value.
- If you remove the production code, the test fails for a *named*
  reason ("admin lockout invariant broken"), not just "got null,
  expected X".

Practical rule: before writing the test, finish the sentence "This
test exists because if it ever fails, that means `<concrete business
consequence>`." If you can't finish it without hand-waving, the test
is testing the wrong thing.

## When this skill fires

- Onboarding a new project — confirm the rule template with the user.
- The user invokes any rule by number, or says "Mnilax rules" /
  "twelve-rule template".
- You catch yourself doing one of the anti-patterns: model for
  routing, silent token overrun, behavior-only tests.

## When NOT to fire

- Trivial tasks (one-line fix, formatting). Judgment applies; the
  full rule set doesn't need a gate.
- A rule already has a home skill (1–4, 7, 8, 10–12) — read that
  skill, not this one. This skill is the index, not the answer.

## Applying the rules to your project

- **Don't paste all 12 without thought.** Read them, keep the ones
  that map to mistakes you have actually made, drop the rest. A
  6-rule CLAUDE.md tuned to your real failure modes beats a 12-rule
  one with 6 rules you'll never need.
- **Stay under 200 lines total** including any project-specific rules
  appended below the 12.
- **Avoid noise rules.** "Be careful" / "think hard" / "really focus"
  drop compliance to ~30% because they're not testable. Replace with
  concrete imperatives ("state assumptions explicitly").
- **Avoid examples** in CLAUDE.md. Three examples cost as much
  context as ten rules and the model over-fits to them. Rules are
  abstract; examples are specific.
- **Avoid tool-coupled rules.** "Always use eslint" silently fails on
  projects without eslint. Phrase as capabilities: "match the
  codebase's enforced style."

## Credit

See `docs/credits.md` and the Attribution block above for the full
chain (Karpathy → Forrest Chang → Mnilax).
