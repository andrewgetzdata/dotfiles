# Granola sync (last 7 days)

Sync Granola meetings from the last 7 days (including today) into root-level markdown files using the Meeting Template. Create new files or update existing ones matched by meetingID.

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

## 3. For each meeting

Do the following for each meeting from step 2.

### 3.1 Fetch details and transcript

- Call **get_meetings** with `meeting_ids`: `[<this meeting's id>]`.
- Call **get_meeting_transcript** with `meeting_id`: `<this meeting's id>`.
- From the meeting response: keep **date**, **known_participants**, **summary** (Meeting Overview, Key Points, Next Steps). From transcript: keep the **transcript** text.

### 3.2 Find existing file (already pulled?)

- Search **only the root** of the workspace for `.md` files whose **YAML frontmatter** contains `meetingID: <this meeting's UUID>`.
- If you find such a file, **update** it. If not, **create** a new file.

### 3.3 Build the document

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

### 3.4 Write the file

- **If you found an existing file** with this meetingID in frontmatter: overwrite that file with the full new content (frontmatter + Summary + Transcript).
- **If no file found:** Create a **new** file at the **root** of the workspace. Filename = meeting title, sanitized: remove or replace `/ \ : * ? " < > |`, trim; if empty use meeting ID or date. Extension: `.md`. If another file already exists with the same sanitized title, add a disambiguator (e.g. `Meeting title (YYYY-MM-DD).md`).

## 4. Report back

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
meetingType: "[[Granola.ai]]"
createdDate: YYYY-MM-DD
organization:
  - "[[Fountain]]"
location: "Virtual"
people: []   # e.g. ["[[Steve Johnson]]"], never <Insert your full name here>
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
