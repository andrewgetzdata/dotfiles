---
name: plan-tickets
description: Interactively plan all Linear Todo issues assigned to me — ask clarifying questions, build full specs, create sub-issues, and label tickets as "plan built" when done.
argument-hint: []
---

Walk through all Linear issues in the "Personal" team where status = `Todo` and assignee = me. For each one, build a full implementation plan interactively, update the ticket, and mark it ready for execution.

## Steps

### 1. Fetch issues
Use `list_issues` with:
- `team`: Personal
- `state`: Todo
- `assignee`: me

If no issues are found, inform the user and stop.

### 2. Ensure "plan built" label exists
Use `list_issue_labels` to check if a label named "plan built" exists in the Personal team.
If it does not exist, create it with `create_issue_label`:
- `name`: plan built
- `color`: #6B7280 (gray)
- `teamId`: (Personal team ID)

### 3. For each issue (one at a time)

Display the issue title and current description to the user, then ask clarifying questions to build a full spec. Use `AskUserQuestion` where helpful, or ask in prose. Cover:

- **What files/code need to change?** — explore the codebase as needed to answer this
- **Acceptance criteria** — what does "done" look like? What should a reviewer verify?
- **Sub-issues** — should this be broken into smaller tasks? If yes, what are they?
- **Edge cases or constraints** — anything that could go wrong or needs special handling?

After gathering answers, draft the implementation plan and **present it to the user in chat** before writing anything to Linear. Show the full plan in markdown and ask: "Does this look right, or would you like to adjust anything?"

Iterate based on feedback until the user explicitly approves. Only then proceed:

1. **Create sub-issues** (if any) using `create_issue`:
   - Set `parentId` to the current issue's ID
   - Set `team` to Personal
   - Set `state` to Todo

2. **Update the issue description** using `update_issue` with a structured implementation plan:

```markdown
## Implementation Plan

### Files to change
- `<file path>` — <what changes and why>

### Steps
1. <step>
2. <step>

### Acceptance criteria
- [ ] <criterion>
- [ ] <criterion>

### Sub-issues
- <SELF-XX: sub-issue title> (if any)

### Edge cases
- <any edge cases noted>
```

3. **Add the "plan built" label** using `update_issue`:
   - Set `labels` to include the "plan built" label ID

### 4. After all issues are processed

Summarize what was planned:
- List each ticket that was updated
- Note any sub-issues created
- Remind the user they can now run `/execute-tickets` to implement everything

## Notes
- Stay focused: only plan code changes (what files change, how, why)
- Don't over-engineer sub-issues — only create them if the work is genuinely separable
- If a ticket already has a detailed description or "plan built" label, skip it and note it was already planned
