# Example 01: first-call to proposed after an agreed direction

## Context

The fictional client `dana-studio` had a first call on 2026-08-20. `post-call` wrote
`clients/dana-studio/post-call-2026-08-20.md`, the operator read it and pasted the recap.
`profile.md` still says `stage: first-call`, and `state.md` holds one entry from
2026-08-01 (`lead to first-call`). The `CallFacts` block in the doc has
`stage_signal: "proposed"`, a `direction_agreed`, two next steps (scope by 2026-08-27 from
Yonatan; the Q&A list and the inbound number from Dana, no date) and `parking_lot`
holding phone calls.

Invocation:

```
/sync-call-state dana-studio --date 2026-08-20
```

## What the skill does

1. Finds the folder, opens the doc, sees DRAFTS ONLY on line 1 and a JSON block under
   `## 0. Call facts`. Reads the current stage `first-call` and the one existing entry.
   The transcript file sits in the same folder and is not opened.
2. Scans `state.md` for a `2026-08-20` heading with `Source: post-call-2026-08-20.md`;
   none. `stage_signal` is `proposed`, valid and different from `first-call`, so the
   proposal is a change entry plus a stage edit.
3. Prints the diff and asks:

```
--- clients/dana-studio/state.md
+++ clients/dana-studio/state.md
@@ -8,3 +8,9 @@
 Next: first call, Yonatan, 2026-08-20
 Open: which channel the leads arrive on; who answers today
+
+## 2026-08-20, first-call to proposed
+Source: post-call-2026-08-20.md
+Direction: automatic first reply on recurring questions, handoff with a short summary, weekly report
+Next: send one-page scope, Yonatan, 2026-08-27
+Open: phone calls, next phase; prepare the Q&A list and the inbound number (Dana)
--- clients/dana-studio/profile.md
+++ clients/dana-studio/profile.md
@@ -8 +8 @@
-stage: first-call
+stage: proposed
```

   Options: Apply, Edit, Cancel. The operator picks Apply.

4. Appends the entry to `state.md`, edits the one `stage:` line, and reports:

```
client: dana-studio
date: 2026-08-20
source: post-call-2026-08-20.md
state.md: appended "2026-08-20, first-call to proposed"
profile.md: stage first-call to proposed
external systems: none touched
```

`state.md` now ends with the new entry; the 2026-08-01 entry is byte-identical to
before. `profile.md` differs from before in exactly one line.

## Why it matters

The next time `client-context` or `prep-call` opens this folder, the stage says
`proposed`, the promised next step has a date, and the phone-calls topic is still on
record as open. The operator saw every changed line before it landed, edited none of
them, and never had to remember to update a second file. The state moved because the
doc said so, in the words the doc used, and nowhere else.
