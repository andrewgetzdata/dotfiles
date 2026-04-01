---
name: teammate
description: Spawn a tmux teammate agent for a quick task. Use when the user wants to delegate a self-contained task to a parallel agent.
argument-hint: <task description>
---

# Spawn a tmux teammate

Spawn a teammate agent in a tmux pane to handle a self-contained task.

## Procedure

### 1. Parse the task

The user's argument is the task description. If no argument is provided, ask what they'd like the teammate to do.

### 2. Create the team

Use TeamCreate with:
- `team_name`: a short kebab-case slug derived from the task (e.g., `fix-tests`, `cleanup-imports`)

### 3. Create a task

Use TaskCreate to track the work with a clear subject and description.

### 4. Spawn the teammate

Use the Agent tool with:
- `name`: a short name for the agent (e.g., `worker`, `fixer`)
- `team_name`: the team name from step 2
- `mode`: `"auto"`
- `run_in_background`: `true`
- `prompt`: Include:
  - The full task description with enough context to work independently
  - The current working directory and any relevant file paths
  - Instruction to mark the task as completed when done and report back

### 5. Confirm

Tell the user the teammate has been spawned and what it's working on. Wait for the teammate to report back before marking the task complete.
