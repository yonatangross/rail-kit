# Example 02: cancel writes nothing, a later apply lands once, a third run proposes nothing

## Context

Same fixture as example 01: `dana-studio`, reviewed doc `post-call-2026-08-20.md`,
`profile.md` at `stage: first-call`. The operator runs the skill three times over two
days.

```
/sync-call-state dana-studio --date 2026-08-20
```

## What the skill does

Run 1, cancel. Steps 1 and 2 produce the same proposal as example 01 and the same diff.
At the gate the operator picks Cancel, because the scope date still needs a check. The
run ends with:

```
cancelled: nothing written
```

`state.md` and `profile.md` are byte-identical to before the run. No partial entry, no
stage edit, no marker file.

Run 2, apply. Next morning the operator runs the same command. Step 2 scans `state.md`
for a `2026-08-20` heading with `Source: post-call-2026-08-20.md` and finds none, because
run 1 wrote nothing. The identical diff appears. The operator picks Edit and shortens the
`Open` line to `phone calls, next phase`. The rebuilt diff shows the shorter line; the
heading and `Source:` are unchanged. The operator picks Apply. The entry lands, the stage
line becomes `proposed`, and the report ends with `external systems: none touched`.

Run 3, nothing to do. Later that day the operator runs the command again by habit.
Step 2 finds the heading `## 2026-08-20, first-call to proposed` followed by
`Source: post-call-2026-08-20.md`. The output is one line and the run stops before any
diff or question:

```
already synced: 2026-08-20, first-call to proposed
```

Both files are untouched. There is no second entry for the same doc and the stage line
is not re-edited.

## Why it matters

Cancel means cancel: a run that was refused leaves no trace, so the next run is a fresh
decision rather than a resume of a half-done one. Apply means once: the key is the entry
date plus the `Source:` line, so the same doc cannot land twice no matter how many times
the command runs, and the edited `Open` line stayed exactly as the operator typed it. A
log that can only grow by one confirmed entry per reviewed doc is a log the other skills
can trust.
