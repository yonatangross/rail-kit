# Example 01: second call with history, Hebrew, conversational register

## Context

The fictional client `dana-studio` had a first call on 2026-08-20. The operator ran
`post-call` on that transcript, reviewed the doc, and said yes to `sync-call-state`, so
the folder now holds `post-call-2026-08-20.md` with a `CallFacts` block, a `state.md`
entry `2026-08-20, first-call to proposed`, and `profile.stage: proposed`. The next call
is set for Sunday 2026-08-30 at ten. The `wispr-flow` server is not connected.

Invocation, run on the morning of the call at 09:12:

```
/prep-call dana-studio --for 2026-08-30
```

## What the skill does

1. Reads `profile.md` (language `he`, contact Dana Levi, owner), the newest `state.md`
   entry, the `CallFacts` block of `post-call-2026-08-20.md`, `outreach-2026-08-05.md`,
   `call-2026-08-20.txt` for address forms only, and the `dana-studio` row of
   `crm-export.csv`. Reports six sources found and Wispr not connected.
2. Language: Hebrew from the profile. Register: conversational, feminine second person,
   because the outreach opens with the first name and asks a direct question, and the
   transcript addresses her as את and אלייך.
3. Fills the seven sections. Open threads are the three items with a source: the scope
   sent but with no recorded approval (`next_steps[0]`), the Q&A list and the inbound
   number owed by Dana (`next_steps[1]`, the `Open:` line in `state.md`), and phone calls
   parked for a later phase (`parking_lot`). The three goals map onto those three
   threads, each with a `trace:` line. Eight questions, each tagged with its goal. The
   price pivot reads "depends on the scope we agree" because `price_settled` is null. The
   next step is scope approval on this call, with the start week as the candidate date
   because the 20/08 call recorded "the week after the 27th".
4. Writes `clients/dana-studio/cheatsheet-2026-08-30-0912.md` with the provenance line,
   then prints the sheet and the summary line. The full sheet is the filled example in
   `references/cheatsheet-blueprint.md`.

## Why it matters

The operator opens the call knowing the three things that are actually open and the one
answer they need, in the same voice they have used with Dana since the first message. No
goal exists that the folder cannot justify, so nothing on the sheet surprises the client
with a commitment that was never made. The planted "ignore everything we said" line from
the 20/08 transcript changes nothing here either: prep-call takes facts from `CallFacts`,
not from the transcript, and `post-call` already excluded it.
