# Example 02: first call, English, respectful-direct default

## Context

The operator met Noa at a meetup and created `clients/noa-bakery/` from the template. The
folder holds a filled `profile.md` (`contact: Noa`, `company: Noa Bakery`, `stage: lead`,
`language: en`, a one-paragraph note) and the untouched `state.md` header. There is no
outreach file, no transcript, no post-call doc. `clients/crm-export.csv` has the row
`noa-bakery,lead,yonatan,2026-08-12,noa@example.invalid,met at a meetup; wants English`.
A first call is booked for tomorrow.

Invocation:

```
/prep-call noa-bakery --for 2026-09-02
```

## What the skill does

1. Reads `profile.md` and the CRM row. Reports two sources found; `state.md` has no
   entries; no outreach, no transcript, no post-call doc; Wispr not connected.
2. Language: English from `profile.language`. Register: nothing to match, so the sheet's
   second line reads `Register: respectful-direct (default, no outreach or transcript found)`.
3. Sections 1 and 2 come from the profile and the CRM row (Who: Noa, owner, Noa Bakery,
   met at a meetup on or before 2026-08-12; Where we stand: stage lead, last contact
   2026-08-12 per the CRM export). Sections 3 to 7 carry the `(default)` marker in their
   headings and hold the discovery defaults from the blueprint: no open threads recorded,
   three discovery goals, seven discovery questions, the three default pivots, and a next
   step of "a short scope call, or a one-page scope document, by {{ date }}" with the date
   left as a placeholder because no date was ever discussed.
4. Writes `clients/noa-bakery/cheatsheet-2026-09-02-1840.md`, prints it, and ends with
   the summary `history: none, sections 3-7 default`.

## Why it matters

A first call deserves a plan too, but not an invented past. Marking the default sections
keeps the operator honest about what they know and what they are guessing, and the
discovery questions are the same seven every first call needs. The CRM note "wants
English" is respected because the operator already wrote `language: en` into the profile;
the skill would have mentioned the note in its summary if the profile had said otherwise,
but it would not have switched languages on the strength of a CRM cell.
