---
name: explain-diff
description: Summarize what a set of code changes does to a project's design — the modules, classes, and functions that changed, and how they now relate. For reviewers who track the high-level layout while delegating low-level detail to the LLM.
disable-model-invocation: true
allowed-tools: Glob(*), Grep(*), Read(*), Bash(git:*), Bash(gh:*)
argument-hint: [PR number/URL, branch name, or empty for working changes]
---

## Context

You are helping a **reviewer** understand how a set of changes affects the project's design: its modules, classes, functions, and how they connect — plus its data storage and the services it runs on. The reviewer reads code, but wants to track the high-level layout, not re-derive every line. Low-level implementation is assumed delegated to the LLM; your job is to show what moved and what the reviewer should check.

## Steps

1. **Resolve the target** from `$ARGUMENTS`:
   - A PR number or URL → `gh pr diff <n>` for the patch, `gh pr view <n>` for title/description.
   - A branch name → diff it against its **merge-base** with the default branch, so you show only what this branch adds: `git merge-base <branch> origin/HEAD` then `git diff <merge-base>...<branch>`. Find the default branch with `git symbolic-ref refs/remotes/origin/HEAD` (fall back to `main`, then `master`).
   - Empty → the working changes: `git diff HEAD` plus staged. If the working tree is clean, say so and stop.

2. **Get the changed files and the full diff.** Read enough of the surrounding code (not just the diff hunks) to know what each changed part *does* and *why it exists*.

3. **Inventory every changed module, class, and function.** This step is done only when **every changed module, class, and function appears in your summary** — none silently dropped. Group related ones; batch trivial changes (formatting, pure renames, moved code) into a single line, but say they were batched. A vague "several helpers changed" fails this step.

   - **If the change is documentation or config only** (no code), skip the code inventory. Instead summarize what the docs or config now say, and what depends on them — which tool reads this config, where the file must live to take effect, what breaks if it is wrong.

4. **Write the summary** using the shape and language rules below.

5. **Draw a mermaid diagram only if the change is complex** — see *Diagrams*.

## The 12-year-old test

Before using a word, ask: would a smart 12-year-old know it? If a word describes the code by comparison to another field, replace it with what is literally happening.

- Building words — *architecture, foundation, layer, scaffold, surface* → say the plain thing: "how the code is organized", "the code that runs first".
- Motion/place words — *navigate, flow, pipeline, path, downstream* → "the order the code runs in", "what happens next".
- Other-field words — geology (*sediment, erosion*), sailing (*anchor, steer*), food (*bake, recipe, boilerplate*) → drop them.

Say "the code that runs first" not "the entry point". Say "calls" not "reaches into". If you must use a technical word the reviewer needs (a class name, a table name), keep it — the reviewer reads code; this rule targets vague comparisons, not real names.

## Language rules

- **Lead with the punchline.** One sentence: what these changes do to the project, in plain terms.
- **What and why, not line-by-line how.** The reviewer delegated the line-level detail. Report structure and intent.
- **Name real things.** Use the actual module, class, function, and table names — they are the layout the reviewer is tracking.
- **No praise, no filler.** No "this is a clean refactor", no "let me know if you have questions".

## Diagrams

Draw **one** mermaid diagram only when the change adds or removes a relationship between parts — a new module calling an existing one, a changed order of calls, a new table and how it links to others. If the change stays inside one function, skip the diagram; prose is clearer.

- Call/data flow → `flowchart`. Database change → `erDiagram`.
- Cap it at ~7 nodes. If it needs more, the change is too big for one picture — draw only the part that changed and its immediate neighbours.
- Mark what changed (e.g. a comment or a distinct node label) so the reviewer sees the delta, not the whole system.

## Output shape

```
**[Punchline: what these changes do to the project]**

## What changed
[The inventory from step 3 — grouped by module/class, real names, plain descriptions.]

## Why it matters for the design
[How the layout, data storage, or running services now differ. New relationships, removed ones, shifted responsibilities.]

## Diagram
[Only if complex. A single mermaid block.]

## Watch for
[Short list: delegated implementation a reviewer should double-check — edge cases, error handling, security-sensitive spots, data changes that are hard to undo. Skip if nothing stands out.]
```
