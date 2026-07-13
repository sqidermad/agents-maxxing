---
name: continuation-sanity-check
description: >-
  Verify your final answer addresses the newest user request, not an
  older ghost goal. Use after any context compaction, conversation
  resume, long tool-running gap, or when the user has sent multiple
  messages in quick succession that could conflict. Guards against
  drift after the system summarises context for you.
---

# Continuation Sanity Check

When the conversation has been summarised, resumed, or interrupted —
or when you see "<Previous conversation summary>" or "<system_reminder>"
at the start of the turn — run this check before sending your final
answer.

## The check

1. Read the **last user message** verbatim. What is it asking right now?
2. Read your **planned final answer**. Does it answer that message, or
   does it answer an older goal you've been pursuing?
3. Skim the most recent ≤3 user messages. If any conflict, the newest
   wins.

## Common drift patterns

- A compaction summary lists in-flight tasks; you instinctively continue
  them; the user has actually moved on to a different question.
- The user asked "is it ready?" mid-work; you answer the older
  implementation goal instead of the readiness question.
- A long tool run finished; the user asked something else meanwhile;
  you respond about the build instead of the new question.
- You start a turn assuming the prior plan; the user has just
  redirected scope and your assumption is now stale.

## What to do when you detect drift

1. Acknowledge the newest goal explicitly in the response.
2. Either pivot to it, or — if the in-flight work is partially done —
   give a one-line status update on the in-flight work, then address
   the newest message in full.
3. Never silently ignore the newest message because you're "in the
   middle" of something.

## What it sounds like in practice

> "(Build finished, all green.) On your latest question about the env
> vars: ..."

> "Pausing the lint pass — your latest message asks about the PR
> description, which takes priority. Here's that..."

## When to invoke

- After any "<Previous conversation summary>" or compaction notice.
- After a long-running tool just completed and the user sent messages
  during the run.
- When two or more user messages in the same turn could be in tension.

Skip when: a single fresh request with no prior turns, or a
straightforward continuation of one explicit goal.
