---
name: improve-codebase-architecture
description: Scan a codebase for deepening opportunities AND context-shaping improvements — shallow modules to deepen, bloated contexts to split, scattered logic to gather into a new context, leaky seams to repair, cycles to break — present them as a visual HTML report, then grill through whichever one you pick.
disable-model-invocation: true
---

# Improve Codebase Architecture

Surface architectural friction and propose fixes across **two lenses at once**:

1. **Deepening** — refactors that turn shallow modules into deep ones.
2. **Context shaping** — grouping related functionality into coherent **contexts**, each a deep module at domain scale: split a bloated context, extract a new one for logic that's smeared across entry points, repair a seam that other code reaches past, break a cycle between contexts.

Both lenses share one aim: **leverage** for callers, **locality** for maintainers, and testability for everyone.

A **context** is a coarse deep module that owns one domain area: its public functions are the **interface**, its data access and rules are the **implementation** hidden inside, and its **seam** is where the rest of the system (entry points, other contexts, jobs, UI) calls in. Everything in the design vocabulary applies unchanged — the deletion test, "the interface is the test surface," "one adapter = hypothetical seam, two = real" — just applied at domain granularity.

This command is _informed_ by the project's domain model and built on a shared design vocabulary:

- Run the `/codebase-design` skill for the architecture vocabulary (**module**, **interface**, **depth**, **seam**, **adapter**, **leverage**, **locality**) and its principles. Use these terms exactly. **"context" is admitted as a first-class term here** — it names a domain-scale module — but keep avoiding **"boundary"**: say **seam** for the location and **context** for the module.
- See [CONTEXTS.md](CONTEXTS.md) for the context lens: the principles that shape a good context, the friction signals to hunt for, the candidate taxonomy, how to map a domain into contexts, and the context-map diagram patterns.
- The domain language in `CONTEXT.md` (and `CONTEXT-MAP.md`, if the repo has multiple contexts) gives names to good seams; ADRs in `docs/adr/` record decisions this command should not re-litigate.

## Process

### 1. Explore

Read the project's domain glossary (`CONTEXT.md`, and `CONTEXT-MAP.md` if present) and any ADRs in the area you're touching first.

Then use the Agent tool with `subagent_type=Explore` to walk the codebase. Don't follow rigid heuristics — explore organically and note where you experience friction. Look through **both** lenses.

**Depth friction** (per module):

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

**Context friction** (per domain area) — see [CONTEXTS.md](CONTEXTS.md) for the full signal list:

- **God context** — one module grouping several unrelated resources behind one sprawling interface.
- **Scattered logic / missing context** — domain rules and data access smeared across entry points (controllers, handlers, UI, jobs) with no module owning them.
- **Leaky seam** — callers reach *past* a context's interface into its internals (data models, queries, private helpers).
- **Cycle** — two contexts depend on each other.
- **Over-split / chatty contexts** — two contexts that always change together and call each other constantly (one adapter = a hypothetical seam).
- **Shared-model bloat** — one data structure accreting fields for every area of the system.

Apply the **deletion test** to anything you suspect is shallow or misplaced: would deleting the module/context concentrate complexity, or just move it? "Yes, concentrates" is the signal you want. For a candidate context, also sketch the domain first (see "Mapping the domain into contexts" in [CONTEXTS.md](CONTEXTS.md)) so a split/extract lands on a real cohesion, not a guess.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Open it for the user — `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows — and tell them the absolute path.

Use the base scaffold, styling, and diagram guidance in [HTML-REPORT.md](HTML-REPORT.md) — Tailwind + Mermaid via CDN, editorial not corporate, diagrams carry the weight. Add the **context-map diagram patterns** from [CONTEXTS.md](CONTEXTS.md) for context-shaping candidates.

For each candidate, render a card with:

- **Kind badge** — one of `deepen module`, `split context`, `new context`, `merge contexts`, `repair seam`, `break cycle`, `de-bloat model` — plus the recommendation-strength badge (`Strong` = emerald, `Worth exploring` = amber, `Speculative` = slate) and the dependency-category tag (`in-process`, `local-substitutable`, `ports & adapters`, `mock`).
- **Files** — which files/modules/directories are involved (`font-mono text-sm`).
- **Before / After diagram** — the centrepiece. For depth candidates use the mass/collapse/cross-section patterns; for context candidates use the context-map/split/extract/cycle-break patterns in [CONTEXTS.md](CONTEXTS.md).
- **Problem** — one sentence. What hurts.
- **Solution** — one sentence. What changes.
- **Wins** — bullets, ≤6 words each, named in glossary terms ("leverage: one interface, N callers", "locality: rules stop leaking", "delete 4 shallow wrappers").
- **ADR callout** (if applicable) — one amber line.

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

**Use `CONTEXT.md` vocabulary for the domain, and the `/codebase-design` vocabulary for the architecture.** If `CONTEXT.md` defines "Order," talk about "the Order context" or "the Order intake module" — not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly (e.g. _"contradicts ADR-0007 — but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

Do NOT propose interfaces yet. After the file is written, ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, run the `/grilling` skill to walk the design tree with them — constraints, dependencies, the shape of the deepened module or reshaped context, what sits behind the seam, which resources move where, what tests survive.

Side effects happen inline as decisions crystallize — run the `/domain-modeling` skill to keep the domain model current as you go:

- **Naming a context or deepened module after a concept not in `CONTEXT.md`?** Add the term to `CONTEXT.md`. Create the file lazily if it doesn't exist.
- **Splitting one context into several, or creating a new one?** The repo now has multiple contexts — record them in `CONTEXT-MAP.md` (create it lazily), and give each context its own `CONTEXT.md` per the structure in the `/domain-modeling` skill.
- **Sharpening a fuzzy term during the conversation?** Update the glossary right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing — skip ephemeral reasons ("not worth it right now") and self-evident ones.
- **Want to explore alternative interfaces for the deepened module or reshaped context?** Run the `/codebase-design` skill and use its design-it-twice parallel sub-agent pattern.
