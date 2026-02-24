---
name: granola-sync-transcripts
description: This skill should be used when the user asks to "sync transcripts", "pull transcripts", "granola transcripts", or wants to fetch and append Granola meeting transcripts to existing meeting notes.
version: 1.0.0
---

# Granola sync transcripts

Fetch Granola meeting transcripts for meetings that have summaries but no transcripts yet. Uses `granola_helper.json` to track which meetings need transcripts. Processes one meeting at a time with a **2-minute wait** between each to avoid rate limiting.

## 1. Read granola_helper.json

Read `granola_helper.json` from the vault root (same level as `web_urls.json`).

If the file does not exist, report that no meetings are tracked yet and suggest running `/granola-sync` first. Stop.

## 2. Identify meetings needing transcripts

Filter `granola_helper.json` entries to find all meetings with `"status": "summary_synced"`. These are the meetings that need transcripts.

If none are found, report that all meetings are fully synced. Stop.

Report how many transcripts need to be pulled and list them (title + date).

## 3. Process each meeting sequentially

**CRITICAL — One at a time, 2-minute waits.** For each meeting with `"status": "summary_synced"`:

### 3.1 Fetch transcript

- Call **get_meeting_transcript** with `meeting_id`: `<the meetingID>`.
- This is the **only** Granola API call needed — the summary is already in the file.

### 3.2 Read the existing file

- Read the file at the path stored in `granola_helper.json` → `file` field for this meeting.
- Parse the file to locate the `## Transcript` section.

### 3.3 Replace transcript placeholder

- Replace everything under `## Transcript` (including the placeholder text `*Transcript not yet synced...*`) with the actual transcript content from Granola.
- Preserve everything above `## Transcript` (frontmatter, Summary section) exactly as-is.

### 3.4 Write the updated file

- Write the file back with the transcript appended.

### 3.5 Update granola_helper.json

- Set this meeting's status to `"transcript_synced"`.
- Write the updated `granola_helper.json` immediately (so progress is saved even if the skill is interrupted).

### 3.6 Clear context and wait

- After writing the file and updating the helper JSON, **clear all unnecessary context** — you do not need to retain the transcript content in memory for subsequent meetings.
- If there are more meetings to process, run `sleep 120` via Bash (2 minutes) before starting the next one.
- This extended wait prevents Granola API rate limiting on transcript endpoints.

## 4. Report back

After processing all meetings (or if interrupted), report:
- How many transcripts were pulled.
- Which files were updated (path/name).
- How many meetings still need transcripts (if any remain).
- Current granola_helper.json status counts.
