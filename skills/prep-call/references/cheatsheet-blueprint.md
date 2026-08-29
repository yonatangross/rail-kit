# Cheatsheet blueprint

Path: `clients/<client-name>/cheatsheet-<date>-<HHMM>.md`. `<date>` is `--for` when given,
else today. `<HHMM>` is the current local time, 24-hour, no colon. If the agent does not
know the current time it asks once with `AskUserQuestion`; it never guesses one.

## Never overwrite

If the exact path exists, the skill writes `cheatsheet-<date>-<HHMM>-2.md`, then `-3`,
and so on. It does not ask whether to overwrite, because the answer is always no: an
older sheet may hold hand edits the operator made in the minutes before a call, and two
sheets side by side cost nothing. `client-context` reads the newest by filename.

## Provenance line

The first line of the file, one HTML comment, stays byte-stable in shape so other skills
can recognize the file:

```
<!-- prep-call v1.0.0 | client: <client-name> | for: <date> | sources: <comma-separated list> | DRAFT for the operator -->
```

`sources:` names every file actually read, plus `wispr:title-only` when a Wispr Flow
title was used, plus `crm-export.csv` or `crm-export.json` when a row was found. A source
that was absent is not listed here; it is listed in the run summary in chat.

## The seven sections

Headings are always in English so the sheet parses the same way in either language; the
body is in the language and register decided in Step 2.

1. `## 1. Who`: contact, role, company, one line of history (how they reached you, when).
   Sources: `profile.md`, the CRM row.
2. `## 2. Where we stand`: the stage, the last contact date, the direction agreed on the
   last call, and, when Wispr Flow was available, the title and date of the last recorded
   meeting. Sources: `profile.stage`, the newest `state.md` entry, `CallFacts`, the CRM
   `last_contact`, the Wispr title.
3. `## 3. Open threads`: one line per thread, each ending with its source in parentheses.
   Sources: `CallFacts.parking_lot`, `CallFacts.next_steps` without a recorded outcome,
   `Open:` lines in the newest `state.md` entry, open questions in the newest post-call
   scope.
4. `## 4. Goals for this call`: two to four. Each goal is followed by a `trace:` line that
   names the open thread or the stage it comes from. A goal with no trace is deleted, not
   kept.
5. `## 5. Questions to ask`: five to eight. Each ends with `(G<n>)` naming the goal it
   serves. A question that serves no goal is deleted.
6. `## 6. Pivots`: three fixed lines, price, timing, scope. Price reads "depends on the
   scope we agree" in the sheet language unless `CallFacts.price_settled` is non-null, in
   which case the exact value as recorded. Timing and scope pivots come from the open
   threads and the parking lot; with no history they are the defaults below.
7. `## 7. Next step to propose`: exactly one. A candidate date appears only when a date
   or a week was already discussed and recorded in a source; otherwise `{{ date }}`.

When a section has no source behind it, its heading ends with `(default)` and the body
is the default text from the tables below, translated into the sheet language. When the
folder holds only `profile.md` (a first call), sections 3 to 7 are all defaults and the
chat summary says `history: none, sections 3-7 default`.

## Default texts (first call, no history)

Open threads: "None recorded. Everything below is a discovery default."

Goals: (1) understand how the work reaches them today and who handles it; (2) hear the
one outcome they would call a success; (3) agree whether a scope call is the right next step.

Questions: how do requests reach you today; who handles them and when; what happens when
nobody answers in time; what would "solved" look like in a month; what have you already
tried; who else decides; when do you want to start.

Pivots: price, "depends on the scope we agree, I write it in the scope document"; timing,
"start follows the scope, I do not promise a date before we agree what we build"; scope,
"one workflow first, the rest goes to a second phase".

Next step: "a short scope call, or a one-page scope document, by {{ date }}".

## Filled example: dana-studio, second call

