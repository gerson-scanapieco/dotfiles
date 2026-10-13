---
name: my-flow
description: Drive a piece of work end to end — scope it with my-spec, plan it with my-plan, implement it with my-execute, review and fix the branch locally, open a pull request, then watch the pull request every 5 minutes and handle new feedback with address-pr-threads until it is merged.
disable-model-invocation: true
argument-hint: [problem description or Linear issue ID] [--draft]
---

## Context

You are the driver for the developer's main work loop. You do not reimplement the stages below — you invoke each skill, pass its output to the next, and own only the steps no other skill covers: the local code review, opening the pull request, and watching it until merge.

Input in $ARGUMENTS is a free-text problem description or a Linear issue ID, plus optional flags:
- `--draft`: open the pull request as a draft. Without it, open it ready for review.

Each invoked skill keeps its own approval gates. Never answer them on the developer's behalf; when a skill ends its turn waiting for approval, wait too, then continue that skill and the rest of this flow once the developer responds.

## Phase 0: Find the starting point

If $ARGUMENTS is a Linear issue ID, read the issue and its comments, and the current branch's state, and resume from the first phase not yet done:
- The issue is already scoped (has Implementation Guidance and Acceptance Criteria) → skip Phase 1
- The issue has a `my-plan` plan comment → skip Phase 2
- A branch for the issue already has implementation commits → skip Phase 3
- A pull request for the branch is already open → go to Phase 6

State which phases you are skipping and why before continuing.

## Phase 1: Spec

Invoke the `my-spec` skill with the problem description or issue ID. When it finishes, collect the identifiers of the issues it created.

This flow ships one issue per run. If `my-spec` produced more than one issue, ask the developer which one to drive now, and remind them to run `my-flow` again for the rest.

## Phase 2: Plan

Invoke the `my-plan` skill with the chosen issue ID.

## Phase 3: Execute

Invoke the `my-execute` skill with the issue ID, but run only its Phase 1 and Phase 2. **Do not run its Phase 3**: do not push, open a pull request, comment on Linear, or change the issue status yet. This flow does those after the local review.

## Phase 4: Local code review

Review the branch before anyone else sees it. Repeat the following at most 3 rounds, or until a round finds nothing valid:

1. Determine the base: `git merge-base HEAD origin/<default branch>` (find the default branch with `git symbolic-ref refs/remotes/origin/HEAD`).
2. Delegate the review to a subagent with fresh context, so it does not inherit the implementer's assumptions. Give it the Linear issue ID, the plan comment, and the diff range `<base>...HEAD`, and ask for findings on correctness, missed requirements or acceptance criteria, missing tests, security, and deviations from the repository's `AGENTS.md`/`CLAUDE.md` and conventions. Each finding must name the file and line, the problem, and a concrete failure scenario.
3. Verify every finding yourself against the code before acting on it, and classify it as `valid`, `incorrect`, or `needs decision` (a product or design choice, or a change outside the issue's scope).
4. For each `valid` finding: make the smallest complete fix, add or update a test when it protects the behavior, run focused validation, and create one commit for it, staging only its changes.
5. Run the repository's full relevant test suite after the round's fixes.

Do not act on `needs decision` findings. Present them to the developer with the rest of the review summary and wait for their call before Phase 5. If none exist, continue without waiting.

Keep a record of each round: findings, classifications, and commit SHAs. It goes into the final report.

## Phase 5: Open the pull request

Follow `my-execute`'s Phase 3 exactly, with these differences:
- Target the repository's default branch.
- Open the pull request ready for review, without `--draft`, unless `--draft` was passed to this flow.

That includes pushing the branch, choosing the template, commenting the PR link on the Linear issue, and updating its status. Present the PR URL to the developer.

## Phase 6: Watch the pull request until merge

1. Start a background monitor running this skill's `scripts/watch-pr` script:

   ```
   <this skill's directory>/scripts/watch-pr <PR URL> <state file> 300
   ```

   Use a state file in your scratchpad or temp directory named after the PR number, and reuse the same path for the life of this PR. The script polls every 300 seconds and prints:
   - `NEW_FEEDBACK ...` for each new review, inline comment, or conversation comment not authored by the developer
   - `POLL_ERROR ...` after 3 consecutive failed polls
   - `PR_MERGED ...` or `PR_CLOSED ...`, then exits

   In Claude Code, use the `Monitor` tool with the maximum `timeout_ms`. A monitor expires after at most 30 minutes; whenever it expires without the PR being merged or closed, re-arm it with the same command and state file. The state file keeps already-seen feedback from being reported twice. If your harness has no background monitor, tell the developer and stop after Phase 5.
2. On `NEW_FEEDBACK`, invoke the `address-pr-threads` skill on the PR's branch. It assesses the feedback and asks the developer for approval before changing anything. If feedback arrives while an `address-pr-threads` run is still waiting for approval, let the developer know and include the new items when that run re-fetches the PR.
3. On `POLL_ERROR`, check `gh auth status` and network access, tell the developer, and re-arm the monitor once the cause is clear.
4. On `PR_MERGED`, stop the monitor, update the Linear issue's status to reflect the merge if the integration has not already, and give the final report.
5. On `PR_CLOSED`, stop the monitor and ask the developer whether the work should be abandoned or reopened. Do not change the Linear issue.

## Final report

Report:
- The Linear issue ID and PR URL
- Which phases ran and which were skipped
- Each local review round: findings, classifications, and commit SHAs
- Each `address-pr-threads` run: items handled and their outcomes
- The final PR state

## Constraints

- One issue, one branch, one pull request per run
- Never bypass an invoked skill's approval gate
- Never force-push
- Never open the pull request before Phase 4 is done and every `needs decision` finding has the developer's call
