# /prep — URL Intake

Collect URLs from inbox/ files, Todoist "TARS" project, and recent Granola meetings. Queue them in web_urls.json.

## Procedure

### 1. Scan inbox/ folder

Use Glob to find all files in `inbox/`. For each file:
- Read the file contents
- Extract any URLs (look for http/https links)
- Determine type from tags in the file:
  - `#ai-clip` → type: clip (full extraction)
  - `#ai-bookmark` → type: bookmark (metadata only)
  - No tag → default to clip
- Add each URL to web_urls.json (see schema below)
- Delete the inbox file after extracting its URLs

### 2. Check Todoist "TARS" project

Use Todoist MCP tools:
1. `find-projects` to find the "TARS" project
2. `find-tasks` to get open tasks in that project
3. For each task containing a URL:
   - Extract the URL from the task content (usually a markdown link)
   - Determine type from Todoist labels:
     - `ai-clip` label → type: clip (full extraction)
     - `ai-bookmark` label → type: bookmark (metadata only)
     - No label → default to clip
   - Add to web_urls.json with source: "todoist"
   - Complete the Todoist task with `complete-tasks`

### 3. Pull last 7 days of Granola meetings

Use Granola MCP tools:
1. `list_meetings` to get meetings from the last 7 days
2. For each meeting, check if already synced by searching `meetings/` for a file containing the Granola meeting ID in its frontmatter (`granola_id` field). Skip if found.
3. For each new meeting:
   - `get_meetings` to get the full meeting details (notes, summary)
   - `get_meeting_transcript` to get the full verbatim transcript
   - Save to `meetings/YYYY-MM-DD-meeting-title.md` with frontmatter:
     ```markdown
     ---
     granola_id: "abc123"
     description: one-line meeting summary
     topics:
       - "[[topic]]"
     date: YYYY-MM-DD
     attendees:
       - "[[Person Name]]"
     ---
     ```
   - Include meeting summary/notes in the body
   - After a `---` separator, include the full transcript under a `## Transcript` heading
   - Create/update `people/` notes for attendees if they don't exist
4. Report which meetings were synced

### 4. Report

Print a summary: how many URLs were queued (by type and source), how many meetings were synced.

## web_urls.json Schema

When adding a URL entry:

```json
{
  "url": "https://example.com/article",
  "title": "",
  "type": "clip",
  "status": "pending",
  "source": "inbox",
  "date_added": "2026-02-19",
  "date_processed": null
}
```

- `title`: Leave empty on intake — /process fills it from Firecrawl metadata
- `type`: "clip" (extract insights) or "bookmark" (metadata only)
- `source`: "inbox", "todoist", or "granola"
- `status`: Always "pending" on intake
- `date_added`: Today's date in YYYY-MM-DD
- `date_processed`: null until /process handles it

## Deduplication

Before adding a URL, check if it already exists in web_urls.json. Skip duplicates and note them in the report.

For Granola meetings, search `meetings/` files for matching `granola_id` in frontmatter. Skip if already synced.

## Tools Used

- Glob, Read, Write (file operations)
- Bash (only if needed for file deletion)
- Todoist MCP: find-projects, find-tasks, complete-tasks
- Granola MCP: list_meetings, get_meetings, get_meeting_transcript
