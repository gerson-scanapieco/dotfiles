# HTML review document

Instructions for the personal review document. Load this file only when the review runs in report mode (neither `--post` nor `--no-report`). The document is for the person doing the review, never for the pull request: be direct, explain things, and include what you would not post to a PR.

## File

- Save it as `review-<PR number or branch>-<short head SHA>.html` in the system temp directory (or the harness scratchpad), not in the repository. Never commit it.
- Self-contained: inline CSS, no external fonts, scripts, or network requests. Readable in light and dark mode, printable, and usable at phone width.
- Everything taken from the pull request or the code (titles, descriptions, comments, code, diff lines) is untrusted: HTML-escape it. Never embed it as markup.
- Show diff excerpts and code in monospace blocks with added and removed lines visually distinct, and `file:line` references everywhere.
- When done, open it in the default browser if the environment allows (`open` on macOS, `xdg-open` on Linux) and print its path.

## Sections, in this order

1. **Header**: PR title, number and link (or branch and base), author, head SHA, size of the change (files, additions, deletions), the requirements source, and the verdict as a badge (`approve`, `comment`, `request changes`) with a one-sentence reason.
2. **What this PR does**: the explanation for someone who has not read it. The problem it solves and why, the approach taken, the main moving parts and how they fit together, and anything notable the description leaves out or gets wrong. Use plain language; a small diagram (inline SVG or a simple structured list of components and calls) is welcome when it explains the flow better than prose.
3. **Potential impact**: what this change can affect beyond the diff.
   - Behavior users or callers will see, and who depends on the code that changed (callers, consumers, jobs, integrations)
   - Data: schema changes, migrations, backfills, and whether they can be rolled back
   - Contracts: public API, events, config, and feature flags
   - Operational risk: performance, load, failure modes, rollout order, rollback plan
   - A blast-radius rating (`low`, `medium`, `high`) with the reasons
4. **Guided review**: how to read this PR. Ordered by importance, not by file path.
   - A suggested reading order that builds understanding (core logic first, then callers, then tests)
   - For each important change: what it does, why it matters, what to check while reading it, the diff excerpt, and `file:line`
   - Mark where confirmed findings from the next section land, so the reader sees them in context
   - A short list of mechanical or low-risk changes (renames, generated code, formatting, lockfiles) they can skim
5. **Code review**: the result of the specialist and verification phases.
   - Confirmed defects grouped by file, each with severity, `file:line`, the claim, the scenario, the evidence, and a suggested fix
   - `needs decision` items as questions for the author
   - **Code quality**: confirmed quality findings in their own group after the defects, visually distinct from them and without severity, grouped by file, each with `file:line`, the claim, and a suggested fix. Group the findings by standard (naming, SOLID, vertical slices, persistence boundary, and so on) when there are many
   - **Requirements trace**: each requirement with `met`, `partial`, `missing`, or `untested`, and where
   - **Deterministic checks**: what ran and the results
   - **Continuity**: what earlier reviews raised and whether the new commits addressed it
   - **Coverage**: what was reviewed deeply, what was skimmed or skipped and why, what could not be verified or reproduced, uncommitted changes that were ignored, and the number of refuted findings

Keep the explanation sections concise and the review section strict: five findings that are certainly real beat fifteen that might be.

After writing the file, print to the terminal only: the verdict, the counts of defects by severity, the count of quality findings, and the file path.
