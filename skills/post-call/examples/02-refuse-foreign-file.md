# Example 02: the guard refuses a hand-written doc

## Context

Before adopting the kit, the operator wrote their own notes by hand at
`clients/dana-studio/post-call-2026-08-20.md`. It has a title and a few bullets and no
provenance line. Later they run:

```
/post-call dana-studio --transcript clients/dana-studio/call-2026-08-20.txt
```

## What the skill does

Steps 1 to 4 run normally and both drafts exist in memory. At Step 5 the guard runs:

```
$ bash "$S/scripts/check-write-target.sh" clients/dana-studio/post-call-2026-08-20.md
refuse-foreign clients/dana-studio/post-call-2026-08-20.md
$ echo $?
3
```

The skill does not Write. It does not try `post-call-2026-08-20-2.md` either, because
the deterministic path is what `sync-call-state` and `client-context` read. It prints
both drafts in chat so nothing is lost, then asks: move the hand-written file aside, or
give a different `--date`, or stop. The summary line reads
`doc: not written (refuse-foreign)` and the run still ends at `REVIEW-GATE`.

## Why it matters

"Same client, same date, overwrite" is the right contract when the skill owns the file
and data loss when it does not. The Write step cannot tell those apart, so the guard
decides first, and the only signal it trusts is the signature the skill itself writes.
An `error` verdict (rc 2) is treated the same way: not "safe", stop and ask.
