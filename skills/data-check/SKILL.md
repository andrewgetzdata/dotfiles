---
name: data-check
description: Validate and fill missing properties across all meeting notes. Use when the user asks to "check meetings data", "validate meeting notes", "data check", or wants to ensure all meetings/ notes have consistent, complete frontmatter.
version: 1.0.0
---

# Data check — meetings property validation

Scan all meeting notes in the `meetings/` folder, verify that every note has the same set of properties and that all properties are filled. Attempt to fill missing values and ask the user to confirm before writing.

## 1. Define the canonical schema

Every meeting note must have exactly these frontmatter properties:

```yaml
buckets:        # Array of wiki-refs, e.g. ["[[Meetings]]"]
meetingID:      # UUID string
description:    # Short plain-text summary (non-empty)
createdDate:    # YYYY-MM-DD
organization:   # Array of wiki-refs, e.g. ["[[Fountain]]"]
location:       # String, e.g. "Virtual"
people:         # Array of wiki-refs, e.g. ["[[Person Name]]"]
topics:         # Array of wiki-refs, e.g. ["[[topic-name]]"]
```

**Properties that should NOT be present** (remove if found):
- `meetingType` — deprecated, remove from any note that has it.

## 2. Read all meeting notes

- Read every `.md` file in the `meetings/` folder.
- Parse the YAML frontmatter from each file.
- Collect the set of topics used across all notes (for reuse suggestions).

## 3. Identify issues

For each note, check:

1. **Missing properties:** Any canonical property not present in frontmatter.
2. **Empty properties:** Properties that exist but are empty (`""`, `[]`, `null`, or missing value).
3. **Extra properties:** Any property not in the canonical schema (e.g. `meetingType`).
4. **Filename format:** Filename should match `YYYY-MM-DD-slug-title.md`. Flag files that don't match.

## 4. Attempt to fill missing/empty values

For each issue found, attempt a best-guess fill:

| Property | How to fill |
|----------|-------------|
| **buckets** | Default: `["[[Meetings]]"]` |
| **meetingID** | Cannot generate — flag as error if missing |
| **description** | Read the Summary section of the note body and write a one-sentence plain-text description |
| **createdDate** | Parse from filename date prefix if possible |
| **organization** | Default: `["[[Fountain]]"]` — adjust if context suggests otherwise (e.g. personal meeting) |
| **location** | Default: `"Virtual"` |
| **people** | Parse from note body/transcript if available — use `[[Display Name]]` format, exclude "Andrew Getz" |
| **topics** | Infer from the note's summary/transcript content. Reuse existing topics from other notes where applicable. Use `[[kebab-case]]` format. Assign 2-5 topics. |

For **extra properties** like `meetingType`: propose removal.

## 5. Present changes for confirmation

Display a clear summary of all proposed changes, grouped by file:

```
## meetings/2026-02-23-example-meeting.md
- ADD description: "Weekly sync on data pipeline progress"
- ADD topics: ["[[data-engineering]]", "[[planning]]"]
- REMOVE meetingType: "[[Granola.ai]]"
- FILL location: "Virtual" (was empty)
```

If no issues are found for any file, report that all notes are clean.

**Ask the user to confirm** before applying any changes. Present all changes at once and wait for approval.

## 6. Apply changes

After user confirmation:
- Update each file's frontmatter with the approved changes.
- Preserve the note body (Summary + Transcript) exactly as-is.
- Ensure consistent YAML formatting (no trailing spaces, proper quoting).

## 7. Report

After applying:
- How many files were scanned.
- How many files had issues.
- How many files were updated.
- Any files with unresolvable issues (e.g. missing meetingID).
