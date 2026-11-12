# Handoff

The handoff tells someone who was not in the design conversation exactly what to build. Write it for an engineer or a coding agent: precise, complete, and free of the exploration history. The final prototype shows the design; the handoff explains everything the prototype cannot show on its own.

Reference the design system's tokens and components by name instead of restating raw values. When the design needs something new in the system, the system is updated first and the handoff points to it.

Write it to `design/work/<slug>/handoff.md`:

```markdown
# <Design name>: handoff

## Summary
<What this design is, the user problem it solves, and the main job of each screen, in a few sentences.>

## References
- Final prototype: `design/work/<slug>/final.html`
- Design system: `design/system/` (list any tokens, components or patterns added or changed for this work)
- Brief: `design/work/<slug>/brief.md`

## Flow
<The steps of the flow, entry points and exits, and what triggers each transition. Omit for a single screen.>

## Screens
### <Screen name>
- **Purpose:** <its main job>
- **Layout:** <structure and how it adapts across screen sizes>
- **Content:** <each element, the data it shows, and its source when known>
- **Components:** <design system components used, with variants>
- **Interactions:** <what each interactive element does, including keyboard behaviour>
- **States:** <empty, loading, error, partial and extreme content, permissions; each described or shown in the prototype>
- **Copy:** <final interface text, including errors and empty states>

## Accessibility
<Focus order, labels and text alternatives, announcements for dynamic changes, and anything else beyond the system's defaults.>

## Out of scope
<What was discussed but deliberately left out, so the implementer does not add it.>

## Open questions
<Anything still undecided that the implementer must raise rather than guess. Empty when nothing is open.>
```

Before calling the handoff done, check that every state and interaction in `final.html` is described, and that every screen and state described can be seen in `final.html`.
