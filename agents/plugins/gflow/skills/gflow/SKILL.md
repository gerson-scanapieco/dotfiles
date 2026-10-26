---
name: gflow
description: Drive a piece of work end to end — specify it with spec, scope and plan it with plan, implement it with impl, review the branch with the review skill and fix it locally, open a pull request, then hand the pull request to watch-pr to monitor and address new feedback.
disable-model-invocation: true
argument-hint: "[problem description or Linear issue ID] [--draft]"
---

## Context

You are the driver for the developer's main work loop. You do not reimplement the stages below — you invoke each skill, pass its output to the next, and own only the steps no other skill covers: the local code review, opening the pull request, and handing it to `watch-pr`.

Input in $ARGUMENTS is a free-text problem description or a Linear issue ID, plus optional flags:
- `--draft`: open the pull request as a draft. Without it, open it ready for review.

`spec`, `plan`, and `impl` always run in that order: every piece of work is specified, then planned, then implemented. A phase is skipped only when its output already exists (see Phase 0). `spec` clarifies what to build and its acceptance criteria, `plan` scopes the work and defines how, and `impl` carries the plan out.

Each invoked skill keeps its own approval gates. Never answer them on the developer's behalf; when a skill ends its turn waiting for approval, wait too, then continue that skill and the rest of this flow once the developer responds.

## Phase 0: Find the starting point

If $ARGUMENTS is a Linear issue ID, read the issue and its comments, and the current branch's state, and resume from the first phase not yet done:
- The issue already has Acceptance Criteria → skip Phase 1
- The issue has a `plan` plan comment → skip Phase 2
- A branch for the issue already has implementation commits → skip Phase 3
- A pull request for the branch is already open → go to Phase 6

State which phases you are skipping and why before continuing.

## Phase 1: Spec

Invoke the `spec` skill with the problem description or issue ID. It produces one issue with acceptance criteria. Collect its identifier.

## Phase 2: Plan

Invoke the `plan` skill with the issue ID. It scopes the work and may propose splitting it into several issues or a project, which it creates after the developer approves.

This flow ships one issue per run. If `plan` split the work into more than one issue, ask the developer which one to drive now (the one `plan` planned), and remind them to run `gflow` again for the rest.

## Phase 3: Execute

Invoke the `impl` skill with the issue ID, but run only its Phase 1 and Phase 2. **Do not run its Phase 3**: do not push, open a pull request, comment on Linear, or change the issue status yet. This flow does those after the local review.

## Phase 4: Local code review

Review the branch before anyone else sees it, using the `review` skill. Repeat the following at most 3 rounds, or until a round has no findings:

1. Delegate to a subagent with fresh context, so the review does not inherit the implementer's assumptions. Tell it to invoke the `review` skill with `--issue <Linear issue ID>` on the current branch, and to return the skill's output unchanged. The review skill runs with its own model and effort settings. If the harness cannot dispatch subagents, invoke the skill directly.
2. Read the result:
   - Findings are not independently re-verified by the review, so check each one against the code you just wrote before changing it, and skip with a note any that do not hold or no longer apply
   - `needs decision` items are not acted on; they go to the developer
3. For each finding that holds: make the smallest complete fix, add or update a test when it protects the behavior, run focused validation, and create one commit for it, staging only its changes. The review ignores uncommitted work, so commit every fix before the next round.
4. Run the repository's full relevant test suite after the round's fixes.

Present the `needs decision` items to the developer with the rest of the review summary and wait for their call before Phase 5. If none exist, continue without waiting.

Keep a record of each round: verdict, findings, what was fixed with commit SHAs, and what was skipped and why. It goes into the final report.

## Phase 5: Open the pull request

Follow `impl`'s Phase 3 exactly, with these differences:
- Target the repository's default branch.
- Open the pull request ready for review, without `--draft`, unless `--draft` was passed to this flow.

That includes pushing the branch, choosing the template, commenting the PR link on the Linear issue, and updating its status. Present the PR URL to the developer.

## Phase 6: Watch the pull request

Invoke the `watch-pr` skill with the PR URL. It monitors the pull request, handles feedback with the developer's approval, and stops on merge, close, or after 3 watch loops.

When it reports `PR_MERGED`, update the Linear issue's status to reflect the merge if the integration has not already, and give the final report. On `PR_CLOSED`, ask the developer whether the work should be abandoned or reopened. Do not change the Linear issue.

## Final report

Report:
- The Linear issue ID and PR URL
- Which phases ran and which were skipped
- Each local review round: findings, classifications, and commit SHAs
- Each `watch-pr` loop: items handled and their outcomes
- The final PR state

## Constraints

- One issue, one branch, one pull request per run
- Never bypass an invoked skill's approval gate
- Never force-push
- Never open the pull request before Phase 4 is done and every `needs decision` finding has the developer's call
