---
name: failure-surfacing
description: >-
  Stop silent retry loops. When a tool, command, or operation fails
  repeatedly with the same error, surface the failure to the user with
  context and options instead of retrying invisibly. Applies to tool
  flakes, sandbox denials, network errors, auth failures, and any
  repeated-failure pattern.
---

# Failure Surfacing

The user cannot help with a problem they cannot see. A frozen agent
silently retrying the same failed call is worse than an agent that
stops, explains the situation, and asks for direction.

## When to invoke

The trigger is repetition, not the first failure. One retry is fine.
Two is fine if the second failure looks transient (e.g. a different
error message). Three identical failures = stop and surface.

Specifically:

- A tool returns the same error 3+ times in a row.
- A shell command fails 3+ times with what looks like the same
  underlying issue (sandbox denial, missing binary, auth expired).
- A network operation hangs / times out repeatedly.
- A test or build fails the same way after multiple "fix" attempts.
- Any operation where you find yourself thinking "let me just try one
  more time."

## What to do when triggered

Stop. Send a single clear status message to the user with three
parts:

1. **What's failing.** Name the operation, paste the actual error, no
   euphemism. "ReadFile is returning 'Tool failed; this may be
   temporary' on every call for the past 90 seconds."
2. **What you've tried.** Brief — one or two lines. "Retried 4× over
   90s with backoff; sanity-checked with a different file (same
   failure)."
3. **What you need.** Concrete options the user can choose between,
   or a specific question. Examples:
   - "Want me to wait longer, or hand this back to you?"
   - "I can proceed with the partial result I have if you're OK with
     X being unverified."
   - "This looks like a sandbox restriction — want me to retry with
     elevated permissions?"

Keep it short. The user is already mid-context-switch from waiting;
don't make them read a wall of text.

## What NOT to do

- **Don't keep retrying silently.** The user sees no output and
  assumes you're working on something. You're not.
- **Don't pretend it's fine.** "Let me try a different approach" when
  the underlying tool is broken is a lie that wastes more cycles.
- **Don't claim partial success.** If the verify step couldn't run,
  say so. Don't mark the work green.
- **Don't escalate the action without surfacing.** Switching from
  ReadFile → Shell `cat` to dodge a tool flake is fine *after* you
  surface it; doing it silently hides the system fault from the user
  and from your own retry counter.

## Failure modes this catches

- **Tool flakes.** ReadFile / Shell / Grep returning a generic
  "temporary failure" repeatedly. Most common. Real cause is usually
  upstream backend; user can decide whether to wait or take over.
- **Sandbox denials.** A command keeps failing with permission errors
  and you keep tweaking the command. Surface it; the user can grant
  the permission or refactor the approach.
- **Auth expiration.** `gh` calls failing with 401. Tell the user;
  they can refresh.
- **Missing binaries.** A test runner not installed. Tell the user;
  they may want to install it, or ask you to skip that verify step.
- **Network unreachables.** Allowlist deny on a host. Same pattern.

## Test for whether to surface

Ask: "If the user could see exactly what I'm doing right now, would
they be frustrated I haven't told them?" If yes — surface it.

The cost of one paragraph of "here's where I am, here's what's
broken, here's what I need" is always less than the cost of the user
watching a frozen output for two more minutes.

## Cross-references

- `dirty-worktree-etiquette` — surface conflicts before resolving
  unilaterally.
- `agent-operating-manual` Phase 4 — "If you couldn't run a
  verification step, say so honestly." This skill is the operational
  half of that rule.
