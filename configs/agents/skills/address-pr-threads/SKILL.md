---
name: address-pr-threads
description: Assess and address review threads on the current branch's GitHub pull request, with user approval before making changes.
disable-model-invocation: true
---

# Address PR Threads

Treat each unresolved GitHub review thread as an independent unit of work. The user's approval separates assessment from every mutating action.

## 1. Discover and assess

1. Identify the checked-out branch and its open pull request. Stop if the repository is in detached HEAD state or the branch has no open pull request.
2. Inspect the working tree and record pre-existing changes. Preserve them throughout the task.
3. Read the pull request metadata, full diff, changed files, and every review thread. Paginate GitHub's GraphQL `reviewThreads` connection and each thread's `comments` connection until exhausted. For each unresolved thread, collect its thread ID, a comment URL, file and current or original line, resolution and outdated state, diff context, and complete conversation. If none are unresolved, report that and stop.
4. Read every applicable `AGENTS.md` and `CLAUDE.md`, plus enough surrounding code, tests, callers, types, blame, and history to verify each remark rather than accepting it at face value.
5. Classify every unresolved thread as one of:
   - `valid`: a code or documentation change is needed.
   - `already addressed`: the current branch already satisfies the remark.
   - `incorrect`: the remark's premise or proposed solution does not hold.
   - `question`: a reply can settle the topic without a change.
   - `blocked`: available evidence is insufficient to decide.

Assessment is complete only when every unresolved thread appears exactly once and each classification cites concrete repository evidence.

## 2. Request approval

Present a compact table containing, for each thread:

- A stable short label and GitHub link
- Reviewer and file location
- Classification and rationale
- Proposed change or reply
- Planned validation
- Proposed commit title when a change is needed

Call out pre-existing working-tree changes, dependencies between threads, and blocked items. Ask the user to approve all or specific thread labels, then end the turn.

Do not edit files, create commits, push, reply on GitHub, or resolve threads until the user explicitly approves the plan. If the user changes the plan, reassess the affected threads and request approval again.

## 3. Address the approved threads

1. Re-fetch the pull request and approved threads. If their content or state changed materially, present the delta and request approval again.
2. Ensure pre-existing user changes cannot enter the planned commits. If they overlap the required edits or prevent clean thread-scoped commits, stop and ask the user how to isolate them.
3. Handle approved threads sequentially:
   - For a `valid` thread, implement the smallest complete fix and add or update tests when they protect the behavior under discussion.
   - Run focused validation before committing.
   - Inspect the staged diff and stage only that thread's changes; never use broad staging such as `git add .`.
   - Create exactly one commit for that thread and record the thread-to-commit mapping. Keep every commit independently coherent.
   - For `already addressed`, `incorrect`, or `question`, prepare an evidence-based reply without creating an empty commit.
   - Leave `blocked` threads untouched unless the user's approval also supplies the missing decision.
4. Run the repository's appropriate final validation across the accumulated commits. Do not publish replies or resolve affected threads when validation fails.
5. Push the current branch without force. Confirm every change commit is visible on the pull request before continuing.
6. Reply to each approved thread through its GraphQL thread ID:
   - For a changed thread, summarize the fix, cite its commit SHA, and state the validation performed.
   - For a no-change thread, explain the evidence and conclusion directly.
7. Resolve a thread only after the reply succeeds and its topic is fully addressed. Leave it open when reviewer confirmation or another decision is still needed. Verify the mutation result rather than assuming success.

Use `addPullRequestReviewThreadReply` to reply and `resolveReviewThread` to resolve. Never substitute a review comment ID for the review thread ID.

## 4. Report the result

Report each thread's label, final classification, commit SHA or `no change`, reply status, and resolution status. Include validation results and list every thread left open with the reason.
