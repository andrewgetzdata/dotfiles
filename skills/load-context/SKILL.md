---
name: load-context
description: "Load project context from the TARS vault into the current session. Use when the user asks to 'load context', 'pull project context', or wants to resume work on a named project."
version: 1.0.0
argument-hint: [project name or phrase]
---

# /load-context — Load Project Context

Pull the relevant project and its associated notes from `~/tars-vault/` into the current session so you can immediately resume work with full context.

## Procedure

### 1. Identify the project

Take the phrase or project name from the skill argument. Match it against the project files in `/Users/andrewgetz/tars-vault/projects/`. Use fuzzy matching — e.g., "context engine" matches `context-engine.md`, "source mlops" matches `source-mlops.md`, "conrads site" matches `conrad-ai.md`.

If the argument is ambiguous or matches multiple projects, list the candidates and ask the user to pick one using `AskUserQuestion`.

### 2. Read the project file

Read the matched project file from `/Users/andrewgetz/tars-vault/projects/<project-name>.md`. This file contains:
- An "About this Project" section with the project description and goals
- Date-grouped sections with links to associated agent-context notes

### 3. Pull associated context notes

From the project file, extract all `[[wiki-link]]` references that point to agent-context notes (they follow the pattern `[[YYYY-MM-DD-*]]`). Read each linked note from `/Users/andrewgetz/tars-vault/agent-context/<note-name>.md`.

Focus on notes from the last 14 days unless the project file has very few entries — in that case, read all of them.

### 4. Synthesize and report context

Produce a structured context summary in your response:

```
## Project: <Project Name>

### About
<One paragraph from the project's "About this Project" section>

### Recent Work (last 14 days)
For each context note, in reverse-chronological order:
- **YYYY-MM-DD** — <what was done, decisions made, current state>

### Current State
<What's in progress, what's done, what's next — synthesized across notes>

### Open Threads
<Unfinished items, blockers, deferred decisions>

### Key Context
<Important details, decisions, or constraints a fresh session needs to know>
```

### 5. Confirm readiness

After delivering the summary, tell the user: "Context loaded. Ready to continue work on <project name>." Then wait for their instructions.

## Notes

- If a linked context note doesn't exist on disk, skip it gracefully — don't error out
- If there are no context notes yet, just summarize the project file itself
- Read the most recent notes first; older notes are lower priority
- Don't dump raw file contents — synthesize into a readable, actionable summary
- Keep the summary focused: what matters for continuing the work, not a full history
