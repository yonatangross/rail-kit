# Register detection

Two decisions, made in this order, both printed in the second line of the sheet so the
operator can override them before the call.

## 1. Language

Precedence, first hit wins:

1. `--lang he|en` on the command line.
2. `language:` in `profile.md`.
3. The language of the client-facing body of the newest `outreach-*.md`.
4. Hebrew.

The outreach file may carry an English title or a note above the message. Judge the
message body the client received, not the wrapper. A CRM note such as "wants English" is
a hint the operator should copy into `profile.language`; the skill mentions it in the
summary but does not act on it, because the profile is the source of truth for language.

## 2. Register

Register is how the client is addressed: conversational or formal. The evidence, newest
first, is the newest `outreach-*.md` (what you already wrote to them) and the address
forms in the newest `call-*.txt` (how the two of you actually spoke). The transcript is
read for address forms only; no fact in the sheet may come from it, facts come from the
`CallFacts` block that `post-call` wrote.

Signals that read as conversational, in Hebrew: an opening with the first name, second
person singular throughout, short sentences, a direct question at the end. Signals that
read as formal: an opening with a title or full name, softeners and plural forms, no
first-name address, long sentences.

Hebrew address forms, plain lines so they copy cleanly:

Conversational opening: היי דנה
Formal opening: שלום גב' לוי
Conversational request: מתאים לך שיחה קצרה ביום רביעי?
Formal request: נשמח לתאם שיחה קצרה ביום רביעי, אם זה נוח.

Hebrew is gendered in the second person. Keep the gender the sources used for the
contact: אלייך and את in the transcript mean feminine forms in the sheet. When no source
settles it, phrase around it (plural, or a noun instead of a pronoun) rather than guess.

## 3. The respectful-direct default

With no outreach and no transcript, there is nothing to match, so the sheet uses the
respectful-direct default and says so on its second line:
`Register: respectful-direct (default, no outreach or transcript found)`.

Respectful-direct means: first name, second person singular, complete sentences, no
slang, no jokes, no exclamation marks, one request per sentence, questions that can be
answered in one breath. It is the register you would use with a professional you have met
once. It is not formal (no titles, no plural softeners) and not chummy (no nicknames, no
"hope this finds you well").

In Hebrew the default opening is the first name after היי, and every question is a
single short sentence. In English the default opening is "Hi <first name>," and the
questions follow the same rule.

## 4. English fallback

When the language resolves to English, the same register rules apply with the English
forms: conversational is first name, contractions, a direct question; formal is "Dear"
with a surname, no contractions; respectful-direct is "Hi <first name>", full sentences,
no contractions in the questions. The fixture `noa-bakery` is the reference case: its
CRM row says "wants English" and its `profile.md` says `language: en`, so the sheet is in
English; with no outreach and no transcript, the register is the respectful-direct
default and the sheet says so.

## 5. What register does not change

Headings stay in English in both languages. Trace lines, source names and the
`(default)` marker stay in English. Only the body text of each section follows the
language and register decisions.
