# Example 02: three sources, three stages, none picked

## Context

Same client, different history. After the 2026-08-20 call the operator edited
`clients/dana-studio/profile.md` by hand to `stage: proposed` while sending the scope. A
day later they ran `sync-call-state` on the post-call doc, approved its `stage_signal`,
and the log got `## 2026-08-20, first-call to active`; the profile edit was overwritten
in neither direction because the operator declined that part of the diff. The CRM export
in `clients/crm-export.csv` is from before the call and still says `lead`. Today is
2026-08-29.

Invocation:

```
/client-context dana-studio
```

## What the skill does

Steps 1 to 3 run as in example 01. Step 4 finds three stage candidates that disagree.
The board's Stage section becomes:

```markdown
## Stage
profile.md: proposed
state.md (newest entry, 2026-08-20): active
crm-export.csv: lead
Verdict: CONFLICT, three sources, three values. Reconcile with sync-call-state.
```

Everything else renders as usual: last contact, direction agreed, open threads, next
steps, sources. The run still ends with `CONTEXT-RENDERED: read-only, nothing written`.

What it does not do, on purpose:

- It does not print `active` because the log is newer or "more authoritative".
- It does not print `proposed` because the profile is what the operator typed last.
- It does not drop `lead` because the export is stale; the age of the export is not
  something the skill can know from the row.
- It does not edit any of the three files, and it has no tool that could.

If the operator answers "she is active, fix it", the skill points to `sync-call-state`,
which shows a diff of the profile line and waits for a yes.

## Why it matters

A stage disagreement is the most common silent defect in a client folder: each file was
right when it was written, by a different hand, and the folder as a whole has no single
truth. A skill that silently picks the newest value turns that defect into a confident
wrong answer that outlives the call. Showing all three values with their sources costs
one screen line each and makes the reconciliation a thirty-second decision by the one
person who knows what happened.
