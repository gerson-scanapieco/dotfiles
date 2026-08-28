---
name: address-pr-threads
description: Assess and address inline review threads and top-level review comments on the current branch's GitHub pull request, with user approval before making changes.
disable-model-invocation: true
---

# Address PR Threads

Act as the supervisor for the review. Inventory the feedback, prepare evidence for isolated analysts and challengers, manage their debate, and present the conclusions for approval. Do not substitute the supervisor's own opinion for delegated analysis. Related items may share an action only after each has reached a conclusion separately. The user's approval separates assessment from every mutating action.

## 1. Discover and triage

1. Identify the checked-out branch and its open pull request. Stop if the repository is in detached HEAD state or the branch has no open pull request.
2. Inspect the working tree and record pre-existing changes. Preserve them throughout the task.
3. Read the pull request metadata, full diff, changed files, every review thread, and every submitted review. Paginate GitHub's GraphQL `reviewThreads` connection, each thread's `comments` connection, and the pull request's `reviews` connection until exhausted.
   - Establish the intended scope from the pull request description, linked issues, explicit acceptance criteria, and applicable repository instructions. Record inaccessible or contradictory scope sources instead of guessing.
   - For each unresolved inline thread, collect its thread ID, a comment URL, file and current or original line, resolution and outdated state, diff context, and complete conversation.
   - For each review with a non-empty body, collect its review ID, URL, author, state, submission time, and complete body. Split a review body into separate feedback items when it contains independent remarks. Do not assume a review-body remark is addressed merely because the review is old, dismissed, approved, or followed by another review; verify it against subsequent commits and conversation.
   - If there are neither unresolved inline threads nor substantive review-body remarks, report that and stop.
4. Read every applicable `AGENTS.md` and `CLAUDE.md`, plus enough surrounding code, tests, callers, types, blame, and history to prepare a complete evidence packet for each item.
5. Mark an item `already addressed` only when direct current-branch evidence clearly satisfies it. Record that evidence with priority `none`, confidence `high`, and adversarial verdict `not applicable`. Treat every uncertain item as unaddressed and delegate it rather than resolving the uncertainty during triage.
6. Give every item a stable label. For every unaddressed item, prepare an evidence packet containing its original feedback and conversation, diff context, pull request and issue scope, repository instructions, and relevant code and history. Keep raw evidence separate from later analysis.

Triage is complete only when every original feedback item appears exactly once as clearly addressed or unaddressed and every unaddressed item has a complete evidence packet.

## 2. Analyze and challenge

1. Confirm that isolated subagent delegation is available. If not, mark unaddressed items `blocked` and stop before requesting approval; never simulate analysis or challenge in the supervisor's context.
2. For every unaddressed item, spawn a distinct, isolated analyst subagent with no inherited conversation context. Do not batch items. Analysts are read-only and must not edit files, publish replies, resolve threads, create commits, or push.
3. Give the analyst only the item's evidence packet and require:
   - The reviewer's claim, concrete failure mode, and requested outcome.
   - A classification of `valid`, `already addressed`, `incorrect`, `scope creep`, `question`, or `blocked`. Use `scope creep` only when the suggestion is not required by the pull request, linked issue, acceptance criteria, or repository rules and is not necessary to make the introduced change correct, secure, or compatible.
   - A priority of `critical`, `high`, `medium`, or `low` for actionable items and `none` when no change is warranted, based on concrete impact and urgency rather than reviewer wording.
   - A confidence of `high`, `medium`, or `low`, based on evidence strength rather than agreement.
   - A scope verdict of `in scope`, `required safeguard`, `scope creep`, or `unclear`, with evidence for and against the conclusion.
   - The smallest safe change or reply, planned validation, and any overlap with other feedback.
4. For every completed analysis, spawn a different isolated challenger subagent. Challengers have the same read-only restrictions as analysts and must not inherit the analyst's or supervisor's context.
5. Use staged disclosure to limit anchoring:
   - First give the challenger only the raw evidence packet. Require it to inspect the evidence independently and record a blind classification, priority, confidence, scope verdict, and strongest counter-case.
   - Store that baseline, then reveal the analyst's complete analysis. Require the challenger to try to falsify it point by point, testing its assumptions, causal path, attribution to the pull request, scope, severity, evidence, proposed action, and regression risk. The challenger may revise its baseline when the evidence warrants it; it must not defend a position merely for disagreement's sake.
6. Relay the challenge to the analyst, require an evidence-based response or revision, then return that response to the challenger. Continue for at most two challenge-response rounds. A conclusion is either agreement or a clearly recorded unresolved dispute; never force consensus.
7. Record one adversarial verdict:
   - `upheld`: the challenger accepts the analysis without a material change.
   - `revised`: the analysis changes materially and both agents accept the revised conclusion.
   - `overturned`: the original conclusion is withdrawn and both agents accept its replacement.
   - `disputed`: a material objection remains after the debate limit; classify the item as `blocked` with low confidence.
8. The supervisor records the agreed conclusion or dispute without silently choosing a winner. Group items only when they have the same root cause, final classification, proposed action, and validation. Retain every original label, GitHub link, and adversarial result.

This phase is complete only when every unaddressed item has a separate analyst, a separate challenger with a stored blind baseline, a bounded debate record, and a final adversarial verdict.

## 3. Request approval

Present a compact table with one row per feedback item or coherent action group and these columns:

- Stable label or grouped labels, item type, and GitHub links
- Reviewer and file location, or `PR-level review` for a review-body remark
- Final classification
- Priority
- Confidence
- Adversarial verdict
- Concise challenge summary
- Concise evidence-based rationale
- Proposed change or reply
- Planned validation
- Proposed commit title when a change is needed

Use `not applicable` as the adversarial verdict for items triaged as already addressed. Show expanded analyst and challenger arguments only for `revised`, `overturned`, or `disputed` items. Call out pre-existing working-tree changes, dependencies and action groups, scope-creep conclusions, and blocked or disputed items. Ask the user to approve all or specific labels or action groups, then end the turn.

Sort the table by priority, highest first, while preserving stable labels so the user can act on the most important feedback quickly.

Do not edit files, create commits, push, reply on GitHub, or resolve threads until the user explicitly approves the plan. If the user changes the plan, reassess the affected threads and request approval again.

## 4. Address the approved feedback

1. Re-fetch the pull request, approved threads, and approved reviews. If their content, state, or relevant scope changed materially, re-triage and repeat delegated analysis and challenge for the affected items, then present the delta and request approval again.
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
