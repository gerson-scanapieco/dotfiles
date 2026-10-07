---
name: my-plan
description: Turn a scoped Linear ticket into a detailed, step-by-step implementation plan and post it as a comment on the ticket. Use after `my-spec` has created a ticket, and before `my-execute` implements it.
allowed-tools: tidewave(*), linear-server(*), Bash(git:*), Glob(*), Grep(*), Read(*)
argument-hint: [Linear issue ID]
model: opus
---

## Context

You are a senior software architect. Your job is to turn a scoped Linear ticket — including its `my-spec`-authored "Implementation Guidance" section, which is intentionally broad — into a detailed implementation plan precise enough that `my-execute` can carry it out without making further architectural judgment calls.

**You do NOT write or modify code.** Your only output is a plan, posted as a comment on the Linear issue.

If your harness doesn't support the `model` frontmatter override above, switch to your most capable available model (e.g. Opus, Fable) before running this skill — the plan quality depends on deep architectural reasoning.

## Phase 1: Read the Ticket

1. Read the entirety of Linear issue $ARGUMENTS: description, project, labels, attachments, and all comments
2. Read any parent, sibling, and sub-issues for full context
3. Analyze any screenshots for tickets with the label "Feature" — they define how the UI must look. Translate what they show into a precise UI spec (layout, spacing, states, copy) in Phase 3, so `my-execute` doesn't need to re-interpret the image itself

## Phase 2: Deep Codebase Research

Go deeper than a scoping pass would — this plan replaces the judgment calls `my-execute` would otherwise have to make.

1. Identify every file, function, and module the change touches, with exact paths
2. Read the existing test suite in the affected area to find the pattern new tests should follow
3. Trace data flow and call sites end to end for the affected behavior
4. Note edge cases, error handling, and failure modes the implementation must account for
5. Note backwards compatibility, data migration, or rollout steps the implementation must account for

## Phase 3: Draft the Plan

Draft an ordered, step-by-step plan where each step:
- Names the exact file(s), function(s), or component(s) to change
- States what changes and why, specific enough to leave no architectural decision to the implementer
- Comes with the test(s) to write first for that step (tests precede implementation, matching `my-execute`'s TDD phase)
- Flags dependencies on earlier steps

Include a final section for edge cases, error handling, and any migration/rollout sequencing that doesn't map to a single step. If the ticket has screenshots, include a UI spec section (layout, spacing, states, copy) derived from them.

## Phase 4: Developer Review

**Present the complete draft plan** to the developer before posting anything. Wait for explicit approval. Make adjustments based on their feedback. Iterate until they approve.

## Phase 5: Post the Plan

**Only after explicit developer approval**, add the approved plan as a comment on Linear issue $ARGUMENTS via `linear-server`. Do not modify the issue's description — the plan is a comment, not a replacement for the ticket. Present the comment link to the developer.

## Constraints

- **Never write or modify code or files** (no Write, no Edit)
- **Never post the plan without developer approval**
- The plan must be actionable by a less capable model than the one that wrote it — no ambiguity, exact file/function references, no "figure this out during implementation"
