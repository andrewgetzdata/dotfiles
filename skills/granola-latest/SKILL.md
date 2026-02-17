---
name: granola-latest
description: This skill should be used when the user asks to "get latest meeting", "pull last meeting", "most recent meeting", "what was my last meeting", or wants to fetch the most recent Granola meeting.
version: 1.0.0
---

# Granola latest meeting

Fetch the most recent Granola meeting and create/update a markdown file using the Meeting Template format.

## 1. Date range

- **custom_end:** Today's date in ISO form `YYYY-MM-DD`.
- **custom_start:** Two days before today, ISO `YYYY-MM-DD`.

## 2. List meetings

- Call Granola MCP **list_meetings** with:
  - `time_range`: `"custom"`
  - `custom_start`: (computed above)
  - `custom_end`: (computed above)
- Take the **most recent** meeting by date.

## 3. Fetch details and transcript

- Call **get_meetings** with `meeting_ids`: `[<meeting id>]`.
- Call **get_meeting_transcript** with `meeting_id`: `<meeting id>`.
- From the meeting response: keep **date**, **known_participants**, **summary** (Meeting Overview, Key Points, Next Steps). From transcript: keep the **transcript** text.

## 4. Find existing file

- Search **only the root** of the workspace for `.md` files whose **YAML frontmatter** contains `meetingID: <this meeting's UUID>`.
- If you find such a file, **update** it. If not, **create** a new file.

## 5. Build the document

Use the structure of **templates/Meeting Template.md**. Fill as follows:

| Field | Value |
|-------|--------|
| **buckets** | `["[[Meetings]]"]` |
| **meetingID** | This meeting's UUID |
| **meetingType** | `"[[Granola.ai]]"` |
| **createdDate** | Meeting date only, no time: `YYYY-MM-DD` parsed from Granola's date |
| **organization** | `["[[Fountain]]"]` |
| **location** | `"Virtual"` |
| **people** | See below |
| **topics** | `[]` |

**People:** From Granola `known_participants`, take each participant's display name (the part before `(` or before `<`). Add `"[[Display Name]]"` to the people array for each, **but never include "Andrew Getz".**

**Summary:** Use the summary from **get_meetings** (Meeting Overview, Key Points, Next Steps). Keep that structure under `## Summary` in the body.

**Transcript:** Use the transcript from **get_meeting_transcript** verbatim under `## Transcript`.

## 6. Write the file

- **If you found an existing file** with this meetingID in frontmatter: overwrite that file with the full new content (frontmatter + Summary + Transcript).
- **If no file found:** Create a **new** file at the **root** of the workspace. Filename = meeting title, sanitized: remove or replace `/ \ : * ? " < > |`, trim; if empty use meeting ID or date. Extension: `.md`. If another file already exists with the same sanitized title, add a disambiguator (e.g. `Meeting title (YYYY-MM-DD).md`).

## 7. Report back

Report:
- The meeting title and date.
- Whether the file was **created** or **updated**.
- The file path.

## Reference: template structure

```yaml
---
buckets:
  - "[[Meetings]]"
meetingID: <uuid>
meetingType: "[[Granola.ai]]"
createdDate: YYYY-MM-DD
organization:
  - "[[Fountain]]"
location: "Virtual"
people: []   # e.g. ["[[Steve Johnson]]"], never Andrew Getz
topics: []
---

## Summary

### Meeting Overview

### Key Points

### Next Steps

---

## Transcript
```

Summary and Transcript content come from Granola (get_meetings summary and get_meeting_transcript).
