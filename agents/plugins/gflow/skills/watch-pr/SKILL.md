---
name: watch-pr
description: Watch a GitHub pull request every 5 minutes for new review feedback, assess it, and address it after user approval, for at most 3 watch loops or until the pull request is merged or closed.
argument-hint: [PR URL]
---

# Watch PR

Monitor a pull request for new feedback and address it. Treat each unresolved GitHub review thread and each distinct substantive remark in a top-level review comment as an independent unit of work. The user's approval separates assessment from every mutating action.

Input in $ARGUMENTS is an optional pull request URL. Without it, use the open pull request of the checked-out branch. Stop if the repository is in detached HEAD state or the branch has no open pull request.

## Watch loop

Run at most 3 loops. A loop is one monitor window: the monitor runs for at most 30 minutes, and any new feedback it reports is assessed and addressed (sections 1-4) within that loop. A loop ends when its monitor expires, or when its feedback has been handled. After the third loop, stop watching, report, and tell the user to run this skill again to keep watching.

1. Start a background monitor running this skill's `scripts/watch-pr` script:

   ```
   <this skill's directory>/scripts/watch-pr <PR URL> <state file> 300
   ```

   Use a state file in your scratchpad or temp directory named after the PR number, and reuse the same path for the life of this PR. The script polls every 300 seconds and prints:
   - `NEW_FEEDBACK ...` for each new review, inline comment, or conversation comment not authored by the user
   - `POLL_ERROR ...` after 3 consecutive failed polls
   - `PR_MERGED ...` or `PR_CLOSED ...`, then exits

   In Claude Code, use the `Monitor` tool with the maximum `timeout_ms`. A monitor expires after at most 30 minutes; when it expires without the PR being merged or closed, that loop is over, so start the next loop with the same command and state file. The state file keeps already-seen feedback from being reported twice. If your harness has no background monitor, tell the user and stop.
2. On `NEW_FEEDBACK`, run sections 1-4 below. If more feedback arrives while waiting for approval, tell the user and include the new items when section 3 re-fetches the pull request. When the loop's feedback is handled, start the next loop.
3. On `POLL_ERROR`, check `gh auth status` and network access, tell the user, and start the next loop once the cause is clear.
4. On `PR_MERGED`, stop the monitor and report the final state.
5. On `PR_CLOSED`, stop the monitor and report that the pull request was closed without merging.

## 1. Discover and assess

1. Check out the pull request's branch if it is not already checked out.
2. Inspect the working tree and record pre-existing changes. Preserve them throughout the task.
3. Read the pull request metadata, full diff, changed files, every review thread, and every submitted review. Paginate GitHub's GraphQL `reviewThreads` connection, each thread's `comments` connection, and the pull request's `reviews` connection until exhausted.
   - For each unresolved inline thread, collect its thread ID, a comment URL, file and current or original line, resolution and outdated state, diff context, and complete conversation.
   - For each review with a non-empty body, collect its review ID, URL, author, state, submission time, and complete body. Split a review body into separate feedback items when it contains independent remarks. Do not assume a review-body remark is addressed merely because the review is old, dismissed, approved, or followed by another review; verify it against subsequent commits and conversation.
   - If there are neither unresolved inline threads nor substantive review-body remarks, report that and end this loop.
4. Read every applicable `AGENTS.md` and `CLAUDE.md`, plus enough surrounding code, tests, callers, types, blame, and history to verify each remark rather than accepting it at face value.
5. Classify every feedback item as one of:
   - `valid`: a code or documentation change is needed.
   - `already addressed`: the current branch already satisfies the remark.
   - `incorrect`: the remark's premise or proposed solution does not hold.
   - `question`: a reply can settle the topic without a change.
   - `blocked`: available evidence is insufficient to decide.

Assessment is complete only when every unresolved inline thread and every substantive review-body remark appears exactly once and each classification cites concrete repository evidence.

## 2. Request approval

Present a compact table containing, for each feedback item:

- A stable short label, item type, and GitHub link
- Reviewer and file location, or `PR-level review` for a review-body remark
- Classification and rationale
- Proposed change or reply
- Planned validation
- Proposed commit title when a change is needed

Call out pre-existing working-tree changes, dependencies between feedback items, and blocked items. Ask the user to approve all or specific labels, then end the turn.

Do not edit files, create commits, push, reply on GitHub, or resolve threads until the user explicitly approves the plan. If the user changes the plan, reassess the affected threads and request approval again.

## 3. Address the approved feedback

1. Re-fetch the pull request, approved threads, and approved reviews. If their content or state changed materially, present the delta and request approval again.
2. Ensure pre-existing user changes cannot enter the planned commits. If they overlap the required edits or prevent clean thread-scoped commits, stop and ask the user how to isolate them.
3. Handle approved feedback items sequentially:
   - For a `valid` item, implement the smallest complete fix and add or update tests when they protect the behavior under discussion.
   - Run focused validation before committing.
   - Inspect the staged diff and stage only that item's changes; never use broad staging such as `git add .`.
   - Create exactly one commit for that item and record the item-to-commit mapping. Keep every commit independently coherent.
   - For `already addressed`, `incorrect`, or `question`, prepare an evidence-based reply without creating an empty commit.
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

## 4. Report the result

At the end of each loop, report each feedback item's label, type, final classification, commit SHA or `no change`, reply status, and resolution status. Include validation results and list every inline thread left open with the reason.
