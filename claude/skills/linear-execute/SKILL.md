---
name: linear-execute
allowed-tools: tidewave(*), linear-server(*), Bash(git:*), Bash(mix:*), Bash(gh:*), sequential-thinking(*), Glob(*), Grep(*), Read(*), Write(*), Edit(*)
description: Read an issue from Linear and implement it exactly as specified. Creates a branch, writes tests first, implements the feature, commits frequently, opens a PR, and updates the Linear issue.
argument-hint: [Linear issue ID]
---

## Context

Read the contents of Linear issue $ARGUMENTS, including attachments. If the issue has any parent or sibling issues, read those as well since they have important context. Perform the implementation described in the ticket EXACTLY as it is specified.

## Your Comprehensive Task

### Phase 1: Deep Analysis and Understanding

- **MANDATORY**: Read the entirety of Linear issue $ARGUMENTS, including its project, labels, attachments, and all comments
- **MANDATORY**: Analyze any screenshots present in the issue $ARGUMENTS for tickets with the label "Feature". These screenshots define how the UI must look like
- **MANDATORY**: Read any parent issues, sub-issues, and related issues for full context

### Phase 2: Execute the plan

- **MANDATORY**: Create a new git branch for the work. It should be named after the Linear ticket identifier
- **MANDATORY**: Start by implementing the unit tests for the feature EXACTLY as it is specified
- **MANDATORY**: Perform the feature implementation described in the ticket EXACTLY as it is specified
- **MANDATORY**: If there is missing information, describe your assumptions before proceeding
- **MANDATORY**: Perform small, incremental git commits for each logical unit of work
- **MANDATORY**: Use short, descriptive commit titles and descriptions
- **OPTIONAL**: Verify that the implementation works as expected by accessing the webpage via the URL described in the Linear ticket. This is required if the Linear issue involves front-end changes

### Phase 3: Open Pull Request

- **MANDATORY**: Push the branch to the remote repository
- **MANDATORY**: Open a PR via `gh pr create` targeting `main` with:
  - A short, descriptive PR title (under 70 characters)
  - A PR body that includes:
    - Summary of changes (2-3 sentences)
    - Link to the Linear issue
    - Test coverage notes
    - Any areas that need careful review
- **MANDATORY**: Add a comment to the Linear issue $ARGUMENTS with the PR link
- **MANDATORY**: Update the Linear issue status to reflect that a PR is open
- **MANDATORY**: Present the PR URL to the developer
