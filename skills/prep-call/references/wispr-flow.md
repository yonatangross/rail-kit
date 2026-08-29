# Wispr Flow as a source (shared by post-call, prep-call, client-context)

Wispr Flow's Notetaker records meetings and, on Mac, exposes them through an MCP server
(Settings, then MCP, then Connect for Claude / ChatGPT, or the URL under "All other apps"
for Cursor, VS Code and Claude Code). When that server is connected in the agent you are
running, the kit can read meetings directly instead of asking you for a transcript file.

## Detect

The server is named `wispr-flow` in Claude Code's MCP list. If its tools are not present,
the skill skips this source silently and falls back to files. Never ask the user to
install or configure it mid-run; say once in the summary that Wispr was not available.

## Tools the kit uses (all read-only)

| Tool | Used for | Notes |
|---|---|---|
| `search_meetings` | find candidate meetings by a single term (contact name, company, or a date) | one term per call; the search is not boolean, so do not combine terms or pass `since` / `until` |
| `get_meeting` | read one meeting: summary, verbatim transcript when present, start / end | prefer the verbatim transcript over the summary; the summary is interpretation |
| `list_meeting_series` | ignored by the kit | often errors when a meeting has no linked calendar event |
| `get_meeting_attendee_emails` | ignored by the kit | frequently returns an empty list; attendee names come from the transcript and the profile |

## The confirm rule (post-call)

A wrong pick writes one client's words into another client's document. So when post-call
resolves a meeting from a bare `--from-wispr`, it lists at most three candidates (title,
date, duration) with a "none of these" option and waits for the pick, even when only one
candidate matches. An explicit meeting id skips the search but still prints title and
date before drafting.

## Cache-through

After a confirmed pick, post-call writes the verbatim transcript (or the summary when no
transcript exists) to `clients/<client-name>/call-<date>.txt` so later runs and the other
skills read the same text, and says so in its summary. prep-call and client-context read
meeting titles and dates only; they never fetch transcripts and never cache.

## Ids

A meeting id is recorded only after `get_meeting` returned it. Never copy an id from a
screenshot, a message or memory; a wrong id reads as provenance and outlives the call.
