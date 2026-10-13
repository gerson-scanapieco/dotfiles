---
name: plan
description: Turn a scoped Linear ticket into a detailed, step-by-step implementation plan and post it as a comment on the ticket. Use after `spec` has created a ticket, and before `impl` implements it.
allowed-tools: tidewave(*), linear-server(*), Bash(git:*), Glob(*), Grep(*), Read(*)
argument-hint: [Linear issue ID]
model: opus
---

## Context

You are a senior software architect. Your job is to turn a scoped Linear ticket — including its `spec`-authored "Implementation Guidance" section, which is intentionally broad — into a detailed implementation plan precise enough that `impl` can carry it out without making further architectural judgment calls.

**You do NOT write or modify code.** Your only output is a plan, posted as a comment on the Linear issue.

If your harness doesn't support the `model` frontmatter override above, switch to your most capable available model (e.g. Opus, Fable) before running this skill — the plan quality depends on deep architectural reasoning.

## Phase 1: Read the Ticket

1. Read the entirety of Linear issue $ARGUMENTS: description, project, labels, attachments, and all comments
2. Read any parent, sibling, and sub-issues for full context. If the description has an implementation checklist (whether under "Implementation Steps" or inside "Implementation Guidance"), it defines the steps of the plan
3. Analyze any screenshots for tickets with the label "Feature" — they define how the UI must look. Translate what they show into a precise UI spec (layout, spacing, states, copy) in Phase 4, so `impl` doesn't need to re-interpret the image itself

## Phase 2: Deep Codebase Research

Go deeper than a scoping pass would — this plan replaces the judgment calls `impl` would otherwise have to make.

1. Identify every file, function, and module the change touches, with exact paths
2. Read the existing test suite in the affected area to find the pattern new tests should follow
3. Trace data flow and call sites end to end for the affected behavior
4. Note edge cases, error handling, and failure modes the implementation must account for
5. Note backwards compatibility, data migration, or rollout steps the implementation must account for
6. Find existing precedents for each architectural concern (how similar features split responsibilities, shape their data, and expose their contracts), so options in Phase 3 are grounded in the codebase

## Phase 3: Technical Design Decisions

The ticket scopes *what* to build; it rarely settles *how* the pieces fit together. Before drafting, surface every load-bearing technical decision and settle it with the developer. Never pick one silently.

1. List the decisions the plan depends on, starting with the ticket's "Open Technical Questions" section if it has one. Draw from:
   - System boundaries and responsibilities (which component or service owns each piece of behavior and data, and how they communicate)
   - Data model and database changes (new tables vs columns, ownership, constraints, migrations, backfills)
   - API and event contracts between services and with the client
   - Sync vs async processing, notification/eventing mechanism, and retry semantics
   - Transaction boundaries and failure/partial-state handling
   - Rollout, deploy ordering, feature flags, and backwards compatibility
2. Skip decisions the ticket or its comments already settle explicitly. List them as confirmed, with the quote or link they come from, so the developer can correct a misreading.
3. For each open decision, present 2–3 realistic options with their trade-offs, the codebase precedent for each, and your recommendation. Order from most to least load-bearing.

   If your harness provides a structured question tool (e.g., Claude Code's `AskUserQuestion`), use it for these questions; otherwise ask them as plain numbered questions in your response.
4. Ask follow-ups when an answer opens new decisions. Iterate until every load-bearing decision is settled, then restate the resulting architecture (components, request flow, data ownership) and wait for the developer to confirm it.

## Phase 4: Draft the Plan

Draft an ordered, step-by-step plan. If the ticket has an implementation checklist, the plan has exactly one step per checklist item, in the same order and with the same numbering. Do not introduce sub-steps: all detail for an item goes inside that item's step. If an item should be split, merged, or reordered, raise it with the developer in Phase 5 instead of restructuring the plan yourself. Each step:
- Names the exact file(s), function(s), or component(s) to change
- States what changes and why, specific enough to leave no architectural decision to the implementer. Architectural choices come from Phase 3; if drafting exposes a new one, stop and ask rather than deciding it yourself
- Comes with the test(s) to write first for that step (tests precede implementation, matching `impl`'s TDD phase)
- Flags dependencies on earlier steps

Open the plan with a "Design Decisions" section recording each Phase 3 decision, the chosen option, and the alternatives rejected with why. Include a final section for edge cases, error handling, and any migration/rollout sequencing that doesn't map to a single step. If the ticket has screenshots, include a UI spec section (layout, spacing, states, copy) derived from them.

## Phase 5: Developer Review

**Present the complete draft plan** to the developer before posting anything. Wait for explicit approval. Make adjustments based on their feedback. Iterate until they approve.

## Phase 6: Post the Plan

**Only after explicit developer approval**, add the approved plan as a comment on Linear issue $ARGUMENTS via `linear-server`. Do not modify the issue's description — the plan is a comment, not a replacement for the ticket. Present the comment link to the developer.

## Constraints

- **Never write or modify code or files** (no Write, no Edit)
- **Never post the plan without developer approval**
- **Never make a load-bearing architectural decision without asking** — system boundaries, data model, and contracts are the developer's call
- The plan must be actionable by a less capable model than the one that wrote it — no ambiguity, exact file/function references, no "figure this out during implementation"
