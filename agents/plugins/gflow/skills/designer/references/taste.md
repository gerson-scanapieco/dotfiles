# Taste

`craft.md` makes a design correct. This makes it good: distinctive, deliberate, and recognisably made for this product. Competent but generic is a failure, not a safe default.

## Point of view

- Every product gets a visual point of view derived from its personality in `DESIGN.md`. Before styling anything, be able to say in one sentence why this design looks the way it does, and why it would look wrong on a different product.
- Restraint over decoration. Every element, border, shadow, colour and icon earns its place by helping the user; remove what does not.
- Contrast creates interest: large against small, dense against airy, quiet surfaces against one confident accent. A design where everything has the same size, weight and spacing is flat.
- Let the content lead. Real data, real words and real imagery shape the layout, not a template the content is poured into.
- Give each product one signature: a memorable detail that is its own, such as a typographic treatment, a way of showing its core data, or a distinctive layout. One, not five.
- Sweat the details: optical alignment, consistent rhythm, numerals that line up, careful line breaks in headings. They are most of the difference between polished and generic.

## The generic AI look

These are the defaults that make interfaces look machine-made. Never use one by default; use one only when you can name the reason it is right for this product, and say it.

- Purple, indigo or blue-to-pink gradients, gradient text, glows, and decorative blurred blobs or grid backgrounds.
- The Tailwind default palette and shadows used as-is (slate neutrals with an indigo-500 accent, `shadow-lg` everywhere).
- Inter or the system font chosen by default rather than on purpose.
- Everything in a rounded card with a shadow, cards nested in cards, and the same large radius on every element.
- The landing-page template: a centered hero with a pill badge, a gradient headline, two buttons, and a row of three feature cards with icons in coloured circles.
- The dashboard template: a row of four stat cards with percentage deltas and arrows, above a line chart, regardless of what the user needs to know.
- The SaaS shell of sidebar, top bar and card grid applied to every product, whatever its shape.
- Glassmorphism, neon accents on dark backgrounds, and emoji used as icons.
- Uniform padding everywhere, every element centered, and every section the same height.
- Marketing filler copy ("Unlock the power of", "Seamless", "Elevate your workflow") and placeholder identities ("John Doe", "Acme Inc").

Check every prototype against this list during self-review.

## Typography

Typography carries most of a product's personality, so choose it deliberately and explain the choice.

- Start from the personality and the content. Know what each family conveys: grotesque sans serifs read neutral and modern, humanist sans serifs warm and readable, geometric sans serifs clean and sometimes cold, serifs editorial or traditional or literary, monospace technical and precise.
- Show, don't assert: present 2–3 candidate typefaces or pairings set in the product's real screens, with a recommendation and why.
- Check the practical needs before committing: the weights you need, tabular numerals for data, legibility at small sizes, the languages and characters the product needs, and licensing for production use.
- Look beyond the obvious. Good candidates are available from Google Fonts and Fontshare, and those also load in prototypes from their CDNs.
- Set it with care: tighter letter spacing on large headings, slightly looser and tracked on small all-caps labels, tabular numerals in tables and figures, real quotes, apostrophes and dashes, and no orphaned single words in headings where it can be avoided.
- Record the choice and the reason in `DESIGN.md` and `decisions.md`.

## References

Working from references is how taste gets shared between you and the developer. See "Working from references" in `SKILL.md` for the process.

- Take qualities from references, not surfaces. "The calm density of its tables" is a quality you can design with; reproducing another product's look is not.
- Look at references outside the product's own category too: editorial design, print, signage and well-made tools in other fields are often where a distinctive idea comes from.
