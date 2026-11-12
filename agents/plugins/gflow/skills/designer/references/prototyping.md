# Prototyping

Prototypes are how you think out loud with the developer. They are for exploring and deciding, not production code: optimise for speed, clarity and fidelity to the idea, not for code quality.

## Format

- One self-contained HTML file per prototype, styled with Tailwind via its CDN script (`<script src="https://cdn.tailwindcss.com"></script>`) and plain inline JavaScript for interaction. No build step, no frameworks, no other dependencies beyond web fonts.
- Load the design system with a relative link to `design/system/tokens.css`, and map its custom properties into the Tailwind config in the page (`tailwind.config = { theme: { extend: { colors: { primary: 'var(--color-primary)' } } } }`), so every prototype stays on the system. During Foundations, each direction defines its own tokens inline until one is chosen.
- Make prototypes clickable where the interaction matters: navigation between screens of a flow, opening menus and dialogs, switching tabs, toggling states. A flow can be one file with several screens switched by a small script.
- Fill them with realistic content for the product: plausible names, numbers, dates and text of realistic length, including some long and some awkward values. How a design handles real content is half of what is being judged.

## Structure in the design home

```
design/work/<slug>/
  brief.md
  index.html                 # the gallery: every round, newest first, with one-line notes
  round-1/
    compare.html             # the options side by side
    a-<name>.html
    b-<name>.html
  round-2/
    ...
  final.html                 # the approved design, with every state reachable
```

Keep every round. Earlier ideas are often worth revisiting, and the gallery shows how the design evolved.

## Presenting options

- Give each option a short descriptive name (`a-sidebar-nav`, `b-top-tabs`), not just a letter.
- `compare.html` shows the options side by side when they fit, or as tabs when they are full-screen, each with a two- or three-line summary: the idea, its strength and its cost.
- Add numbered callouts to the elements you want feedback on, so the developer can say "I like 3 but not 5" without having to describe the element. Make the callouts toggleable so the design can also be seen clean.
- Show the state switchers needed to judge the design: empty, loading, error, long content, dark mode if the product has one, and a narrow-screen view when the design is responsive.
- Name your recommendation and the reason in the message where you present the round, and keep the message short. The prototypes carry the detail.

## Opening prototypes

Give the developer the full absolute path of the file to open. When the harness can open files for them (for example `open <path>` on macOS), open the comparison page directly.

## Self-review before showing

Before you show any prototype, look at it the way the developer will:

1. Render it with `agent-browser` (`agent-browser open file://<path>`), and capture screenshots at a desktop width and, when relevant, a phone width (`agent-browser set viewport 390 844`) and in dark mode (`agent-browser set media dark`). Save the screenshots to your scratch space, not to `design/`.
2. Look at the screenshots and check them against `craft.md` and the generic AI look in `taste.md`: broken layouts, overflow, misalignment, weak hierarchy, low contrast, cramped or uneven spacing, unrealistic content, missing states.
3. Click through the interactions that matter and confirm they work.
4. Fix what you find, then show it.

If `agent-browser` is not available, use whatever browser tooling the harness provides; if there is none, tell the developer that the prototype was not visually checked.
