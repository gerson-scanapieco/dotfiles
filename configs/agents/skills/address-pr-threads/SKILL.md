---
name: address-pr-threads
description: Assess and address inline review threads and top-level review comments on the current branch's GitHub pull request, with user approval before making changes.
disable-model-invocation: true
---

# Address PR Threads

Treat each unresolved GitHub review thread and each distinct substantive remark in a top-level review comment as an independent assessment unit. Related items may share an action only after each has been assessed and challenged separately. The user's approval separates assessment from every mutating action.

## 1. Discover and assess

1. Identify the checked-out branch and its open pull request. Stop if the repository is in detached HEAD state or the branch has no open pull request.
2. Inspect the working tree and record pre-existing changes. Preserve them throughout the task.
3. Read the pull request metadata, full diff, changed files, every review thread, and every submitted review. Paginate GitHub's GraphQL `reviewThreads` connection, each thread's `comments` connection, and the pull request's `reviews` connection until exhausted.
   - Establish the intended scope from the pull request description, linked issues, explicit acceptance criteria, and applicable repository instructions. Record inaccessible or contradictory scope sources instead of guessing.
   - For each unresolved inline thread, collect its thread ID, a comment URL, file and current or original line, resolution and outdated state, diff context, and complete conversation.
   - For each review with a non-empty body, collect its review ID, URL, author, state, submission time, and complete body. Split a review body into separate feedback items when it contains independent remarks. Do not assume a review-body remark is addressed merely because the review is old, dismissed, approved, or followed by another review; verify it against subsequent commits and conversation.
   - If there are neither unresolved inline threads nor substantive review-body remarks, report that and stop.
4. Read every applicable `AGENTS.md` and `CLAUDE.md`, plus enough surrounding code, tests, callers, types, blame, and history to verify each remark rather than accepting it at face value.
5. For each feedback item, state the reviewer's claim, the concrete failure mode, and the requested outcome. Determine whether the issue was introduced by the pull request, already existed, or cannot be attributed confidently.
6. Give every item a provisional classification:
   - `valid`: a code or documentation change is needed.
   - `already addressed`: the current branch already satisfies the remark.
   - `incorrect`: the remark's premise or proposed solution does not hold.
   - `scope creep`: the suggestion may be reasonable, but it is not required by the pull request, linked issue, acceptance criteria, or repository rules, and is not necessary to make the introduced change correct, secure, or compatible.
   - `question`: a reply can settle the topic without a change.
   - `blocked`: available evidence is insufficient to decide.
7. Assign a priority and confidence:
   - Priority is `critical`, `high`, `medium`, or `low` for actionable items and `none` when no change is warranted. Base it on concrete impact and urgency, not reviewer wording.
   - Confidence is `high`, `medium`, or `low`. Base it on the strength and completeness of repository and scope evidence, not agreement alone.

The provisional assessment is complete only when every original feedback item appears exactly once and its classification, priority, and confidence cite concrete repository and scope evidence.

## 2. Challenge and adjudicate

1. Dispatch a distinct, isolated adversarial reviewer subagent for every original feedback item. Do not batch multiple items into one challenger. Parallel execution is allowed. Challengers are read-only and must not edit files, publish replies, resolve threads, create commits, or push.
2. Give each challenger the original feedback and conversation, diff context, relevant pull request and issue scope, repository instructions, and the code and history needed for independent verification. Do not reveal the primary assessor's classification, rationale, priority, confidence, or proposed action until the challenger returns its initial assessment.
3. Require the challenger to return:
   - Its independent classification, priority, and confidence using the same vocabulary as the primary assessment.
   - A scope verdict of `in scope`, `required safeguard`, `scope creep`, or `unclear`.
   - The strongest evidence for and against the feedback, including hidden assumptions, pre-existing behavior, duplicate or overlapping feedback, and plausible regressions from the proposed remedy.
   - Whether any suggested remedy is necessary and proportionate, and the smallest safe action.
