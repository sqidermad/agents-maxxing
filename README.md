# agents-maxxing

A portable operating system for AI coding agents.

> So that we don't work twice.

`agents-maxxing` is a curated set of agent skills + a master operating
manual that codifies how an agent should think and work to deliver
quality results: meeting requirements, considering edges, staying
concise, matching industry practice, while being effective and
efficient.

The system installs into both **Cursor** (`~/.cursor/skills-cursor/`)
and **Codex** (`~/.codex/skills/`) so any model behind either tool —
Claude, GPT, Gemini, future ones — sees the same disciplines.

## What's inside

A spine + seven phase-specific disciplines:

- **`_agent-operating-manual`** — the spine. Five-phase workflow
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
- **`answer-shape-discipline`** — final-answer brevity. 70-line cap.
  Prose for small tasks. No filler metaphors. No anti-comparison
  rhetoric.

## Quick install

```bash
git clone https://github.com/sqidermad/agents-maxxing.git ~/Developer/agents-maxxing
cd ~/Developer/agents-maxxing
./install.sh
```

The installer **symlinks** each skill into both Cursor and Codex
skill folders. Editing a skill from anywhere — the repo, the Cursor
folder, the Codex folder — updates the same file. One source of truth.

To install for only one tool:

```bash
./install.sh --cursor   # only Cursor
./install.sh --codex    # only Codex
```

To verify install:

```bash
make doctor
```

To uninstall (removes symlinks; doesn't delete repo):

```bash
./uninstall.sh
```

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
