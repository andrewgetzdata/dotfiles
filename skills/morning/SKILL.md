# /morning — Focus the Day

Start the day with a clear picture of what's ahead and what matters.

## Procedure

### 1. Check today's calendar

Use Google Calendar MCP tools:
1. `get-current-time` to confirm the date
2. `list-events` for today — show all meetings, blocks, and commitments
3. Note any prep needed for upcoming meetings

### 2. Check today's tasks

Use Todoist MCP tools:
1. `find-tasks-by-date` with startDate "today" to get today's tasks (includes overdue)
2. Group by project — highlight priorities (p1/p2)

### 3. Check pending knowledge work

1. Read `web_urls.json` — count pending URLs
2. Scan `inbox/` for any new drops
3. Report: "X articles queued for processing"

### 4. Review yesterday's journal

Read `journal/` for yesterday's entry (if it exists). Pull forward any open threads or unfinished items.

### 5. Create today's journal entry

If `journal/YYYY-MM-DD.md` doesn't exist yet, create it using the daily template:

```markdown
---
tags:
  - daily
gratitudeHabit:
exerciseHabit:
journalHabit:
people:
places:
---



![[Daily.base#Daily notes]]
```

### 6. Write schedule into the daily note

After creating (or confirming) today's journal entry, insert the day's schedule at the top of the note body (after the frontmatter closing `---` and before `![[Daily.base#Daily notes]]`). Format:

```markdown
## Schedule
- 12:00 PM - Lunch with Jay @ Huey Magoo's
  - Jay is a close friend, casual catch-up
- 3:00 PM - Team standup
  - Prep: check Linear board for blockers
```

Rules:
- Each event is a bullet: `- HH:MM AM/PM - <Event summary>`
- Below each event, indent a sub-bullet with any helpful context: location details, attendee info, prep notes, things Tars knows that would be useful
- If no events, write `- No meetings today — open for deep work`
- Use the Edit tool to insert into the existing file, don't overwrite

### 7. Write priority tasks into the daily note

After the schedule section, add a `## Tasks` section with the highest priority tasks as checkboxes. Format:

```markdown
## Tasks
- [ ] Connect with Dad
- [ ] Connect with Mom
- [ ] Ship feature X
```

Rules:
- Include all p1 and p2 tasks first, then overdue recurring tasks (house chores, connections)
- Cap at ~10 items — this is a focused daily list, not a full backlog dump
- Use `- [ ]` checkbox format so they can be checked off in Obsidian
- Use the Edit tool to insert after the Schedule section

### 8. Present the morning brief

Print a concise overview:
- **Calendar**: Today's schedule at a glance
- **Top tasks**: Priority items for the day
- **Knowledge queue**: Pending articles/bookmarks
- **Carried forward**: Anything from yesterday that needs attention
- **Suggestion**: One recommended focus area or action

Keep it brief and actionable — this is a launchpad, not a report.

## Tools Used

- Google Calendar MCP: get-current-time, list-events
- Todoist MCP: find-tasks-by-date
- Read, Write, Glob (file operations)
