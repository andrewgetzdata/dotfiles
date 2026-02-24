---
name: granola-latest
description: This skill should be used when the user asks to "get latest meeting", "pull last meeting", "most recent meeting", "what was my last meeting", or wants to fetch the most recent Granola meeting.
version: 3.0.0
---

# Granola latest meeting — summary only

Fetch the most recent Granola meeting **summary** and create/update a markdown file in the `meetings/` folder. Transcripts are NOT fetched — use `/granola-sync-transcripts` separately.

## 1. Date range

- **custom_end:** Today's date in ISO form `YYYY-MM-DD`.
- **custom_start:** Two days before today, ISO `YYYY-MM-DD`.

## 2. List meetings

- Call Granola MCP **list_meetings** with:
  - `time_range`: `"custom"`
  - `custom_start`: (computed above)
  - `custom_end`: (computed above)
- Take the **most recent** meeting by date.

## 3. Scan existing meetings

Read all existing `.md` files in the `meetings/` folder to understand:
- Which meetingIDs already exist (to update vs create).
- What **topics** are used across notes (to inform topic guessing).
- The title slug conventions used (to stay consistent).

Also read **`granola_helper.json`** (at the vault root, same level as `web_urls.json`) if it exists.

## 4. Fetch details (summary only)

- Call **get_meetings** with `meeting_ids`: `[<meeting id>]`.
- Do **NOT** call get_meeting_transcript — transcripts are handled by `/granola-sync-transcripts`.
- From the meeting response: keep **date**, **known_participants**, **summary** (Meeting Overview, Key Points, Next Steps).

## 5. Find existing file

- Search the `meetings/` folder for `.md` files whose **YAML frontmatter** contains `meetingID: <this meeting's UUID>`.
- If you find such a file, **update** it. If not, **create** a new file.

## 6. Generate filename

Use the format: `YYYY-MM-DD-slug-title.md`

- `YYYY-MM-DD` = the meeting date.
- `slug-title` = a short, descriptive kebab-case slug derived from the meeting title.
  - Lowercase, replace spaces with hyphens, remove special characters.
  - Keep it concise (3-6 words). Examples: `data-engineering-weekly`, `claude-ai-and-figma-with-parker`, `alex-savannah-context-engine`.
  - Look at existing filenames in `meetings/` for style consistency.
- If updating an existing file, **keep the existing filename** — do not rename.

## 7. Generate description

Write a **short, plain-text description** (one sentence) summarizing what the meeting was about, based on the summary content. Examples:
- `"Demo of Claude Code + Figma MCP integration for SAP purchase order prototype"`
- `"Weekly data engineering team standup and progress review"`

## 8. Generate topics

Assign **topics** as wiki-style references in `[[kebab-case]]` format. Use your best judgment based on:
- The meeting summary content.
- Topics already used in existing meeting notes (prefer reusing existing topic names).
- Common topic examples: `[[claude-code]]`, `[[figma]]`, `[[mcp]]`, `[[data-engineering]]`, `[[SAP]]`, `[[architecture]]`, `[[planning]]`.
- Assign 2-5 relevant topics per meeting.

## 9. Build the document

Fill the frontmatter and body as follows:

| Field | Value |
|-------|--------|
| **buckets** | `["[[Meetings]]"]` |
| **meetingID** | This meeting's UUID |
| **description** | Generated description (see step 7) |
| **createdDate** | Meeting date only, no time: `YYYY-MM-DD` parsed from Granola's date |
| **organization** | `["[[Fountain]]"]` |
| **location** | `"Virtual"` |
| **people** | See below |
| **topics** | Generated topics (see step 8) |

**People:** From Granola `known_participants`, take each participant's display name (the part before `(` or before `<`). Add `"[[Display Name]]"` to the people array for each, **but never include "Andrew Getz".**

**Summary:** Use the summary from **get_meetings** (Meeting Overview, Key Points, Next Steps). Keep that structure under `## Summary` in the body.

**Transcript placeholder:** Add a `## Transcript` section with the text `*Transcript not yet synced. Run /granola-sync-transcripts to pull transcripts.*`

## 10. Write the file

- **If you found an existing file** with this meetingID in frontmatter: update the frontmatter and Summary section. **Preserve the existing Transcript section if it has real content** (i.e. don't overwrite a real transcript with the placeholder).
- **If no file found:** Create a new file in the `meetings/` folder using the generated filename from step 6.

## 11. Update granola_helper.json

Read or create `granola_helper.json` at the vault root (same level as `web_urls.json`). Update the entry for this meeting:

```json
{
  "meetings": {
    "<meetingID-uuid>": {
      "title": "Meeting title from Granola",
      "date": "YYYY-MM-DD",
      "file": "meetings/YYYY-MM-DD-slug-title.md",
      "status": "summary_synced"
    }
  }
}
```

- If the meeting already has `"transcript_synced"`, do NOT downgrade — leave it.
- Otherwise set to `"summary_synced"`.

## 12. Report back

Report:
- The meeting title and date.
- Whether the file was **created** or **updated**.
- The file path.
- The granola_helper.json status for this meeting.

## Reference: template structure

```yaml
---
buckets:
  - "[[Meetings]]"
meetingID: <uuid>
description: Short plain-text summary of the meeting
createdDate: YYYY-MM-DD
organization:
  - "[[Fountain]]"
location: Virtual
people: []   # e.g. ["[[Steve Johnson]]"], never Andrew Getz
topics: []   # e.g. ["[[claude-code]]", "[[figma]]"]
---

## Summary

### Meeting Overview

### Key Points

### Next Steps

---

## Transcript

*Transcript not yet synced. Run /granola-sync-transcripts to pull transcripts.*
```

Summary content comes from Granola (get_meetings summary). Transcripts are synced separately via `/granola-sync-transcripts`.
