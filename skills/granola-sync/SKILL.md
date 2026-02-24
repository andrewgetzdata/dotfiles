---
name: granola-sync
description: This skill should be used when the user asks to "sync meetings", "sync granola", "pull meetings from granola", or wants to sync the last 7 days of Granola meetings into markdown files.
version: 2.0.0
---

# Granola sync (last 7 days)

Sync Granola meetings from the last 7 days (including today) into the `meetings/` folder as markdown files. Create new files or update existing ones matched by meetingID.

## 1. Date range

- **custom_end:** Today's date in ISO form `YYYY-MM-DD`.
- **custom_start:** Six days before today, ISO `YYYY-MM-DD`.
- That gives 7 days inclusive (e.g. 2026-01-29 to 2026-02-04).

## 2. List meetings

- Call Granola MCP **list_meetings** with:
  - `time_range`: `"custom"`
  - `custom_start`: (computed above)
  - `custom_end`: (computed above)
- Note every meeting **id**, **title**, and **date** returned.

## 3. Scan existing meetings

Before processing, read all existing `.md` files in the `meetings/` folder to understand:
- Which meetingIDs already exist (to update vs create).
- What **topics** are used across notes (to inform topic guessing for new meetings).
- The title slug conventions used (to stay consistent).

## 4. Process meetings one at a time

**IMPORTANT — Rate limit prevention:** Process each meeting **sequentially**, one at a time. Do NOT call get_meetings or get_meeting_transcript for multiple meetings in parallel. After finishing all API calls and file writes for one meeting, **wait 30 seconds** (use Bash `sleep 30`) before starting the next meeting.

Loop through the meeting IDs collected in step 2. For each meeting:

### 4.1 Fetch details and transcript

- Call **get_meetings** with `meeting_ids`: `[<this meeting's id>]`.
- Then call **get_meeting_transcript** with `meeting_id`: `<this meeting's id>`.
- These two calls for the same meeting may be made in parallel, but do NOT overlap with calls for other meetings.
- From the meeting response: keep **date**, **known_participants**, **summary** (Meeting Overview, Key Points, Next Steps). From transcript: keep the **transcript** text.

### 4.2 Find existing file (already pulled?)

- Search the `meetings/` folder for `.md` files whose **YAML frontmatter** contains `meetingID: <this meeting's UUID>`.
- If you find such a file, **update** it. If not, **create** a new file.

### 4.3 Generate filename

Use the format: `YYYY-MM-DD-slug-title.md`

- `YYYY-MM-DD` = the meeting date.
- `slug-title` = a short, descriptive kebab-case slug derived from the meeting title.
  - Lowercase, replace spaces with hyphens, remove special characters.
  - Keep it concise (3-6 words). Examples: `data-engineering-weekly`, `claude-ai-and-figma-with-parker`, `alex-savannah-context-engine`.
  - Look at existing filenames in `meetings/` for style consistency.
- If updating an existing file, **keep the existing filename** — do not rename.

### 4.4 Generate description

Write a **short, plain-text description** (one sentence) summarizing what the meeting was about, based on the summary content. Examples:
- `"Demo of Claude Code + Figma MCP integration for SAP purchase order prototype"`
- `"Weekly data engineering team standup and progress review"`

### 4.5 Generate topics

Assign **topics** as wiki-style references in `[[kebab-case]]` format. Use your best judgment based on:
- The meeting summary and transcript content.
- Topics already used in existing meeting notes (prefer reusing existing topic names).
- Common topic examples: `[[claude-code]]`, `[[figma]]`, `[[mcp]]`, `[[data-engineering]]`, `[[SAP]]`, `[[architecture]]`, `[[planning]]`.
- Assign 2-5 relevant topics per meeting.

### 4.6 Build the document

Fill the frontmatter and body as follows:

| Field | Value |
|-------|--------|
| **buckets** | `["[[Meetings]]"]` |
| **meetingID** | This meeting's UUID |
| **description** | Generated description (see 4.4) |
| **createdDate** | Meeting date only, no time: `YYYY-MM-DD` parsed from Granola's date |
| **organization** | `["[[Fountain]]"]` |
| **location** | `"Virtual"` |
| **people** | See below |
| **topics** | Generated topics (see 4.5) |

**People:** From Granola `known_participants`, take each participant's display name (the part before `(` or before `<`). Add `"[[Display Name]]"` to the people array for each, **but never include "Andrew Getz".**

**Summary:** Use the summary from **get_meetings** (Meeting Overview, Key Points, Next Steps). Keep that structure under `## Summary` in the body.

**Transcript:** Use the transcript from **get_meeting_transcript** verbatim under `## Transcript`.

### 4.7 Write the file

- **If you found an existing file** with this meetingID in frontmatter: overwrite that file with the full new content (frontmatter + Summary + Transcript).
- **If no file found:** Create a new file in the `meetings/` folder using the generated filename from step 4.3.

### 4.8 Wait before next meeting

- If there are more meetings to process, run `sleep 30` via Bash before starting the next one.
- This prevents Granola API rate limiting.

## 5. Report back

After processing all meetings, report:
- How many meetings were in range.
- Which files were **created** (path/name).
- Which files were **updated** (path/name).

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
```

Summary and Transcript content come from Granola (get_meetings summary and get_meeting_transcript).
