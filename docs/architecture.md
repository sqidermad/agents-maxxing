# Architecture

How `agents-maxxing` is wired and why.

## The shape

```text
        ┌─────────────────────────────────────────────┐
        │  _agent-operating-manual (the spine)        │
        │  five-phase workflow + ethos + trigger map  │
        └───────────────────┬─────────────────────────┘
                            │
       ┌────────────────────┼────────────────────────┐
       │                    │                        │
   FRAME              INVESTIGATE / CONSTRUCT      VERIFY
   ─────              ─────────────────────       ──────
   continuation-      scope-discipline            construction-
   sanity-check       frontend-design-discipline  discipline
   answer-shape-      dirty-worktree-etiquette
   discipline                                     COMMUNICATE
                                                  ───────────
                                                  review-stance
                                                  answer-shape-
                                                  discipline
```

Eight files. One spine. Seven specialised disciplines triggered at
specific phases of the work.

## Why a spine + leaves, not a single megadocument

A single 4000-line "agent guide" is read once, ignored thereafter, and
rots in place. Smaller skills with **specific triggers** survive
because:

1. The agent reads them at the moment they're relevant. The trigger
   matches the current activity, not a hypothetical one.
2. They can be evolved independently. If `frontend-design-discipline`
   needs a rule update, that's one PR — not a mega-merge.
3. They can be turned off independently. Some teams won't want the
   frontend opinions; they can `rm` that one file.

The spine itself is small and stable: it tells you which phase you're
in and points to the right leaf.

## The five-phase model in detail

### 1. Frame

Before doing anything, answer:

- What is the user **actually** asking? (Not what an old turn asked.)
- Is this a question, a change request, a review, or a debug?
- What's the **newest** message — has the goal shifted since the last
  agent action?
- What shape should the final answer take? (Brief prose? Findings
  list? Code only? Plan?)

Skills that fire here: `continuation-sanity-check`,
`answer-shape-discipline`, parts of `_agent-operating-manual`.

### 2. Investigate

Before changing anything, learn:

- What pattern does this codebase already use for the thing you're
  about to add?
- Are there existing helpers, types, conventions you should imitate?
- What's the smallest scope that satisfies the request?

Skills that fire here: `scope-discipline`,
`_agent-operating-manual` (read-the-system rule).

### 3. Construct

Make the change. Constraints:

- Stay in scope. No drive-by refactors.
- Honor existing abstractions; don't invent new ones for one-shot
  needs.
- Match the codebase's style and naming.
- For UI work: `frontend-design-discipline`.
- For git operations: `dirty-worktree-etiquette`.

### 4. Verify

The phase most often skipped. The pre-commit gate.

`construction-discipline` runs five checks:

1. **Loop trace** — follow a representative data point from origin
   through every layer it touches to its final resting place. State
   set on Layer A and consumed on Layer C must also pass through B.
2. **Deletion audit** — when you add a new write path, did you delete
   the old one? Two writers to the same field will fight.
3. **Symmetry audit** — new state must be handled by every layer that
   handles related state. Persist? Restore? Cache? Serialize? Sync?
4. **Intent-state modeling** — distinguish system-chosen defaults
   from user-pinned choices. Async updates must not silently
   override the user.
5. **Mental-model regression check** — re-read the change with the
   architecture's invariants in mind. Are you accidentally still
   thinking in the old model?

### 5. Communicate

The final answer.

- If it was a review: `review-stance` — findings first, severity
  ordered, file/line grounded.
- For shape: `answer-shape-discipline` — line cap, prose for small
  changes, no filler metaphors, no anti-comparison rhetoric, specific
  code references.

## The trigger map

Located in [`skills/_agent-operating-manual/SKILL.md`](../skills/_agent-operating-manual/SKILL.md).
Maps observable activity → which skill to read.

Examples:

| Activity                                         | Read                              |
|--------------------------------------------------|-----------------------------------|
| About to commit a multi-layer change             | `construction-discipline`         |
| About to render a card, hero, or layout          | `frontend-design-discipline`      |
| About to run any `git` command on a dirty tree   | `dirty-worktree-etiquette`        |
| About to write a final answer to a review        | `review-stance`                   |
| Returning after `<command-message>` or compaction| `continuation-sanity-check`       |
| Drafting the closing message                     | `answer-shape-discipline`         |
| About to add a new file or abstraction           | `scope-discipline`                |

The agent doesn't read every skill on every turn. It reads the right
skill at the right moment.

## How install actually works

`install.sh` walks `skills/` and creates one symlink per skill in:

- `~/.cursor/skills-cursor/<skill-name>` → `<repo>/skills/<skill-name>`
- `~/.codex/skills/<skill-name>` → `<repo>/skills/<skill-name>`

Both Cursor and Codex follow symlinks. Both register the skills as
available based on each skill's YAML frontmatter `description`.

Existing real directories at the target are renamed to
`<name>.backup-<timestamp>` before linking, never deleted. Existing
symlinks pointing elsewhere are replaced (and the old target is left
intact since it lives elsewhere).

Vendor-shipped Cursor skills (`babysit`, `canvas`, `create-skill`,
etc.) are **not touched**. They're real directories with names that
don't collide with this repo's skills.

## How updates propagate

The user edits a skill file. Because every install location is a
symlink to the same file, every agent on the machine sees the change
**instantly**. No reload, no `make sync`, no service restart.

To share the change with other contributors:

```bash
git add skills/<name>/SKILL.md
git commit -m "tighten <skill> rule on X"
git push
```

Other contributors on other machines:

```bash
make pull   # git pull --ff-only && ./install.sh
```

Their symlinks already point at their local repo, so the pulled
change takes effect immediately.

## Where to extend

- **New skill**: add `skills/<your-skill>/SKILL.md`. Re-run
  `./install.sh`. Done.
- **New agent target** (e.g., a future tool that has its own skills
  folder): add a third `link_into` call in `install.sh`.
- **New docs**: drop in `docs/`. The README's "How to read the system"
  section lists the canonical entry points.
