# /wrap-up — End of Workday

Close out the workday with a summary of what happened and clear handoff for tomorrow.

## Procedure

### 1. Review today's activity

1. Check Todoist: `find-tasks-by-date` for today — what was completed vs still open
2. Check today's calendar events — which meetings happened
3. Read today's journal entry if it exists — what was captured throughout the day
4. Check `web_urls.json` for any articles processed today

### 2. Sync new meetings

Run the Granola meeting sync (same as /prep step 3):
1. `list_meetings` for meetings from the last 7 days
2. Sync any new meetings not already in `meetings/` (check by `granola_id`)
3. Save with full transcript, create/update people notes

### 3. Check for inbox items

Scan `inbox/` and Todoist "TARS" project for any URLs dropped during the day. Add to `web_urls.json` if found (same as /prep steps 1-2).

### 4. Update today's journal

Append a wrap-up section to today's `journal/YYYY-MM-DD.md`:

```markdown
## Wrap-up
- **Completed**: tasks/work finished today
- **In progress**: what's actively being worked on
- **Blocked**: anything stuck and why
- **Tomorrow**: top 1-3 priorities for the next day
```

### 5. Save session context

Run `/save-context` to capture the current session state.

### 6. Present the wrap-up

Print a concise summary:
- What got done today
- Meetings synced
- New articles queued
- Top priorities for tomorrow

## Tools Used

- Todoist MCP: find-tasks-by-date, find-projects, find-tasks, complete-tasks
- Granola MCP: list_meetings, get_meetings, get_meeting_transcript
- Google Calendar MCP: list-events
- Read, Write, Edit, Glob (file operations)
- Skill: save-context
