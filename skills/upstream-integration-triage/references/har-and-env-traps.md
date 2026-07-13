# HAR and .env traps

Supporting reference for `upstream-integration-triage`. Read when you
are actually comparing HAR files or reproducing an `.env`-driven
failure from a shell — not needed for the ladder itself.

## HAR gotchas you must know

- **Chrome 109+ strips `Authorization` and `Cookie` from HAR exports
  by default.** Settings → Network → "Allow to generate HAR with
  sensitive data" must be on, otherwise the export looks unauth'd
  even when the live request was authenticated. Do *not* conclude
  "the working call uses no auth" from a sanitised HAR.
- **Safari WebInspector** (`creator.name == "WebInspector"`) strips
  even more aggressively. Suspect any HAR whose creator field is
  Safari/WebInspector.
- Useful underscored fields Chrome adds: `_initiator`,
  `_resourceType`, `_priority`, `_transferSize`. They tell you which
  JS code initiated the call and whether the response was cached.
- `cf-ray`, `cf-cache-status`, `alt-svc: h3=` headers prove the
  request actually crossed Cloudflare. Their absence on the failing
  call means you might be bypassing the edge.

## .env-file shell hygiene

The number-one false-positive when reproducing failures from a shell:

- `set -a; source .env.local; set +a` parses each line **as a bash
  command**. Values containing spaces, `=`, or quotes get truncated
  or lost. `KEY=Basic abc=` becomes `KEY=Basic`.
- **Systemd's `EnvironmentFile=`** reads the whole line as the value,
  no shell parsing. So a service running under systemd may see the
  full value while your interactive `source` sees a broken one. *Do
  not* conclude "the env is wrong for the service" from your shell.
- **Python's `python-dotenv`** behaves like systemd, full line.
- Fix: quote values with spaces in the .env file
  (`KEY='Basic abc='`). Then `source` and `EnvironmentFile=` agree.
- Diagnostic: `echo "len=${#KEY}"` — if the length is suspiciously
  short, you've been truncated.
