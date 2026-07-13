# agents-maxxing

A portable operating system for AI coding agents.

> So that we don't work twice.

`agents-maxxing` is a curated set of agent skills + a master operating
manual that codifies how an agent should think and work to deliver
quality results: meeting requirements, considering edges, staying
concise, matching industry practice, while being effective and
efficient.

The system installs into **Cursor** (`~/.cursor/skills-cursor/`),
**Codex** (`~/.codex/skills/`), and **Claude Code**
(`~/.claude/skills/`) so any model behind any of these tools —
Claude, GPT, Gemini, future ones — sees the same disciplines.

## What's inside

A spine + eleven specialised disciplines:

- **`agent-operating-manual`** — the spine. Five-phase workflow
  (frame → investigate → construct → verify → communicate), the
  cross-cutting ethos, and the trigger map for every other skill.
- **`construction-discipline`** — pre-commit gate (5 checks: loop
  trace, deletion audit, symmetry audit, intent modeling, regression
  check). Catches the bugs you don't know you've shipped.
- **`scope-discipline`** — read existing patterns first, edit narrow,
  don't invent abstractions, test coverage scales with risk.
- **`frontend-design-discipline`** — opinionated UI/UX rules. No card-
  in-card. No orbs. Lucide-first. Brand-as-H1. Stable dimensions.
- **`dirty-worktree-etiquette`** — git safety. Never revert user
  changes you didn't make. No `--hard` resets without explicit ask.
  Stage explicitly.
- **`review-stance`** — when asked for a review, findings lead the
  response, severity-ordered, file/line grounded. Summary follows.
- **`continuation-sanity-check`** — after compaction or resume, verify
  you're answering the **newest** message, not a ghost goal.
- **`failure-surfacing`** — stop silent retry loops. When the same
  operation fails repeatedly, surface the failure with context and
  options instead of retrying invisibly.
- **`answer-shape-discipline`** — final-answer brevity. 70-line cap.
  Prose for small tasks. No filler metaphors. No anti-comparison
  rhetoric.
- **`resilience-bulkhead-discipline`** — production reliability guardrails
  for multi-user systems: control-plane vs heavy-plane separation,
  active-user enforcement across API surfaces, semantic error-code
  preservation, and anti-lockout admin invariants.
- **`upstream-integration-triage`** — diagnose vendor / third-party
  **HTTP/REST API** failures evidence-first. Reachability → transport
  → auth → permission → account → payload ladder. HAR redaction
  gotchas, `.env` shell-source truncation traps, and "is it our code
  or theirs" rollback decision rules. Scope is HTTP — DB / queue /
  SDK-mediated / non-HTTP integrations need different tooling (the
  skill lists them explicitly so an agent does not misapply it).
