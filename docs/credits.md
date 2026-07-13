# Credits

Honest attribution for what's in this repo.

## What came from Codex's base prompt

Codex's base instructions (the `system` message that ships with
Codex) are an opinionated operating manual covering frontend design,
git etiquette, scope discipline, review stance, and answer shape.
Reading them surfaced a number of disciplines that were already
implicit in good agent work but had never been written down.

Skills derived (in part or in spirit) from Codex's base prompt:

- `frontend-design-discipline` — UI/UX rules: card-in-card avoidance,
  no orbs, brand-as-H1, Lucide-first icon discipline, stable
  dimensions, hero rules, palette guidance.
- `dirty-worktree-etiquette` — git safety: never revert user changes
  you didn't make, no `--hard` resets without explicit ask, explicit
  staging, submodule etiquette.
- `scope-discipline` — read existing patterns first, no drive-by
  refactors, scale tests with risk, prefer local helpers.
- `review-stance` — findings lead, severity ordered, file/line
  grounded, summary follows.
- `continuation-sanity-check` — verify you're answering the **newest**
  request, not a stale one from earlier in the context.
- `answer-shape-discipline` — line caps, prose-over-nesting for small
  changes, specific code references, no anti-comparison rhetoric.

Codex's prompt is proprietary, so nothing here is copied verbatim.
The disciplines are paraphrased and adapted to a portable format.
Where Codex's exact wording was strong, it shaped vocabulary
(e.g., "answer shape", "construction discipline") but not full
sentences.

Acknowledgement: a lot of this is **OpenAI Codex team's
craftsmanship made portable**.

## What came from Cursor's skill format

The format of these skills — folder per skill, `SKILL.md` with YAML
frontmatter, trigger-rich `description` field — is Cursor's. We
adopted it because:

1. Cursor and Codex both honor it.
2. The trigger-based loading (rather than always-on) is the right
   primitive: skills are read when relevant, not as ambient
   monologue.
3. Multiple existing Cursor-shipped skills (`babysit`, `canvas`,
   `create-skill`, `split-to-prs`, `statusline`, `update-cursor-settings`,
   etc.) demonstrate the format works at scale.

`docs/adoption-guide.md` instructions on adding a new skill mirror
the structure Cursor uses for its built-in skills.

## What came from production scars

These are original to this repo, born from specific bugs in real
codebases:

- `construction-discipline` — the five-check pre-commit gate (loop
  trace, deletion audit, symmetry audit, intent-state modeling,
  mental-model regression check). This came directly from a
  multi-source data orchestration project where four high-severity
  bugs slipped past the agent because each layer was correct
  individually but the layers weren't traced end-to-end. The five
  checks are exactly the questions that, if asked before commit,
  would have caught all four bugs.
- `agent-operating-manual` — the spine, the five-phase model, and
  the trigger map are original. They synthesise the disciplines into
  a workflow and resolve which skill applies when.

## What inspired the install model

The pattern of "source-of-truth repo + symlinks into multiple tool
homes" is a common dotfiles pattern. `agents-maxxing` adapts it for
agent skills, with the additional twist that the same skill files
serve **two different agent runtimes** (Cursor and Codex) without
modification.

If you've ever managed dotfiles with `stow` or `chezmoi`, the install
script will feel familiar — minus the framework, plus a doctor
command.

## Cross-model benchmark findings

Recent production hardening findings were validated via comparative
review loops across:

- Opus 4.7
- Sonnet 4.6
- Cursor Premium Agents
- Codex 5.5 (extra-high)
- Codex 5.3

The resulting portable rules are captured in
`resilience-bulkhead-discipline` and include:

- enforce user `active` state across all protected API surfaces,
- re-check DB user state on refresh-token flow,
- preserve semantic business error codes across BFF/client layers,
- separate control-plane fail-fast behavior from heavy-plane bounded
  processing,
- block self-deactivation and final-active-admin removal.

Attribution: this was a **multi-model synthesis** driven by real
production incidents and verified in code reviews, not a single-vendor
derivation.

## What came from external practitioners

Skills derived (in whole or in part) from publicly-shared prompts
written by other engineers:

- **`twelve-rule-discipline`** — the CLAUDE.md rule template has a
  three-step lineage worth tracking honestly:
  1. **Andrej Karpathy** (Jan 26, 2026) posted the original complaint
     thread on X identifying three failure modes — silent wrong
     assumptions, over-engineering, orthogonal damage to code that
     shouldn't have been touched.
  2. **Forrest Chang** packaged that complaint into a 4-rule
     CLAUDE.md and shipped it at
     [`forrestchang/andrej-karpathy-skills`](https://github.com/forrestchang/andrej-karpathy-skills).
     It became the fastest-growing single-file repo of 2026 (5,828
     stars day 1, 120K+ stars total). Rules 1–4 in the skill are his
     packaging.
  3. **Mnilax / Mnimiy** ([source article](https://x.com/Mnilax/status/2053116311132155938))
     tested the 4-rule baseline across 30 codebases over 6 weeks and
     added rules 5–12 to cover failure modes the baseline did not
     address (multi-step pipelines, token blowouts, conflict-averaging,
     intent-blind tests, silent successes). Reported mistake rate
     dropped from 41% vanilla → 11% with 4 rules → 3% with 12 rules.

  Of the twelve rules, nine were already covered by existing skills
  in this repo (`agent-operating-manual`, `scope-discipline`,
  `continuation-sanity-check`, `failure-surfacing`) and are cross-
  referenced rather than duplicated. Three concepts were genuinely
  new to this repo and were adopted into the skill body: *use the
  model only for judgment calls* (rule 5), *token budgets are not
  advisory* (rule 6), and *tests verify intent, not just behavior*
  (rule 9). Rule 7 ("surface conflicts, don't average them") was
  adopted as invariant 7 in the operating manual.

  Two framings from Mnilax's article are also adopted as load-bearing
  context inside the skill: the **"behavioral contract, not wishlist"**
  framing (every rule must name the mistake it prevents) and the
  **200-line ceiling** on CLAUDE.md before compliance drops.

## What came from real production scars

Three skills are original to this repo, distilled from incidents and
review cycles in real production work (details sanitised):

- **`production-operations-discipline`** — born from a near-outage
  where a deploy archive faithfully shipped a stale committed
  virtualenv over a host's real one (ignored-but-tracked files still
  ship). Every rule in it — artifact preflights, boot-check before
  restart, matched rollback units, deletion caps — maps to a specific
  thing that went wrong or almost did.
- **`commit-and-release-conventions`** — accumulated from release
  cycles: the `Closes #N` default-branch gotcha, broken tags that
  must be annotated rather than deleted, attribution noise in
  history.
- **`sensitive-data-discipline`** — from operating services that
  handle personal identifiers: masking in code paths (including
  exception traces), synthetic test identifiers, secrets hygiene
  around env files, backups, and HARs.

## What's not (yet) credited

If this repo evolves to include skills derived from other public
prompts, papers, or open-source agent toolkits, they go here. A skill
without a clear lineage gets noted as "original to this repo."

The intent is for `credits.md` to stay accurate as the repo grows.
