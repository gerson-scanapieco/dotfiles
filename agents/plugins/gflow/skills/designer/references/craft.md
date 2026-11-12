# Craft

The principles you design and critique by. They are defaults, not laws: break one when you have a reason, and say what the reason is.

## Start from the user's task

- Every screen has one main job. Decide what it is before laying anything out, and make that job the most obvious thing on the screen.
- Design for the content and data the screen really holds, not for an idealised sample.
- Prefer the patterns users already know from the platform and from comparable products. Novelty costs learning; spend it only where it pays off.
- Reduce the work the user has to do: fewer decisions, fewer steps, sensible defaults, information shown where the decision is made.

## Hierarchy

- Make importance visible through size, weight, colour, position and space, in that order of strength. Use as few of these levers as needed.
- One primary action per view. Secondary actions are visually quieter, and destructive actions are clearly distinct and never the default.
- Squint test: blur the screen; the most important element and the reading order should still be clear.
- Group related things and separate unrelated ones with space before reaching for borders, boxes and dividers.

## Layout and spacing

- Use a spacing scale (for example 4, 8, 12, 16, 24, 32, 48, 64) and nothing outside it.
- Space inside a group is smaller than space between groups.
- Align everything to a small number of edges. Ragged alignment is the most common reason a screen looks amateur.
- Limit line length for reading text to about 60–80 characters.
- Lay out for the narrowest supported screen first, then decide what the extra room on wider screens is used for.

## Typography

- Choose typefaces deliberately, as described in `taste.md`.
- One typeface is usually enough; two at most, with clearly different roles.
- A type scale with a handful of sizes, each with a defined role (page title, section title, body, caption). Body text at least 16px on the web.
- Build hierarchy with size and weight before colour. Avoid all-caps for anything longer than a short label.
- Line height around 1.4–1.6 for body text, tighter for large headings.

## Colour

- Mostly neutrals. One accent colour for interaction and emphasis, plus semantic colours for success, warning, error and information.
- Colour must never be the only signal: pair it with text, an icon or a shape.
- Text contrast at least 4.5:1 against its background (3:1 for large text and for interface elements such as input borders and icons).
- Define dark mode as its own set of tokens, not an inverted light mode: dark surfaces are not pure black, and they get lighter with elevation.

## Components and interaction

- Every interactive element has visible default, hover, focus, active and disabled states, plus loading and error where they apply.
- Touch targets are at least 44×44px.
- Give feedback for every action: immediate acknowledgement, progress for anything slow, and a clear result.
- Prefer undo over confirmation dialogs for reversible actions. Confirm only what cannot be undone, and name the consequence in the dialog.
- Motion explains change (where something came from, where it went). Keep it short (150–300ms) and respect reduced-motion preferences.

## States every design must cover

- **Empty:** the first-time experience, and what to do next. Never just "No data".
- **Loading:** skeletons for content that has a known shape, spinners only for short, unknown waits.
- **Error:** what went wrong in plain words, and how to recover, kept close to where the problem is.
- **Partial and extreme content:** one item, thousands of items, very long names, missing optional fields, numbers with many digits.
- **Permissions and roles:** what each kind of user sees and cannot do.
- **Responsive:** the narrowest and widest supported screens.

## Writing

- Interface text is part of the design. Write it while designing, not afterwards.
- Buttons say what they do ("Save changes", "Send invite"), not "OK" or "Submit".
- Use the user's words, not the system's. Keep labels short, and be consistent with terms across the product.
- Error messages say what happened and what to do next, without blaming the user.

## Accessibility basics

- Everything works with a keyboard, in a logical order, with a visible focus indicator.
- Form inputs have visible labels, not placeholder text as a label.
- Images and icon-only buttons have text alternatives.
- Headings and landmarks reflect the structure of the page.
- Contrast as above, and text that survives 200% zoom.

## Critiquing

When critiquing a design, yours or someone else's, go from the biggest problems to the smallest:

1. Does it solve the user's task? Is the main job obvious?
2. Is the structure right: flow, information architecture, what is on this screen versus elsewhere?
3. Hierarchy, layout and consistency with the design system.
4. States, edge cases and accessibility.
5. Visual polish and copy.

For each problem, say why it matters to the user and propose a concrete fix.