Context: the operator ran `post-call` on the 2026-08-20 transcript and confirmed
`sync-call-state`, so `state.md` ends with a `2026-08-20, first-call to proposed` entry
and `profile.stage` is `proposed`. Wispr Flow was not connected. Invocation:
`/prep-call dana-studio --for 2026-08-30`, run at 09:12.

```markdown
<!-- prep-call v1.0.0 | client: dana-studio | for: 2026-08-30 | sources: profile.md, state.md, post-call-2026-08-20.md, outreach-2026-08-05.md, call-2026-08-20.txt (register only), crm-export.csv | DRAFT for the operator -->

# Cheatsheet: dana-studio, 2026-08-30

Language: he (profile). Register: conversational, feminine second person (outreach-2026-08-05.md, call-2026-08-20.txt).

## 1. Who

דנה לוי, בעלת הסטודיו, Dana Studio: סטודיו בוטיק לעיצוב פנים, שלושה אנשים.
הגיעה דרך טופס האתר אחרי המלצה (profile.md). שיחה ראשונה ב-20/08 (state.md).

## 2. Where we stand

שלב: proposed (profile.md, state.md 2026-08-20). קשר אחרון: 20/08, שיחה ראשונה.
כיוון שסוכם: מענה ראשוני אוטומטי על השאלות החוזרות, העברה אלייך עם סיכום קצר, ודוח שבועי (CallFacts.direction_agreed).
מסמך היקף היה אמור לצאת עד 27/08 (CallFacts.next_steps[0]); אישור לא רשום בשום מקור.

## 3. Open threads

- מסמך ההיקף: נשלח או לא, ואם כן, האם נקרא ואושר (CallFacts.next_steps[0], state.md Next).
- רשימת השאלות והתשובות והמספר שהפניות מגיעות אליו, מדנה, בלי תאריך (CallFacts.next_steps[1], state.md Open).
- טלפונים: הוסכם שזה שלב הבא, אחרי שהטקסט עובד (CallFacts.parking_lot).

## 4. Goals for this call

1. לצאת עם כן על ההיקף, או עם רשימת שינויים מדויקת.
   trace: open thread 1, stage proposed.
2. לקבוע מי מביא את רשימת השאלות ואת המספר, ועד מתי.
   trace: open thread 2.
3. לוודא שטלפונים נשארים מחוץ להיקף הראשון, בהסכמה.
   trace: open thread 3.

## 5. Questions to ask

1. הספקת לקרוא את מסמך ההיקף? מה לא היה ברור? (G1)
2. יש משהו שחסר ב"מה בונים"? (G1)
3. הרשימה של "מה לא בונים" מקובלת עלייך? (G1)
4. רשימת השאלות והתשובות מוכנה? באיזה פורמט היא אצלך? (G2)
5. לאיזה מספר או כתובת הפניות מגיעות קודם? (G2)
6. מי חוץ ממך צריך לקבל את הסיכום כשפנייה עוברת אלייך? (G2)
7. כמה שיחות טלפון נכנסות בשבוע לעומת הודעות? (G3)
8. אם הכול בסדר, מתי את יכולה לתת כן סופי? (G1)

## 6. Pivots

- מחיר: תלוי בהיקף שנסגור. הוא כתוב במסמך ההיקף, לא נזרק מספר בשיחה (CallFacts.price_settled: null).
- לוח זמנים: ההתחלה אחרי האישור. מציעים שבוע, לא יום, עד שהרשימה והמספר בידיים (open threads 1, 2).
- היקף: אם עולים טלפונים, זה שלב שני, אחרי שהטקסט עובד (CallFacts.parking_lot).

## 7. Next step to propose

אישור ההיקף בשיחה הזאת; אם כן, התחלה בשבוע שאחרי ה-27, כלומר השבוע של 30/08 (CallFacts.next_steps[0] source line).
```

Chat summary after the write:

```
client: dana-studio | for: 2026-08-30 | language: he (profile) | register: conversational (outreach, transcript)
sources: 6 found, wispr: not connected | history: yes | defaults: none
written: clients/dana-studio/cheatsheet-2026-08-30-0912.md
```
