# The Context Lens

How to see a codebase as a set of **contexts** and reshape it toward better ones. Assumes the vocabulary in the `/codebase-design` skill — **module**, **interface**, **implementation**, **depth**, **seam**, **adapter**, **leverage**, **locality**.

## What a context is

A **context** is a coarse **deep module** that owns one domain area. Nothing new — it's the same shape you already know, scaled up to a domain concept instead of a single function:

- **Interface** — the context's public operations, named for *what* they do, not *how*. Plus the invariants they guarantee and the errors they surface.
- **Implementation** — the data access, persistence, queries, and rules, all hidden inside.
- **Seam** — where the rest of the system calls in: entry points (controllers, handlers, CLI, UI), other contexts, background jobs.

Language-agnostic. A context might be a package, a module namespace, a folder of cohesive modules, or a domain module inside a larger service — whatever your stack calls a named, importable unit. What makes it a *context* is not the file layout but the discipline: **one public interface in front, implementation hidden behind, one domain area owned.**

**Vocabulary note.** "context" is a first-class term in this skill — it names a domain-scale module. Keep avoiding **"boundary"**: the *location* is the **seam**, the *module* is the **context**.

## Principles that shape a good context

- **Group related functionality behind one public interface.** Callers learn one small surface and get a whole domain area's worth of behaviour. That's **leverage**.
- **Hide data access and persistence.** Callers never touch the data models, queries, or storage directly — they go through the interface. Swapping storage later shouldn't ripple out to callers.
- **Intent-revealing operations, not raw data plumbing.** Expose `place_order(cart)`, not `insert_row(:orders, attrs)`. The interface should read as domain verbs.
- **Prefer distinct contexts per resource; refactor later.** When unsure whether two resources belong together, keep them apart. Merging later is cheap; untangling a wrongly-merged God context is not.
- **Don't bloat one data structure for the whole system.** A single entity accreting fields for every area is shared-model bloat. Give each context its own model of the concept, named for that context's view of it.
- **Minimize cross-context coupling; never cycle.** A context may depend on another, but not mutually. If you need both directions, the two share a responsibility that wants its own **coordinating context**.
- **Consolidate cross-context operations behind one operation.** A multi-step action that spans contexts belongs behind a single coordinating operation that orchestrates it as one unit — not hand-rolled across three call sites.

## Friction signals to hunt for

| Signal | What you see | Move |
|---|---|---|
| **God context** | One module with a sprawling interface over several unrelated resources | `split context` |
| **Scattered logic / missing context** | Domain rules + data access smeared across entry points, no module owning them | `new context` |
| **Leaky seam** | Callers reach *past* a context's interface into its data models, queries, or private helpers | `repair seam` |
| **Cycle** | Context A depends on B and B on A | `break cycle` |
| **Over-split / chatty** | Two contexts that always change together and call each other constantly | `merge contexts` |
| **Shared-model bloat** | One entity carrying fields for every area of the system | `de-bloat model` |
| **Shallow context** | A context that only forwards to storage and adds nothing (deletion test: complexity just moves to callers) | `deepen module` |

Run the **deletion test** on every candidate: imagine deleting the module/context. If complexity vanishes, it was a pass-through. If it reappears, spread across callers, the module was earning its keep and the fix is to *deepen* it, not delete it.

## Candidate taxonomy

Every candidate carries a **kind** badge in the report:

- **`split context`** — one context → distinct contexts per resource cluster. Redistribute the interface; each new context owns its resources and data.
- **`new context`** — gather scattered domain logic and its data access out of entry points into a fresh context behind a clean interface.
- **`merge contexts`** — fold two over-split contexts into one (justified only when they don't actually vary across the seam: one adapter = hypothetical seam).
- **`repair seam`** — funnel callers that bypass the interface back through it; make the internals private again.
- **`break cycle`** — introduce a coordinating context, or move the shared concept, so dependencies flow one way.
- **`de-bloat model`** — replace one shared data structure with per-context models of the concept.
- **`deepen module`** — the plain deepening move: small interface, more behaviour absorbed inside.

## Mapping the domain into contexts

Before proposing a `split` or `new context`, sketch the domain so the reshape lands on real cohesion, not a guess:

1. **Identify the resources / aggregates** — the root concepts the system stores and mutates.
2. **Group by cohesion** — which resources change together, are queried together, or share invariants? Those belong in one context. Ones that merely *reference* each other usually don't.
3. **Name each grouping with a domain term** — pull the name from `CONTEXT.md`; if it isn't there, that's a term to add (via `/domain-modeling`).
4. **Treat each grouping as a deep module** — public operations = interface, data access = implementation, callers-in = seam. Sanity-check depth: is the interface much smaller than what it hides?

If the map yields more than one context, the repo is multi-context — record it in `CONTEXT-MAP.md` and give each context its own `CONTEXT.md` (see the `/domain-modeling` skill's file structure).

## Testing across the context seam

The **interface is the test surface** — tests cross the same seam callers do. Classify the context's dependencies (from the `/codebase-design` skill's DEEPENING.md) to decide how:

- **In-process** (pure logic, in-memory) — test through the context's public operations directly; no adapter.
- **Local-substitutable** (storage with a local stand-in — test database, in-memory store) — run the stand-in in the suite and test through the public operations. The storage seam stays *internal*; don't expose it at the interface.
- **Remote but owned** (another service you control) — define a **port** at the seam; production adapter for transport, in-memory adapter for tests.
- **True external** (third-party) — inject a port; tests supply a mock adapter.

Replace, don't layer: once tests exist at the context's interface, the old per-internal unit tests are waste — delete them. Tests assert observable outcomes through the interface, so they survive internal refactors.

## Diagram patterns for the report

Extend the base patterns in [HTML-REPORT.md](HTML-REPORT.md) with these context-scale visuals. Mix Mermaid (graph-shaped) with hand-built divs/SVG (editorial). Keep before/after side by side, ~320px tall.

### Context map (the workhorse for context candidates)

A Mermaid `flowchart` of contexts as nodes and cross-context calls as edges. Add a node for the entry-point/UI layer. Colour leak edges and cycle edges red. Before: a tangle. After: an acyclic map, often with a new coordinating context.

```html
<div class="rounded-lg border border-slate-200 bg-white p-4">
  <pre class="mermaid">
    flowchart LR
      UI[Entry points] --> ORD[Ordering]
      UI -.leak.-> DB[(orders table)]
      ORD --> BIL[Billing]
      BIL -.cycle.-> ORD
      classDef bad stroke:#dc2626,stroke-width:2px;
      class DB,BIL bad
  </pre>
</div>
```

### Split diagram

One large context box with a crowded interface list → two or three context boxes, the operations and resources redistributed. Hand-built divs read best here — show the operations physically moving.

### Extract diagram

Entry-point / data-access boxes with domain rules embedded inside them (shown as faded fragments) → an arrow pulling those fragments into a new context box that now owns them, entry points left thin.

### Cycle-break diagram

Before: `A ⇄ B` with both arrows red. After: `A → C ← B`, the new coordinating context `C` holding the shared responsibility, arrows now one-way.

## Tone

Same as the base report: plain English, sparse prose, diagrams carry the weight. Architectural nouns come straight from the `/codebase-design` glossary; domain nouns from `CONTEXT.md`. Don't write "cleaner code" or "better separation" — name the gain as **leverage**, **locality**, or **depth**.
