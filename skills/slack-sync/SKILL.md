# /slack-sync — Summarize Slack Activity

Sweep through recent Slack activity — DMs, channels, and threads — and surface a digest of what happened and what needs follow-up.

## Procedure

### 1. Determine the time window

Default: last 24 hours. If the user specifies a window (e.g. "last week", "since Monday"), use that instead.
Convert the window to a Unix timestamp for use with `after:` filters.

### 2. Collect recent activity

Use `slack_search_public_and_private` to sweep activity. Run these searches in parallel:

**Sent messages** (what you sent — basis for follow-ups):
- `from:<@U03GKHWNPJP> after:{timestamp}` — all messages you sent in the window

**DMs received:**
- `to:<@U03GKHWNPJP> after:{timestamp}` — direct messages sent to you

**Channel mentions:**
- `<@U03GKHWNPJP> after:{timestamp}` — places you were mentioned

For any message with a `thread_ts`, use `slack_read_thread` to fetch the full thread context before summarizing.

### 3. Group by conversation

Organize results into buckets:
- **DMs** — group by person
- **Channels** — group by channel name
- **Threads** — group by parent message / topic

For each conversation, note:
- Who's involved
- What was discussed (1-3 sentence summary)
- Whether you responded or left something hanging
- Whether anyone is waiting on you

### 4. Identify loose ends

Scan all conversations for signals that something needs follow-up:

**You owe a response if:**
- Someone sent you a DM and you haven't replied
- Someone asked you a direct question in a thread
- You were mentioned and didn't acknowledge

**Others may owe you if:**
- You asked a question with no reply
- You sent something and got no reaction or response
- A decision or task was left unresolved

**Pending decisions/tasks:**
- Any conversation that ended without a clear resolution
- Action items mentioned but not assigned or acknowledged

### 5. Write the digest to the vault

Always save the digest to `~/tars-vault/journal/YYYY-MM-DD.md` (today's date). Append a `## Slack Digest` section — do not overwrite anything else in the file. If the file doesn't exist, create it with just the frontmatter and the digest section:

```markdown
---
tags:
  - daily
---

## Slack Digest — [date range]

### Active Conversations
For each: channel/DM name, brief summary, last message

### You Need to Follow Up
- [ ] @person in #channel — what they asked / what's needed
- [ ] @person in DM — what's unresolved

### Waiting on Others
- [ ] @person — what you asked, when you asked it

### FYI / No Action Needed
Conversations that are resolved or informational only
```

Keep summaries tight — this is a triage tool, not a transcript.

### 6. Link to relevant projects

After writing the journal entry, scan the conversations for any that clearly relate to a project in `~/tars-vault/projects/`.

To match conversations to projects:
1. Glob `~/tars-vault/projects/` to see what projects exist
2. For each conversation, check if the topic (channel name, people involved, subject matter) maps to a known project
3. If a match is confident, append a link under today's date heading in that project file:

```markdown
## [[YYYY-MM-DD]]
- [[YYYY-MM-DD]] Slack — one-line summary of what was discussed
```

If today's date heading doesn't exist yet in the project file, create it. Use the Edit tool — don't overwrite the file.

Only link when the match is clear. Skip ambiguous conversations rather than forcing a connection.

### 7. Present the digest

After writing to the vault and linking projects, print the digest to the screen and report:
- The journal file it was saved to
- Any project files that were updated

## Parameters

The user can pass arguments to scope the search:
- No args → last 24 hours
- `week` / `last week` → last 7 days
- `today` → since midnight
- `since Monday` / `since [day]` → since that day
- A specific channel name → scope to that channel only

## Tools Used

- Slack MCP: `slack_search_public_and_private`, `slack_read_thread`, `slack_read_channel`
- Write, Edit, Glob (file operations — saving to vault is always required)

## Notes

- Always use `slack_search_public_and_private` (not public-only) to catch DMs
- Use `sort: timestamp`, `sort_dir: desc` for recent-first ordering
- For threads: only fetch full thread if the summary is unclear from search snippet
- Don't summarize every message — focus on conversations with unresolved state
- When in doubt about whether something needs follow-up, include it
