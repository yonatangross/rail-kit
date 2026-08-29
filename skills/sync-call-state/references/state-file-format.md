# state.md entry format

`clients/<client-name>/state.md` is the client's append-only log. `fixtures/clients/_template/state.md`
carries the header and the entry shape; this file pins the grammar so every writer
(this skill, or the operator by hand) produces entries the readers can parse.

## Grammar

```
## YYYY-MM-DD, <old stage> to <new stage>
Source: <file name in the client folder>
Direction: <one line>
Next: <what>, <who>, <by when>
Open: <item>; <item>
```

- The heading is `## `, an ISO date, a comma, then either `<old> to <new>` or
  `<stage> (no change)`. Stage words come from the same list `profile.md` uses:
  `lead`, `first-call`, `proposed`, `active`, `paused`, `closed`.
- Exactly four labelled lines follow, in this order, each `Label: value` on one line.
- `Source:` names a file in the same folder (`post-call-<date>.md` when written by
  sync-call-state; hand entries may name `outreach-*.md` or `notes-*.md`).
- `Next:` is `<what>, <who>, <by when>`; `by when` is an ISO date or `no date`.
- `Open:` items are separated by `; `. `none` when there is nothing.
- Entries are separated by one blank line. The newest entry is the last one in the file.
- Lines are copied from the source verbatim, in whatever language the source used.

## Example: stage change

```
## 2026-08-20, first-call to proposed
Source: post-call-2026-08-20.md
Direction: automatic first reply on recurring questions, handoff with a short summary, weekly report
Next: send one-page scope, Yonatan, 2026-08-27
Open: phone calls, next phase; prepare the Q&A list and the inbound number (Dana)
```

Alongside this entry, `profile.md` changes from `stage: first-call` to `stage: proposed`.

## Example: no change

A follow-up call on 2026-09-03 where the client asked two questions about the scope and
nothing moved (`stage_signal` null in the doc):

```
## 2026-09-03, proposed (no change)
Source: post-call-2026-09-03.md
Direction: none
Next: answer the two scope questions in writing, Yonatan, 2026-09-05
Open: start date depends on the studio calendar
```

`profile.md` is not edited. The same heading is used when `stage_signal` equals the
current stage, or when it holds a value outside the list (the run prints
`stage_signal ignored: <value>` above the diff).

## Example: already synced

Running the skill again on `post-call-2026-08-20.md` after the first example was
applied finds the heading `## 2026-08-20, first-call to proposed` followed by
`Source: post-call-2026-08-20.md`. Nothing is proposed. The output is one line:

```
already synced: 2026-08-20, first-call to proposed
```

No diff, no gate, no write. The pair (heading date, `Source:` line) is the idempotency
key; a hand-written entry with the same pair counts as synced too.

## How the other skills read this file

- `client-context` shows the last entry as the current position (its `Next:` and
  `Open:` lines) and lists earlier headings as the timeline. It takes the stage from
  `profile.md`, not from the last heading, and flags a mismatch between the two.
- `prep-call` reads the last entry's `Next:` to know what was promised and its `Open:`
  to seed the open-questions part of the cheatsheet. With `/effort high`, this skill
  carries unresolved `Open:` items forward marked `(carried)`, so `prep-call` sees them
  without walking the whole file.
- `post-call` does not read `state.md`; it reads the transcript and `profile.md` only.

A file that breaks the grammar (a heading without four lines, a line out of order) is
reported by the readers, not repaired. This skill never rewrites earlier entries, so a
broken entry is fixed by hand.
