---
name: my-review
description: "Rigorous local and PR review that raises only actionable feedback. Use when the user asks to review changes, a diff, a branch, or a GitHub PR."
---

<!-- Adapted from https://github.com/samcdavid/dotfiles/tree/main/claude/skills/my-review. -->

# Code Review

Delegate substantive review routing, evidence assembly, whole-diff synthesis,
per-finding verification, and verdict construction to the `skill-my-review`
custom agent. This wrapper determines the source and authorization context,
preserves the user-facing publication boundary, and renders the agent's
structured review envelope.

## Dispatch

Before dispatch, resolve `ledger_path` from `~/.claude/thoughts/shared/workflows/`; workflow ledgers are retained in Claude Thoughts and never in the worktree. Normalize the request into `{ mode, review_relationship, target, base_ref, artifact_inputs, ledger_path, stage, authority: local_only, publication_authorization: none }`, then delegate it through the environment's custom-agent mechanism:

- In Codex, call `spawn_agent` with `agent_type: "skill-my-review"`, pass the normalized request in `message`, and wait for that agent's result.
- In Claude Code, use the Agent tool with subagent type `skill-my-review`.

`skill-my-review` is an agent role, not a skill, shell executable, or MCP tool. Do not search for another callable with that name and do not perform the delegated review manually in this wrapper. If the role is unavailable, report the missing custom-agent installation instead of silently bypassing the review pipeline.

- Infer `mode` as capture/promote, PR, branch/range, local, or local issue only from the supplied argument and current context; load the runner's retained shared routing references before resolving ambiguity.
- Set `review_relationship` to `local`, `self_authored_pr`, or `third_party_pr`. In PR mode, compare the PR author's login with the authenticated GitHub login; if either cannot be established, use `unknown_pr`, which is not eligible for `COMMENT`.
- Match a ledger by its recorded branch first, then its issue/slug context when branch metadata is unavailable. Set `ledger_path: none` after that Claude Thoughts lookup finds no matching ledger; a missing ledger is valid and must not block dispatch. Never search the repository for one.
- For `/my-workflow`, pass the approved plan/base/ledger context and stage number in embedded local mode. The runner returns the compact review envelope plus stable finding keys and prior-ledger matches, so the feedback loop can settle each finding without rehashing it.
- Do not invoke publication from this wrapper unless the user explicitly asks after reviewing the completed result. A runner may never publish a review, reply, resolve a thread, push, create/update a PR, or widen that authorization.

## Present

Return the coverage manifest and actionable findings first with file:line
evidence and concrete author-controlled fixes, decisions, or information
requests, then verdict, questions, residual risk, requirements coverage,
dropped findings, prior resolved/deferred matches, and the compact workflow-stage
envelope when embedded. Drop observations, preferences, and speculative concerns
that do not ask the author to do something concrete. Use `REQUEST_CHANGES` only
for verified findings that are both `Critical` and `High` risk. In local,
branch/range, local-issue, embedded-local, self-authored PR, and unknown-PR
reviews, the only other verdict is `APPROVE`. `COMMENT` is available only for an
actual PR whose author differs from the authenticated reviewer. Do not include
raw lens or verifier transcripts.
