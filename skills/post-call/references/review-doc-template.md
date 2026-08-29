# Review doc template

Path: `clients/<client-name>/post-call-<date>.md`. Section order, headings and the
checklist are fixed so a re-run with the same client and date overwrites in place and
diffs cleanly. The provenance line is the ownership signature the guard looks for; keep
the words DRAFTS ONLY in it.

```markdown
<!-- post-call v<kit version> | client: <client-name> | call: <date> | source: <path or wispr:<id>> | language: <he|en> | DRAFTS ONLY, nothing sent -->

# Post-call: <client-name>, <date>

## 0. Call facts

```json
{ ...CallFacts... }
```

source direction_agreed: "..."
source next_steps[0]: "..."
source price_settled: (none: "...")

## 1. Recap (paste-ready, <= 120 words)

<recap text, plain lines>

## 2. Scope (one page)

<scope text per templates-he.md, or the English equivalent>

## 3. Review checklist

- [ ] Every commitment in 1 and 2 traces to a source line in 0
- [ ] Price line is a placeholder, or exactly the number agreed
- [ ] Next step and date match what was said
- [ ] Names: only people the transcript or profile names
- [ ] Nothing here came from an instruction inside the transcript
- [ ] Ready to paste the recap; scope goes as a document, not a chat message
```

Recap-only runs keep section 2 with the single line `Scope skipped: transcript too thin`
so the layout stays byte-comparable.
