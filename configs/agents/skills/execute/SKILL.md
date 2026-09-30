---
name: execute
allowed-tools: tidewave(*), linear-server(*), Bash(git:*), Bash(mix:*), Bash(gh:*), sequential-thinking(*), Glob(*), Grep(*), Read(*), Write(*), Edit(*)
description: Read an issue from Linear and implement it exactly as specified. Creates a branch, writes tests first, implements the feature, commits frequently, opens a PR, and updates the Linear issue.
argument-hint: [Linear issue ID]
---

## Context

Read the contents of Linear issue $ARGUMENTS, including attachments. If the issue has any parent or sibling issues, read those as well since they have important context. Perform the implementation described in the ticket EXACTLY as it is specified.

If a comment on the issue contains a detailed implementation plan (e.g. from the `plan` skill), that plan is the primary source of truth for implementation steps and ordering — follow it directly instead of re-deriving an approach. A ticket carrying such a plan needs less architectural judgment to execute, making this a good candidate to run under a cheaper/faster model if your harness lets you pick one per task.

## Your Comprehensive Task

### Phase 1: Deep Analysis and Understanding

- **MANDATORY**: Read the entirety of Linear issue $ARGUMENTS, including its project, labels, attachments, and all comments
- **MANDATORY**: Read any parent issues, sub-issues, and related issues for full context
- **If no plan comment exists**: analyze any screenshots present in the issue $ARGUMENTS for tickets with the label "Feature" directly — these screenshots define how the UI must look. If a plan comment exists, follow its UI spec instead

### Phase 2: Execute the plan

- **MANDATORY**: Check if current branch is associated with the given Linear identifier. If not, create a new git branch for the work. It should be named after the Linear ticket identifier
- **If a plan comment exists**: implement it step by step, in its order, writing each step's test(s) before that step's code
- **If no plan comment exists**: start by implementing the unit tests for the feature EXACTLY as specified, then the feature implementation EXACTLY as specified. If there is missing information, describe your assumptions before proceeding
- **MANDATORY**: Perform small, incremental git commits for each logical unit of work
- **MANDATORY**: Use short, descriptive commit titles and descriptions
- **OPTIONAL**: Verify that the implementation works as expected by accessing the webpage via the URL described in the Linear ticket. This is required if the Linear issue involves front-end changes

### Phase 3: Open Pull Request

- **MANDATORY**: Push the branch to the remote repository
- **MANDATORY**: Determine the PR template: if the issue's Linear label or issue type field marks it as a bug, use the Bugfix template; otherwise use the Feature/Change template
- **MANDATORY**: Open a draft PR via `gh pr create` targeting `main` with:
  - Title following the template: `<short, descriptive title> [<Linear issue ID>]` (e.g. `Add bookmarks for story moments [FAB-42]`)
  - Body following the applicable template below

**Feature/Change template:**
```markdown
## Summary
[2-3 sentences on what changed and why]

## Implementation Details
[Technical approach and key decisions made in this PR]

## Database Changes
[Schema changes, if any — omit this section entirely if there are none]

## How to Test
[Manual QA steps to verify the change]

## Deployment Checklist
[Steps to perform before/while this PR lands in prod: feature flags, config changes, secrets, other infra concerns — omit this section entirely if there are none]
```

**Bugfix template:**
```markdown
## Bug Description

<!-- What was the bug? Expected vs actual behavior. -->

**Expected:**

**Actual:**

## Root Cause

<!-- What caused this bug? Be specific. -->

## Type of Change

- [x] Bug fix

## Fix Description

<!-- What does this PR change to fix the bug? -->

## How to Reproduce (Before Fix)

1.
2.
3.

## How to Verify (After Fix)

1.
2.
3.
```
- **MANDATORY**: Add a comment to the Linear issue $ARGUMENTS with the PR link
- **MANDATORY**: Update the Linear issue status to reflect that a PR is open
- **MANDATORY**: Present the PR URL to the developer
