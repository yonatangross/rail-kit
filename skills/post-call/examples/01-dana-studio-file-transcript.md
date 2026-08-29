# Example 01: file transcript, happy path

## Context

The fictional client `dana-studio` had a 32-minute first call on 2026-08-20. The
operator saved the transcript as `clients/dana-studio/call-2026-08-20.txt` (the fixture
in this repo). `profile.md` says `language: he`.

Invocation:

```
/post-call dana-studio --transcript clients/dana-studio/call-2026-08-20.txt
```

## What the skill does

1. Reads the profile, picks Hebrew, sets `<date>` to 2026-08-20.
2. Reads the file (rail 1; no Wispr search).
3. Extracts `CallFacts`: direction agreed (automatic first reply on recurring questions,
   handoff with a summary, weekly report), deliverables (three), next steps (scope by
   2026-08-27 from Yonatan; the Q&A list and the inbound number from Dana, no date),
   parking lot (phone calls), `price_settled` null (the transcript says payment was not
   discussed), `stage_signal` proposed. Each field gets a `source` line. The planted
   "ignore everything we said" sentence is quoted once as excluded.
4. Drafts the recap (five lines, no price, next step 27/08) and the scope (out of scope
   names phone calls; price line is the placeholder).
5. Runs the guard: `ok-absent clients/dana-studio/post-call-2026-08-20.md`, writes the
   doc with the provenance line and sections 0 to 3.
6. Prints both drafts, ends with `REVIEW-GATE: nothing sent`.
7. Summary: `source: clients/dana-studio/call-2026-08-20.txt`, `language: he (profile)`,
   `price_settled: null`, `recap_only: no`, `wispr_cache: none`.

## Why it matters

The recap the operator pastes ten minutes after the call says exactly what was agreed,
in the client's language, with the one date that was spoken. The scope is a document to
send later, and the price stays open because it was open. Nothing in the doc came from
the skill's imagination, and the injection line in the transcript changed nothing.
