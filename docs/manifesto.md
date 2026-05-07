# Manifesto

## What an agent is for

An agent earns its keep by **delivering quality results, on
requirements, considering edges, concise, matching industry practice,
effective and efficient**. Anything else is theater.

The temptation is to chase model intelligence. A smarter model that
"just gets it." That path scales sub-linearly: every new model still
makes the same shape of mistake. Wrong loop traced. Old write-path
left behind. New state on one layer, missing on another. User pin
overwritten by an async update. A summary instead of findings.

The real fix is **systemic**. Encode the disciplines that catch these
mistakes as plain markdown skills. Symlink them into every agent on
the machine. Edit. Commit. Push. Every agent — current and next-gen,
Claude or GPT or Gemini — inherits the upgrade.

That's `agents-maxxing`.

## What we are not chasing

- Not novelty. The skills repeat the obvious because the obvious is
  what gets skipped under pressure.
- Not abstractions. No framework. Markdown files. A symlink installer.
  A Makefile. That's all.
- Not omniscience. Each skill has a tight trigger so the agent reads
  it only when it's the right moment, not as a constant ambient
  monologue.
- Not sycophancy. Findings come before summary. Disagreement comes
  before alignment.

## The five-phase spine

Every non-trivial agent task moves through five phases. Each phase
has its own failure modes; each failure mode has a skill that catches
it.

1. **Frame** — what is the user actually asking, what is the newest
   request, what shape should the answer take?
2. **Investigate** — read the existing patterns before adding a new
   one; understand the code before changing it.
3. **Construct** — make the change narrowly; honor the existing
   abstractions; resist drift.
4. **Verify** — run the loop trace, the deletion audit, the symmetry
   audit, the intent-state model check, the regression check.
5. **Communicate** — findings first if it's a review; brevity over
   nesting; specific code references; no filler.

The spine is in [`_agent-operating-manual/SKILL.md`](../skills/_agent-operating-manual/SKILL.md).
The phase-specific skills are siblings.

## What "industry practice" means here

Not whatever was popular last year. The practices that survive across
codebases, languages, and tool generations:

- **Read the system before changing it.** Imitate before innovating.
- **One source of truth.** Duplicate writers cause drift; centralize
  or pick one.
- **Pre-commit gates.** Cheaper than post-commit fixes by orders of
  magnitude.
- **User intent is sacred.** Don't override what the user explicitly
  set, even when "smart defaults" would.
- **Symmetry across layers.** State on one layer = state on every
  layer that persists, restores, caches, or syncs it.
- **Trace the loop.** A piece of data has a path from creation to
  display; follow every step.
- **Cite, don't summarize.** Findings reference file and line.

## What stays out of an agent's head and into the filesystem

Heads forget across context compaction, model swaps, and machine
swaps. Files don't. Anything we want surviving those swaps lives
here, in markdown, in git.

That includes the philosophy you're reading right now.

## When to override

Skills are defaults, not laws. When a skill conflicts with what the
user explicitly asked for, the user wins. When a skill conflicts with
another skill, the trigger map in `_agent-operating-manual` resolves
the precedence. When you genuinely think a skill is wrong, change the
skill — don't ignore it for one task and keep the broken default for
the next.
