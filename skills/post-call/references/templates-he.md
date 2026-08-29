# Hebrew templates

Fill-in shapes for the two drafts when the output language is `he`. Placeholders are
`{{ }}`; every one is filled from `CallFacts` or left as an explicit placeholder. The
English equivalent follows the same sections.

## Recap (WhatsApp / chat, plain text, at most 120 words)

```
היי {{ contact_name }}, תודה על השיחה היום.
הבנתי שהכיוון הוא {{ direction_agreed }}.
סיכמנו על {{ workflow_picked }}.
הצעד הבא: {{ next_step_what }} עד {{ next_step_date }}.
נדבר,
{{ your_name }}
```

Rules: no price, no links, no numbered lists. Four to six lines. If the call was warm,
one emoji at most.

## Scope (one page)

```
היקף עבודה: {{ client_display_name }}
תאריך: {{ call_date }}

מטרה
{{ goal_one_sentence }}

ה-Workflow שנבחר
{{ workflow_picked }}

מה כלול
{{ deliverable_1 }}
{{ deliverable_2 }}
{{ deliverable_3 }}

מה לא כלול
{{ out_of_scope_1 }}
{{ parking_lot_items }}

מה נדרש מכם
{{ client_provides_1 }}
{{ client_provides_2 }}

לוח זמנים
שבוע 1: {{ week_1 }}
שבוע 2: {{ week_2 }}

תנאי קבלה
{{ acceptance_1 }}
{{ acceptance_2 }}

שאלות פתוחות
{{ open_question_1 }}

מחיר
{{ price: לסיכום בשיחה }}
```

Rules: the price line stays a placeholder unless `price_settled` is non-null; then the
exact number as spoken. No tax framing, no ranges. Timeline relative unless the call
fixed dates.
