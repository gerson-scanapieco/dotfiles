---
name: impl
allowed-tools: tidewave(*), linear-server(*), Bash(git:*), Bash(mix:*), Bash(gh:*), sequential-thinking(*), Glob(*), Grep(*), Read(*), Write(*), Edit(*)
description: Implement the plan posted on a Linear issue exactly as written. Creates a branch, writes tests first, implements each step, commits frequently, opens a PR, and updates the Linear issue. Requires a plan from the `plan` skill.
argument-hint: [Linear issue ID]
---

## Context

Read the contents of Linear issue $ARGUMENTS, including attachments. If the issue has any parent or sibling issues, read those as well since they have important context.

The work is defined by the implementation plan that the `plan` skill posted as a comment on the issue. That plan is the source of truth for the technical approach, the steps, and their order: follow it exactly instead of re-deriving an approach. **If the issue has no plan comment, stop and tell the developer to run `plan` first. Do not implement from the ticket alone.** Because the plan has already settled the architecture, this is a good candidate to run under a cheaper/faster model if your harness lets you pick one per task.

## Your Comprehensive Task

### Phase 1: Deep Analysis and Understanding

- **MANDATORY**: Read the entirety of Linear issue $ARGUMENTS, including its project, labels, attachments, and all comments
- **MANDATORY**: Read any parent issues, sub-issues, and related issues for full context
- **MANDATORY**: Confirm the issue has a plan comment from the `plan` skill, and read it in full. Without one, stop as described above
- Follow the plan's UI spec for tickets with the label "Feature". The plan already translates any screenshots into that spec

### Phase 2: Execute the plan

- **MANDATORY**: Check if current branch is associated with the given Linear identifier. If not, create a new git branch for the work. It should be named after the Linear ticket identifier
- Implement the plan step by step, in its order, writing each step's test(s) before that step's code. If a step turns out to be wrong or impossible, stop and tell the developer rather than improvising a different approach
- **MANDATORY**: Perform small, incremental git commits for each logical unit of work
- **MANDATORY**: Use short, descriptive commit titles and descriptions
- **MANDATORY**: Verify that the implementation works as expected by exercising it the way a user would, not only through unit tests. This applies to every change: front-end, CLI, API, background jobs, and refactors that claim to preserve behavior
  - If the repository has a project-local verification skill (`verify-*` in `.claude/skills/` or `.agents/skills/`), use it: launch the app, drive the affected feature from its feature map, and keep the captured evidence
  - Otherwise, use the closest real entry point: the webpage at the URL described in the Linear ticket, the CLI command, the API request, or the job trigger
  - If the change cannot be exercised live (missing credentials, external dependency, no runnable app), say what was and was not verified in the PR description, and suggest the `create-verification-skill` skill when the repository has no way to run its app. Do not generate one as part of this issue

### Phase 3: Open Pull Request

- **MANDATORY**: Push the branch to the remote repository
- **MANDATORY**: Determine the PR template: if the issue's Linear label or issue type field marks it as a bug, use the Bugfix template; otherwise use the Feature/Change template
- **MANDATORY**: Open a draft PR via `gh pr create` targeting `main` with:
  - Title following the template: `<short, descriptive title> [<Linear issue ID>]` (e.g. `Add bookmarks for story moments [FAB-42]`)
  - Body following the applicable template: read `references/pr-template-bugfix.md` for a bug fix, otherwise `references/pr-template-feature.md`. Fill the verification section from what you actually ran during Phase 2 verification, never from what you expect would work

- **MANDATORY**: Add a comment to the Linear issue $ARGUMENTS with the PR link
- **MANDATORY**: Update the Linear issue status to reflect that a PR is open
- **MANDATORY**: Present the PR URL to the developer
