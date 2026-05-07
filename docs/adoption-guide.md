# Adoption guide

For someone who just cloned this repo and wants to use it, customise
it, or contribute back.

## Install on a new machine

```bash
git clone https://github.com/sqidermad/agents-maxxing.git ~/Developer/agents-maxxing
cd ~/Developer/agents-maxxing
./install.sh
make doctor
```

`make doctor` should print every skill linked to both Cursor and
Codex. If a tool is missing (e.g., you don't use Codex), `install.sh`
will say so and skip — that's expected.

## Verify it's working

In Cursor: open chat, ask the agent to do something that should
trigger a skill (e.g., "review my latest commit"). The agent should
follow `review-stance`: findings first, severity ordered, file/line
grounded.

In Codex: same idea — give it a task that activates the trigger map.

If the agent isn't reading the skills, run `make doctor`. The output
should show every skill `cursor:linked codex:linked`.

## Customise

You can edit any skill in place:

```bash
$EDITOR skills/answer-shape-discipline/SKILL.md
```

Because the install uses symlinks, your edit is immediately visible
to every agent. To share the change:

```bash
git add skills/answer-shape-discipline/SKILL.md
git commit -m "answer-shape: relax 70-line cap for code-heavy answers"
git push
```

## Skip a skill you don't want

Two options:

**Temporary** — uninstall just that one skill manually:

```bash
rm ~/.cursor/skills-cursor/<skill-name>
rm ~/.codex/skills/<skill-name>
```

The next `./install.sh` run will recreate it. So this is good for
"I'm trying without it for one session."

**Permanent** — fork the repo, delete the skill folder under `skills/`,
push to your fork, install from your fork. This is what teams who
don't want the frontend opinions should do.

## Add a new skill

```bash
mkdir skills/my-new-skill
$EDITOR skills/my-new-skill/SKILL.md
```

`SKILL.md` must start with YAML frontmatter that has a `description`
field. The description is what tools surface when deciding whether to
load the skill. Make it precise and trigger-rich:

```markdown
---
description: One-sentence description that includes the verbs and contexts that should trigger this skill.
---

# My new skill

## When to use

Bullet list of specific trigger situations.

## What to do

Numbered list of steps.

## Examples

Concrete before/after pairs.
```

After creating it:

```bash
./install.sh
```

This adds the symlink for the new skill. No need to re-link the others.

If you think the skill is generally useful, open a PR.

## Contribute back

PRs welcome. Ground rules:

1. **One skill, one PR.** Mixing changes makes review hard.
2. **Trigger-grounded descriptions.** A skill nobody triggers is dead
   code. The frontmatter `description` decides whether tools load it.
3. **No vendor coupling.** Don't write skills that assume Cursor or
   Codex specifically. Use neutral language ("the agent", "the tool").
4. **No model coupling.** Don't write skills that assume Claude vs
   GPT vs Gemini. The whole point is portability.
5. **No org-specific naming.** "Use lodash" is fine. "Use our
   internal `@cerflux/utils`" is not.
6. **Keep skills tight.** A skill that runs to 800 lines is rarely
   read end-to-end. Aim for 100–250 lines. Split if you cross 400.
7. **Update the trigger map** in `_agent-operating-manual/SKILL.md`
   if your skill introduces a new trigger.
8. **Update `docs/credits.md`** if your skill is derived from
   somewhere — base prompts, papers, internal docs (sanitised).

## Stay in sync

```bash
make pull
```

Pulls main and re-runs the installer. Safe to run repeatedly; it
won't duplicate links or clobber other tools' skills.

## Uninstall

```bash
./uninstall.sh
```

Removes only the symlinks this repo created. Leaves vendor-shipped
skills, the repo itself, and any backups (`<name>.backup-<timestamp>`)
intact.

## Questions to ask before forking

- Are the disciplines aligned with how my team works, or do I need to
  swap a few out?
- Do I want to add team-specific skills (style guides, deployment
  rules, naming conventions)?
- Do I want to keep the master `_agent-operating-manual` as-is, or
  rewrite the spine to reflect a different workflow?

A fork that answers these honestly is more valuable than a copy that
doesn't.
