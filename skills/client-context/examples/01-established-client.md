# Example 01: an established client, all sources agree

## Context

The fictional client `dana-studio` had a first call on 2026-08-20. The operator ran
`post-call`, which wrote `clients/dana-studio/post-call-2026-08-20.md`, then reviewed the
doc and ran `sync-call-state`, which appended `## 2026-08-20, first-call to proposed` to
`state.md` and set `stage: proposed` in `profile.md`. The CRM export was refreshed after
that change, so the `dana-studio` row also says `proposed`. A short call on 2026-08-27
left `call-2026-08-27.txt` in the folder. Today is 2026-08-29 and the `wispr-flow`
server is not connected.

Invocation:

```
/client-context dana-studio
```

## What the skill does

1. Finds `clients/dana-studio/`, sets today to 2026-08-29, no `--since` bound.
2. Reads `profile.md`, both entries of `state.md`, the call facts block and the recap of
   `post-call-2026-08-20.md`, and `outreach-2026-08-05.md`. Globs `call-2026-08-20.txt`
   and `call-2026-08-27.txt` for their dates and opens neither.
3. Finds the `dana-studio` row in `clients/crm-export.csv` (`stage: proposed`,
   `last_contact: 2026-08-20`). Sees no `wispr-flow` tools and moves on.
4. Stage: three values, all `proposed`, verdict `agreed`. Last contact: the newest date
   is 2026-08-27 from the filename `call-2026-08-27.txt`, 2 days old, fresh.
5. Renders the board:

```markdown
# client-context: dana-studio (2026-08-29)

Name: dana-studio | Company: Dana Studio (fictional) | Contact: Dana Levi (owner) | Language: he | Channel: whatsapp

## Stage
profile.md: proposed
state.md (newest entry, 2026-08-20): proposed
crm-export.csv: proposed
Verdict: agreed

## Last contact
2026-08-27, call-2026-08-27.txt (filename only) (2 days ago). fresh

## Direction agreed
(post-call-2026-08-20.md, call facts)
automatic first reply on recurring questions, handoff with a short summary, weekly report

## Open threads
- phone calls, next phase (parking lot, post-call-2026-08-20.md)
- which channel the leads arrive on; who answers today (Open, state.md 2026-08-01)
- Dana to confirm the Q&A list owner (Open, state.md 2026-08-20)

## Next steps
- send one-page scope, Yonatan, by 2026-08-27 (post-call-2026-08-20.md) [past]
- prepare the Q&A list and the inbound number, Dana, no date (post-call-2026-08-20.md)
- scope review call, Yonatan, 2026-08-31 (state.md 2026-08-20)

## Sources consulted
- profile.md: read
- state.md: 2 entries
- post-call-*.md: post-call-2026-08-20.md (call facts and recap)
- cheatsheet-*.md: none
- outreach-*.md: outreach-2026-08-05.md (whatsapp, sent)
- notes-*.md: none
- call-*.txt: 2026-08-20, 2026-08-27 (dates by filename)
- crm-export.csv: row found
- wispr-flow: not connected

CONTEXT-RENDERED: read-only, nothing written
```

## Why it matters

Before a follow-up the operator needs four answers: which stage, when was the last touch,
what was agreed, what is owed. The board gives all four in one screen, and every line
says where it came from, so a doubt is a one-file check rather than a hunt. The `[past]`
marker on the scope step is the one thing the operator most often forgets, surfaced
without being judged. The transcript of the 27th was never opened; its date was enough.
