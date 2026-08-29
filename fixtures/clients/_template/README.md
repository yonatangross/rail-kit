# One client folder

Copy this folder to `clients/<client-name>/` (kebab-case) and fill `profile.md`.
The four skills read and write only inside that folder, plus an optional
read-only `clients/crm-export.csv` next to it.

| File | Written by | Read by |
|---|---|---|
| `profile.md` | you; `stage:` updated by sync-call-state after a yes | all four |
| `state.md` | sync-call-state (append-only) | client-context, prep-call, post-call |
| `call-<date>.txt` | you, or post-call when it caches a Wispr Flow meeting (it says so) | post-call |
| `post-call-<date>.md` | post-call (deterministic path, guarded overwrite) | sync-call-state, client-context, prep-call |
| `cheatsheet-<date>-<HHMM>.md` | prep-call (never overwrites) | client-context |
| `outreach-*.md`, `notes-*.md` | you | prep-call (register), client-context |

A missing folder is an error, never created implicitly: every skill stops and
prints the copy command instead of inventing a client.
