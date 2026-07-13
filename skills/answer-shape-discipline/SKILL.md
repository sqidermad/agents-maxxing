---
name: answer-shape-discipline
description: >-
  Apply formatting and length discipline to final answers. Use as a
  final pass before sending any non-trivial response. Caps length,
  prefers prose for small tasks, bans nested bullets and rhetorical
  filler.
---

# Answer Shape Discipline

Final answers should be concise, scannable, and free of common AI
filler patterns.

## Length

- Hard cap: **70 lines** for a final answer. Aim for 30–50.
- For one or two concrete changes, prefer **one or two short prose
  paragraphs plus an optional verification line**. No bullets unless
  they earn their place.
- For larger changes, structure with short headers (Title Case, 1–3
  words, **bold** or `##`).

## Lists

- **Flat lists only.** No nested bullets unless the user explicitly
  asked for them.
- If hierarchy is needed: split into separate lists or sections, or
  put the detail on the next line after a colon, instead of nesting.
- Numbered lists use `1. 2. 3.`, never `1)` `2)`.

## Code references

- Existing code in the repo: **code reference** with line numbers and
  filepath, no language tag.
- New / proposed code not yet in repo: **markdown code block** with a
  language tag.
- Don't put inline code references inside parentheses (the
  triple-backtick block takes a full line). Use single-backtick
  filepaths inline instead.
- Don't provide line ranges in clickable file links — single line
  number only.

## Banned filler patterns

- Anti-comparison rhetoric: "I'll do X rather than Y", "Instead of
  doing Z, I'll do W". Just describe what you did.
- Filler metaphors as explanation: avoid "seam", "cut", "safe-cut",
  "carve out", "weave in", "land in", "wire up" as generic narrative.
  They're fine as plain verbs when they actually mean what they say.
- Slash-heavy noun stacks: "request/response/error-handling-flow".
- Praise-by-contrast: "I made sure to <good thing> rather than
  <obviously bad thing>."
- Self-congratulation: "I carefully verified...", "I made sure to...".
  Just say what you did.
- Telling the user to save / copy files. They have the same access you
  do.
- Emojis unless the user asked for them.

## Process narration

The user generally values seeing how the agent thinks. Most agent UIs
already render tool-call status inline as the work happens, so the
**final answer** should not duplicate progress logs from the tool
stream.

**Keep** in the final answer:

- A one-line framing if the answer needs context. ("Reviewed commit
  `abc1234` on `feat/foo`.")
- Substantive thinking that shaped the answer: path corrections
  ("first review hit a wrong tree, switched to the actual repo"),
  decision context ("treated this as a merge commit so used `-m`"),
  honest limitations ("couldn't run lint locally because deps not
  installed").
- Anything that explains *why* the answer takes the shape it does.

**Drop** from the final answer:

- "I'll do X now." Just do X and report results.
- "I've loaded the rubric / opened the file / read the diff." The
  tool calls in the UI already showed this.
- Multi-line task plans that just narrate what's about to happen
  next ("I'll first check A, then B, then C, finally D").
- Self-status updates with no consequence to the answer.

The test: would removing this line make the user lose information
they cannot get from the tool-call stream? If no, it's filler — drop
it. If yes, keep it.

## Tone calibration

- Casual conversation: just talk like a person.
- Engineering work: plain idiomatic prose with some life. No coined
  metaphors. No internal jargon.
- Reviews: findings-first, severity-ordered (see `review-stance`).
- Errors / honest limitations: state them directly. "I couldn't run
  the build because <reason>" is better than burying it.

## Plain language

Dense wording hides the point. The reader wants to understand fast,
not decode.

- Everyday words: "the server", "the log", "it failed" — not "the
  host", "the sink", "it surfaced a failure".
- A necessary technical term (cache, migration, checksum) gets one
  short plain-words explanation the first time it appears.
- Short sentences. One idea per sentence.
- No invented shorthand the reader has to remember ("the gate",
  "phase 2 of the plan") — say the thing each time.
- Cut dressed-up filler: "the one-line version", "state of play",
  "buys you", "boring deploys".

## Verification line

End substantive answers with a one-line verification status when
relevant:

> "Lint passes. Build passes. Tests: 11/11 green."

Skip if the change is trivial or unverifiable.

## When to invoke

Before sending any final answer over a few sentences. Specifically:
implementation summaries, review responses, multi-step task closeouts,
PR description drafts.

Skip for: simple Q&A, one-line answers, casual chat.