- **`twelve-rule-discipline`** — project-wide rule template (12 rules,
  caution over speed). Owns the three concepts not covered elsewhere:
  *model-vs-code split* (don't ask the LLM what a switch statement can
  answer), *hard token budgets* (per-task / per-session, surface
  breaches), and *intent-encoded tests* (tests fail for a named
  business reason, not just "got null"). Cross-references existing
  skills for the other nine rules so nothing is duplicated. Also
  carries the **"behavioral contract, not wishlist"** framing and the
  empirical **200-line CLAUDE.md ceiling** from the source research.
  Lineage: Karpathy (Jan 2026 complaint thread) →
  [Forrest Chang](https://github.com/forrestchang/andrej-karpathy-skills)
  (4-rule template) →
  [Mnilax](https://x.com/Mnilax/status/2053116311132155938) (8 more
  rules after 30 codebases / 6 weeks).

## Quick install

```bash
git clone https://github.com/sqidermad/agents-maxxing.git ~/Developer/agents-maxxing
cd ~/Developer/agents-maxxing
./install.sh
```

The installer **symlinks** each skill into the Cursor, Codex, and
Claude Code skill folders (skipping tools not installed on the
machine). Editing a skill from anywhere — the repo or any tool's
folder — updates the same file. One source of truth.

To install for specific tools only:

```bash
./install.sh --cursor   # only Cursor
./install.sh --codex    # only Codex
./install.sh --claude   # only Claude Code
```

If a tool already has a real (non-symlink) skill folder with the same
name, the installer moves it aside to `<name>.backup-<timestamp>`
before linking. Backups are never deleted; uninstalling does **not**
restore them — move one back by hand if you want it
(`mv <name>.backup-<timestamp> <name>`).

To verify install:

```bash
make doctor
```

To uninstall (removes symlinks; doesn't delete repo or backups):

```bash
./uninstall.sh
```

## Token cost

Honest accounting before you install.

**Two-tier cost model.** Cursor and Codex expose skills in two layers:

1. **Ambient (every session)** — only the YAML `description` field
   from each `SKILL.md` is loaded into the agent's available-skills
   index at session start. The agent reads it to decide *whether* to
   invoke a skill.
2. **On-demand (when triggered)** — the full skill body is loaded via
   `Read` only when the agent decides the skill applies. The other
   eleven skills stay dormant.

**Current ambient cost per skill (description only):**

| Skill | Description | Body (loaded on-demand) |
| --- | --- | --- |
| `agent-operating-manual` | 71 words | 172 lines |
| `answer-shape-discipline` | 38 words | 115 lines |
| `construction-discipline` | 42 words | 107 lines |
| `continuation-sanity-check` | 53 words | 63 lines |
| `dirty-worktree-etiquette` | 72 words | 129 lines |
| `failure-surfacing` | 44 words | 97 lines |
| `frontend-design-discipline` | 73 words | 164 lines |
| `resilience-bulkhead-discipline` | 54 words | 128 lines |
| `review-stance` | 59 words | 63 lines |
| `scope-discipline` | 42 words | 78 lines |
| `twelve-rule-discipline` | 59 words | 169 lines |
| `upstream-integration-triage` | 58 words | 209 lines |
| **Total ambient** | **~665 words ≈ ~865 tokens** | (full bodies sum to ~28K tokens, loaded selectively) |

For context: a typical Claude / GPT coding session runs **50K–200K
tokens**. The full skill index is **~0.4%–1.7% of session budget**.
The 12-rule template recommends keeping any single `CLAUDE.md`-style
file under 200 lines — skill bodies here hold to that ceiling
(`make check` warns when one crosses it; the table above is verified
against the actual files by the same check).

**Cursor's dual-folder behaviour.** Cursor scans **both**
`~/.cursor/skills-cursor/` AND `~/.codex/skills/` when both exist, so
a machine installed with the default `./install.sh` (which symlinks
into both of those) effectively doubles the ambient cost in Cursor
sessions to **~1,730 tokens**. Codex and Claude Code each read only
their own folder, so they always pay the single-tier cost. If you
only use one tool, install for only that one:

```bash
./install.sh --cursor   # Cursor only       (~865 tokens ambient)
./install.sh --codex    # Codex only        (~865 tokens ambient)
./install.sh --claude   # Claude Code only  (~865 tokens ambient)
./install.sh            # all tools found   (~1,730 tokens in Cursor)
```

**Bottom line.** At default settings, the system is not pricey:
under 2% of a typical session's budget even in dual-install mode.
The full skill bodies (which would sum to a much larger number if all
read at once) load only when the agent decides the trigger fires —
which in practice is one or two per turn, not all twelve.

## How to read the system

Start with [`docs/manifesto.md`](docs/manifesto.md) — one page on the
philosophy. Then [`docs/architecture.md`](docs/architecture.md) for
how the five-phase model works. Then
[`docs/adoption-guide.md`](docs/adoption-guide.md) if you want to add
your own skills or fork this for your own toolchain.

## Why this exists

AI coding agents are powerful but uneven. They produce great surface
work and miss invariants underneath. They build correct architectures
and skip the loop that proves the architecture is wired. They follow
patterns but invent abstractions when none are needed.

The fix is not a smarter model. It's a **system that survives the
model**. Skills written as plain markdown, symlinked into both major
tools, version-controlled in git. Edit, commit, push — every agent on
your machine inherits the change. Lose the laptop, `git clone` the
brain back.

## Status

Active. Used daily across multiple production codebases. Open to
contributions — see [`docs/adoption-guide.md`](docs/adoption-guide.md).

## Credits

See [`docs/credits.md`](docs/credits.md) for honest attribution: what
came from Codex's base prompt, what came from Cursor's skill format,
what came from real production scars.

## License

MIT. Take it. Fork it. Use it.
