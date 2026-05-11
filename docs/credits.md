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
- `_agent-operating-manual` — the spine, the five-phase model, and
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

## What's not (yet) credited

If this repo evolves to include skills derived from other public
prompts, papers, or open-source agent toolkits, they go here. A skill
without a clear lineage gets noted as "original to this repo."

The intent is for `credits.md` to stay accurate as the repo grows.
