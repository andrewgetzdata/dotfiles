# /save-context — Save Session Context

Save a summary of the current conversation to `agent-context/` so future sessions can pick up where this one left off.

## Procedure

### 1. Summarize the session

Review the current conversation and extract:
- **Title**: A short descriptive title for the session (3-8 words)
- **What was worked on**: Key tasks, features, or problems addressed
- **Decisions made**: Architectural choices, user preferences, approach decisions
- **Files created or modified**: List of files changed with brief description of changes
- **Current state**: Where things stand now — what's done, what's in progress
- **Open threads**: Anything unfinished, blocked, or deferred for later
- **Key context**: Important details a future session would need (e.g., "user prefers X over Y", "this API requires Z")

### 2. Write the context file

Save to `agent-context/YYYY-MM-DD-descriptive-title.md` using today's date and a lowercase-hyphenated version of the session title.

```markdown
---
description: one-line summary of the session
topics:
  - "[[topic]]"
date: YYYY-MM-DD
---

# Session title

## What Was Done
- Bullet points of completed work

## Decisions Made
- Key decisions and reasoning

## Files Changed
- `path/to/file.md` — what changed and why

## Current State
Where things stand. What's working, what's not.

## Open Threads
- Anything unfinished or deferred
- Next steps if the user continues this work

## Key Context
Important details for future sessions to know.
```

### 3. Confirm

Report the filename and a one-line summary of what was saved.

## Notes

- Keep it concise — this is for future TARS sessions, not a full transcript
- Focus on decisions and state over blow-by-blow of what happened
- If multiple sessions happen on the same day, append a short disambiguator to the filename (e.g., `2026-02-19-tars-setup` and `2026-02-19-article-processing`)
- Link to relevant vault notes with [[wiki-links]] where useful
