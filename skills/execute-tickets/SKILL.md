---
name: execute-tickets
description: Autonomously implement all Linear Todo issues assigned to me with label "plan built" — create branches, make commits, validate the build, open PRs, and move tickets to In Review.
argument-hint: []
---

Execute all planned Linear issues in the "Personal" team where status = `Todo`, assignee = me, and label = `plan built`. For each one, implement the plan from the issue description, validate, and submit a PR.

## Steps

### 1. Fetch issues
Use `list_issues` with:
- `team`: Personal
- `state`: Todo
- `assignee`: me
- `label`: plan built

If no issues are found, inform the user and stop.

### 2. Confirm before starting
Show the user the list of issues about to be executed and ask for confirmation before proceeding. This is the last checkpoint before autonomous execution begins.

### 3. For each issue (one at a time)

#### a. Read the plan
Read the issue description — it contains the full implementation plan written by `/plan-tickets`. Identify:
- Files to change
- Steps to follow
- Acceptance criteria

Also check if there are sub-issues (child issues) linked to this ticket — if so, implement those as part of the same branch.

#### b. Create a branch
```bash
git checkout main
git pull origin main
git checkout -b <gitBranchName from Linear issue>
```
Use the exact `gitBranchName` value from the Linear issue object (e.g. `feature/self-17-remove-fisher-college-of-business`). Always create the branch from an up-to-date `main` to ensure a clean starting point.

#### c. Implement the plan
Make all necessary code changes following the plan in the issue description. Commit logically — each commit should represent one coherent unit of work:
```bash
git add <specific files>
git commit -m "<type>: <description>

Implements <Linear issue URL>"
```

Use conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `style:`, `docs:`

#### d. Validate (build gate)
```bash
npm run build
```
- **If build passes**: continue to the next step
- **If build fails**:
  1. Push the branch to remote for troubleshooting: `git push -u origin <branch>`
  2. Add a comment to the Linear issue documenting the full build error output using `create_comment`
  3. Report the error to the user with a summary
  4. Do NOT open a PR, do NOT move the Linear status
  5. Move to the next issue in the queue

#### e. Push and open a PR
```bash
git push -u origin <branch>
gh pr create \
  --base main \
  --title "<issue title>" \
  --body "$(cat <<'EOF'
## Summary
<1-3 bullet points summarizing what changed>

## Linear issue
<Linear issue URL>

## Test plan
- [x] `npm run build` passes
- [ ] <acceptance criteria from issue>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

#### f. Update Linear
Use `update_issue` to:
- Set `state` to `In Review`

### 4. After all issues are processed

Summarize:
- List each PR that was opened (with URL)
- List any issues that failed the build gate (with error summary)
- Remind the user to review the PRs

## Notes
- Never skip the build gate — a failing build means the PR is not opened
- Use the Linear issue's `gitBranchName` exactly as provided
- If a sub-issue is linked, implement it within the same branch rather than creating a separate branch
- Do not modify files outside the scope described in the issue plan
- If the plan in the issue description is unclear or missing, skip the issue and flag it to the user
