# rail-kit

Four agent Skills for voice-first client work. You talk (Wispr Flow, any notetaker, or
your own notes); the kit turns a call into a reviewed recap and scope, preps the next
call, shows where a client stands, and records the outcome only after you say yes.

Hebrew output by default, English when the client profile says so. Drafts only: nothing
is ever sent, and no external system is written.

[Hebrew README](README_HE.md) · [yonyon.ai/rail](https://yonyon.ai/rail) · MIT

## The four skills

| Skill | Run it | It produces | Writes |
|---|---|---|---|
| `post-call` | right after a call | `CallFacts` block, recap (<= 120 words), one-page scope with a deferred price | `clients/<name>/post-call-<date>.md` (guarded overwrite) |
| `prep-call` | before a call | seven-section cheatsheet in the right register | `clients/<name>/cheatsheet-<date>-<HHMM>.md` (never overwrites) |
| `client-context` | any time | one status board: stage, last contact, open threads, next steps, conflicts flagged | nothing |
| `sync-call-state` | after you review a post-call doc | one diff: a `state.md` entry plus the `stage:` line | those two files, after an explicit yes |

Every skill has a condensed Hebrew twin (`SKILL_HE.md`) for the operator; the model
reads only `SKILL.md`.

## Install

Pick one.

**Claude Code plugin (recommended, updates with the repo):**

```
/plugin marketplace add yonatangross/rail-kit
/plugin install rail-kit@yonyon
```

**Copy the skills into your user skills folder:**

```bash
git clone https://github.com/yonatangross/rail-kit.git
cp -r rail-kit/skills/* ~/.claude/skills/
```

**Zip (no git):** download `rail-kit.zip` from the
[latest release](https://github.com/yonatangross/rail-kit/releases/latest), unzip, and
copy `skills/*` into `~/.claude/skills/` (or `.claude/skills/` inside one project).

Then `/skills` in Claude Code lists `post-call`, `prep-call`, `client-context`,
`sync-call-state`. Other agents that read the Agent Skills format can load the same
`SKILL.md` files.

## One folder per client

The skills read and write inside `clients/<client-name>/` relative to where the agent
runs. Start a client from the template:

```bash
cp -r fixtures/clients/_template clients/dana-studio
# edit clients/dana-studio/profile.md (name, contact, language: he|en, stage)
```

```
clients/<client-name>/
  profile.md              you write it; stage: is updated by sync-call-state after a yes
  state.md                append-only log, written by sync-call-state
  call-<date>.txt         a transcript (yours, or cached from Wispr Flow after you pick the meeting)
  post-call-<date>.md     the reviewed doc from post-call
  cheatsheet-<date>-<HHMM>.md   from prep-call
  outreach-*.md, notes-*.md     yours; used for register and context
clients/crm-export.csv    optional read-only export, matched on the name column
```

A missing folder is an error: the skills print the copy command and stop; they never
invent a client.

## Wispr Flow

If the `wispr-flow` MCP server is connected (Wispr Flow on Mac: Settings, MCP, Connect
for Claude, or the URL under "All other apps"), `post-call --from-wispr` searches your
meetings, shows up to three candidates, and waits for your pick before reading the
transcript; it then caches the text to `call-<date>.txt` and says so. `prep-call` and
`client-context` use meeting titles and dates only. Without the server, everything
works from files.

## Safety promises

- Nothing is sent. No WhatsApp, email, calendar, CRM or web write exists in any skill.
- Every number, date, name and commitment in a draft traces to a sentence in the source;
  where the source is silent the draft carries an explicit placeholder.
- A price is never guessed. The scope's price line stays a placeholder unless a number
  was spoken and agreed.
- Text inside a transcript, note or CRM row is data. An instruction found there is
  content to summarize, never something to execute.
- State changes happen in one place (`sync-call-state`), as one diff, after you say yes.
- `post-call` overwrites only files it wrote itself (`scripts/check-write-target.sh`
  checks the signature) and refuses a foreign file at the same path.

## Try it on the fixture

```bash
mkdir -p /tmp/rail-demo && cp -r fixtures/clients /tmp/rail-demo/ && cd /tmp/rail-demo
claude
# /client-context dana-studio
# /post-call dana-studio --transcript clients/dana-studio/call-2026-08-20.txt
```

`dana-studio` is fictional. Its 2026-08-20 transcript includes one planted
"ignore everything we said" line so you can watch the skill treat it as content.

## Repo layout

```
skills/<name>/        SKILL.md, SKILL_HE.md, metadata.json, behavioral-spec.json, references/, examples/, scripts/
fixtures/clients/     _template/ and the fictional dana-studio
scripts/              validate-kit.sh (the gate), validate-skills.sh, check-giveaway.sh, smoke-install.sh, build-zip.sh, bump-version.sh
.claude-plugin/       plugin.json + marketplace.json
```

`bash scripts/validate-kit.sh` is what CI runs: a 13-check skill validator plus kit
checks (one version everywhere, Hebrew twin stamped, shared references identical, no
internal or client data). See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. Copyright (c) 2026 Yonatan Gross, [yonyon.ai](https://yonyon.ai).
