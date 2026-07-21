---
name: code-review
description: Review a GitHub pull request or the current branch for correctness, regressions, and repository-convention violations. Use when asked to review code, a PR URL or number, or a branch before publication; accept an optional PR URL, PR number, or `branch` argument.
allowed-tools: Bash(git:*), Bash(gh:*), Glob(*), Grep(*), Read(*)
---

Review the requested change rigorously. Report only actionable issues that are introduced by the change and likely to matter in production. Do not publish review comments unless the user explicitly asks.

## Target

- With a PR URL or number, review that pull request.
- With `branch`, find the pull request for the current branch. If none exists, compare the branch against its merge base with the default branch.
- With no argument, review the pull request for the current branch; otherwise review the uncommitted and committed changes against the merge base.
- If the target is a draft, closed, automated, or trivially mechanical change, say so and stop unless the user asks to continue.

## Investigation

1. Read the PR metadata, changed files, full diff, and existing review comments with `gh`. For a local branch, inspect `git status`, the merge base, and the diff.
2. Read every applicable `AGENTS.md` and `CLAUDE.md`, from repository root through each changed file's directory. Treat their requirements as review criteria.
3. Read enough surrounding implementation, tests, callers, and types to prove or disprove each suspected issue. Use `git blame` and targeted history when intent or compatibility is unclear.
4. Compare nearby code and prior review discussions when they reveal a local convention or a previously rejected approach.
5. Ignore pre-existing problems, intentional behavior that the change clearly supports, style preferences, missing tests, and failures that CI or static analysis will catch.

## Findings

- Include only findings with a clear causal path from changed code to an incorrect or harmful outcome.
- Prioritize correctness, data integrity, security, concurrency, backwards compatibility, and violated repository requirements.
- For each finding, state the severity, affected file and line, concrete failure mode, and concise rationale. Link to the exact PR file range when a PR is available.
- Do not manufacture findings. If none survive verification, say `No actionable issues found.`
- Keep the review concise. Lead with findings, then list any remaining assumptions or scope limitations.
