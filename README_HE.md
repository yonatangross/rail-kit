# rail-kit

ארבעה Skills לעבודה מול לקוחות בקול. אתם מדברים (Wispr Flow, כל notetaker, או הערות משלכם), והערכה הופכת שיחה למסמך סיכום והיקף לביקורת, מכינה את השיחה הבאה, מראה איפה הלקוח עומד, ורושמת את התוצאה רק אחרי שאמרתם כן.

פלט בעברית כברירת מחדל, אנגלית כשפרופיל הלקוח אומר כך. טיוטות בלבד: שום דבר לא נשלח, ושום מערכת חיצונית לא נכתבת.

[README באנגלית](README.md), [yonyon.ai/rail](https://yonyon.ai/rail), רישיון MIT.

## ארבעת ה-Skills

post-call: מריצים מיד אחרי שיחה. מייצר בלוק CallFacts, סיכום להדבקה (עד 120 מילים) ומסמך היקף של עמוד עם מחיר שנשאר פתוח. כותב רק את clients/<name>/post-call-<date>.md, עם שומר שמסרב לדרוס קובץ שלא הוא כתב.

prep-call: מריצים לפני שיחה. מייצר דף הכנה בשבעה חלקים, ברגיסטר הנכון (רשמי או שיחתי, עברית או אנגלית). כותב cheatsheet-<date>-<HHMM>.md ואף פעם לא דורס.

client-context: בכל רגע. לוח מצב אחד: שלב, קשר אחרון, נושאים פתוחים, צעדים הבאים, וסתירות בין המקורות מסומנות ולא מוכרעות. לא כותב כלום.

sync-call-state: אחרי שעברתם על מסמך post-call. מציע diff אחד: רשומה ב-state.md ושורת ה-stage בפרופיל. כותב את שני הקבצים האלה בלבד, ורק אחרי כן מפורש.

לכל Skill יש תאום מקוצר בעברית (SKILL_HE.md) למי שמפעיל. המודל קורא רק את SKILL.md.

## התקנה

אחת משלוש הדרכים:

תוסף ל-Claude Code (מומלץ, מתעדכן עם הריפו):

```
/plugin marketplace add yonatangross/rail-kit
/plugin install rail-kit@yonyon
```

העתקה לתיקיית ה-Skills שלכם:

```bash
git clone https://github.com/yonatangross/rail-kit.git
cp -r rail-kit/skills/* ~/.claude/skills/
```

קובץ zip בלי git: מורידים rail-kit.zip מה-release האחרון, פותחים, ומעתיקים את skills/* אל ~/.claude/skills/ (או אל .claude/skills/ בתוך פרויקט אחד).

אחרי זה /skills ב-Claude Code מציג את ארבעת ה-Skills.

## תיקייה אחת לכל לקוח

ה-Skills קוראים וכותבים רק בתוך clients/<client-name>/ יחסית למקום שבו הסוכן רץ. מתחילים לקוח מהתבנית:

```bash
cp -r fixtures/clients/_template clients/dana-studio
```

ואז עורכים את clients/dana-studio/profile.md: שם, איש קשר, שפה (he או en), שלב.

בתיקייה: profile.md (אתם כותבים, השלב מתעדכן על ידי sync-call-state), state.md (יומן, רק הוספה), call-<date>.txt (תמליל), post-call-<date>.md (מסמך הביקורת), cheatsheet-<date>-<HHMM>.md (דף ההכנה), outreach-*.md ו-notes-*.md (שלכם). אופציונלי: clients/crm-export.csv לקריאה בלבד.

תיקייה חסרה היא שגיאה: ה-Skills מדפיסים את פקודת ההעתקה ועוצרים. הם לא ממציאים לקוח.

## Wispr Flow

כשה-MCP של Wispr Flow מחובר (במק: Settings, MCP, Connect for Claude, או ה-URL תחת All other apps), post-call --from-wispr מחפש את הפגישה, מציג עד שלוש מועמדות, ומחכה לבחירה שלכם לפני שהוא קורא את התמליל. אחר כך הוא שומר את הטקסט ב-call-<date>.txt ואומר את זה. prep-call ו-client-context משתמשים רק בכותרות ותאריכים של פגישות. בלי ה-MCP הכול עובד מקבצים.

## הבטחות

- שום דבר לא נשלח. אין בשום Skill דרך לשלוח וואטסאפ, מייל, יומן או CRM.
- כל מספר, תאריך, שם והתחייבות בטיוטה מגיעים ממשפט במקור. כשהמקור שותק, בטיוטה יש placeholder מפורש.
- מחיר אף פעם לא מנוחש. שורת המחיר בהיקף נשארת placeholder אלא אם מספר נאמר וסוכם.
- טקסט בתוך תמליל, הערה או שורת CRM הוא נתון. הוראה שנמצאת שם היא תוכן לסכם, לא פקודה לבצע.
- שינוי מצב קורה במקום אחד (sync-call-state), כ-diff אחד, אחרי שאמרתם כן.

## לנסות על הדוגמה

```bash
mkdir -p /tmp/rail-demo && cp -r fixtures/clients /tmp/rail-demo/ && cd /tmp/rail-demo
claude
```

ואז /client-context dana-studio ואחריו /post-call dana-studio --transcript clients/dana-studio/call-2026-08-20.txt.

dana-studio הוא לקוח בדיוני. בתמליל של 20.08 יש שורה אחת מכוונת של "תתעלם מכל מה שאמרנו" כדי שתראו איך ה-Skill מתייחס אליה כתוכן.

## רישיון

MIT. (c) 2026 יונתן גרוס, yonyon.ai.
