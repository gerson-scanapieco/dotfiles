# Foundations

How to run a Foundations engagement and what it leaves in the design home.

## Discovery

Before exploring visuals, understand enough to make informed choices. Ask, a few questions at a time:

- What the product does and for whom, in one or two sentences.
- Who the users are, how often and in what context they use it (at a desk for hours, on a phone between tasks, once a month), and how experienced they are.
- The feeling the product should give, as a few adjective pairs to place it on (calm or energetic, playful or serious, premium or approachable, dense or airy). When the developer struggles to answer, show them instead of asking.
- Products they admire or dislike, and what specifically about them, gathered as described in "Working from references" in `SKILL.md` and recorded in `design/inspiration/README.md`.
- Existing constraints: a logo, brand colours, platforms (web, mobile, desktop), a UI component library already in use.

Summarise this in `DESIGN.md` before exploring directions, and confirm it with the developer.

## Exploring directions

- Pick one or two representative screens of the real product, such as its main screen and a form, and design each direction on them with realistic content.
- Make the directions genuinely different: typeface (chosen as described in `taste.md`), colour approach, density, shape language (sharp or rounded), use of depth and borders. Three meaningfully different directions beat five variations of one.
- Give each direction a name and a one-line idea ("Ledger: dense, quiet, numbers first"), and recommend one.
- Expect to mix: the developer will often like the colour of one and the density of another. Combine them into a new round rather than forcing a pick.

## Building the system

Once a direction is chosen, turn it into a system small enough to keep consistent and complete enough to design the product's first screens:

- **Tokens** (`design/system/tokens.css`): CSS custom properties for colour (neutrals scale, accent, semantic colours, surfaces, borders, text), typography (families, sizes, weights, line heights), spacing scale, radii, shadows or elevation, and motion durations. Include the dark theme if the product has one. Name tokens by role (`--color-text-muted`, `--color-surface-raised`), not by value (`--gray-500`), except for the raw scales the role tokens reference.
- **Components** (`design/system/components.html`): a living style guide that renders each core component in all its variants and states using the tokens: buttons, inputs and form controls, selection controls, cards or list items, navigation, dialogs, toasts or banners, tables if the product shows data, and empty states. Add components as the product needs them, not speculatively.
- **Patterns** (`design/system/patterns.md`): how recurring situations are handled across the product, such as forms and validation, destructive actions, empty states, loading, notifications, and page layouts.

Review `components.html` with `agent-browser`, as you would a prototype.

## `DESIGN.md` template

```markdown
# <Product> design

## Product
<What it is and the problem it solves, in a few sentences.>

## Users
<Who they are, their context of use, their experience level, and their main jobs.>

## Personality
<The feeling the product gives, as a few adjectives, and what it deliberately is not.>

## Principles
<3–5 principles specific to this product that guide trade-offs, e.g. "Numbers first: data is the hero, chrome stays quiet." Each with one sentence on what it means in practice.>

## Visual language
<A short summary of the chosen direction: typography, colour, density, shape, depth, imagery and iconography. Link to `system/`.>

## Guidelines
<Rules for consistency that tokens and components cannot express: tone of voice, terminology, layout conventions, how to use the accent colour, and so on.>

## Platforms and constraints
<Supported platforms and screen sizes, accessibility target, technical constraints such as an existing component library.>
```

## `decisions.md` entry format

```markdown
## YYYY-MM-DD: <decision>
- **Context:** <what prompted it>
- **Decision:** <what was decided>
- **Alternatives:** <what else was considered>
- **Why:** <the reasons>
```