4. Compare the independent assessments. When they differ materially on classification, scope, priority, or action, or either has low confidence, run one evidence-based debate round: show both assessments to the challenger, have it attack the primary conclusion, then let the primary rebut, inspect any newly identified evidence, and adjudicate.
5. Record one adversarial verdict per item:
   - `confirmed`: the independent assessments materially agree.
   - `confirmed after debate`: a disagreement is resolved in favor of the primary assessment.
   - `revised`: the primary assessment changes after challenge.
   - `disputed`: material disagreement remains; classify the item as `blocked` rather than forcing consensus.
6. After adjudication, group items only when they have the same root cause, final classification, proposed action, and validation. Retain every original label, GitHub link, and adversarial result. Never group items merely because they affect the same file or reviewer.

Adjudication is complete only when every original feedback item has a primary assessment, an independent challenger assessment, a final decision, and an adversarial verdict.

## 3. Request approval

Present a compact table with one row per feedback item or coherent action group and these columns:

- Stable label or grouped labels, item type, and GitHub links
- Reviewer and file location, or `PR-level review` for a review-body remark
- Final classification
- Priority
- Confidence
- Adversarial verdict
- Concise evidence-based rationale
- Proposed change or reply
- Planned validation
- Proposed commit title when a change is needed

Call out pre-existing working-tree changes, dependencies and action groups, scope-creep conclusions, and blocked or disputed items. Ask the user to approve all or specific labels or action groups, then end the turn.

Sort the table by priority, highest first, while preserving stable labels so the user can act on the most important feedback quickly.

Do not edit files, create commits, push, reply on GitHub, or resolve threads until the user explicitly approves the plan. If the user changes the plan, reassess the affected threads and request approval again.

## 4. Address the approved feedback

1. Re-fetch the pull request, approved threads, and approved reviews. If their content, state, or relevant scope changed materially, reassess and re-challenge the affected items, then present the delta and request approval again.
2. Ensure pre-existing user changes cannot enter the planned commits. If they overlap the required edits or prevent clean thread-scoped commits, stop and ask the user how to isolate them.
3. Handle approved action groups sequentially:
   - For `valid` items, implement the smallest complete fix and add or update tests when they protect the behavior under discussion.
   - Run focused validation before committing.
   - Inspect the staged diff and stage only that action group's changes; never use broad staging such as `git add .`.
   - Create exactly one commit for that action group and map every member label to it. Keep every commit independently coherent.
   - For `already addressed`, `incorrect`, `scope creep`, or `question`, prepare an evidence-based reply without creating an empty commit.
   - Leave `blocked` items untouched unless the user's approval also supplies the missing decision.
4. Run the repository's appropriate final validation across the accumulated commits. Do not publish replies or resolve affected threads when validation fails.
5. Push the current branch without force. Confirm every change commit is visible on the pull request before continuing.
6. Reply to each approved feedback item:
   - Reply to an inline thread through its GraphQL thread ID.
   - For a top-level review-body remark, post a pull request conversation comment that links to the original review. GitHub review bodies do not have a reply or resolve mutation, so never substitute the review ID for a thread ID.
   - For a changed item, summarize the fix, cite its commit SHA, and state the validation performed.
   - For a no-change item, explain the evidence and conclusion directly.
7. Resolve an inline thread only after the reply succeeds and its topic is fully addressed. Leave it open when reviewer confirmation or another decision is still needed. Verify the mutation result rather than assuming success. Record resolution as `not applicable` for review-body remarks.

Use `addPullRequestReviewThreadReply` to reply and `resolveReviewThread` to resolve. Never substitute a review comment ID for the review thread ID.

## 5. Report the result

Report each feedback item's label, type, final classification, priority, confidence, adversarial verdict, commit SHA or `no change`, reply status, and resolution status. Include validation results and list every inline thread left open with the reason.
