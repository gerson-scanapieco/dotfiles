# Reviewer rules

Every lens receives the **Shared rules** and its own section, and nothing else from this file. Telling a reviewer what not to flag is what keeps its output worth reading: a finding that is true but not worth the author's time still costs them attention.

When unsure whether something belongs in the review, leave it out.

## Severity

Severity is what happens if the change ships as it is.

- `blocker`: exploitable; loses or corrupts data; causes an outage; breaks existing callers; leaves a requirement unmet
- `major`: a real defect with a concrete scenario that is bounded or recoverable; a requirement only partly met or with no test that would fail without it
- `minor`: correct but weaker than it should be: maintainability, a small inconsistency, a low-impact edge case

Only a `blocker` blocks the merge; `major` and `minor` are reported as non-blocking comments. Rate by the scenario you can describe, not by the category of the issue: an injection pattern with no reachable untrusted input is not a `blocker`.

## Self-check

Run this on every finding before returning it, and drop the finding if any answer is no:

1. Did you read the cited code at the head being reviewed, not only the diff hunk?
2. Did you read the callers and the nearest guards, types, validators, and tests, and does none of them already handle the scenario?
3. Can you state the input or state, and the wrong outcome, in two sentences without "might", "could", or "may"?
4. Is the defect introduced or made reachable by this change?
5. Would the project's maintainers, reading your claim and scenario, agree it needs a change rather than a different taste?

Report only findings with `high` or `medium` confidence. If you would rate one `low`, drop it. If the only thing missing is information from outside the diff, such as infrastructure or product intent, put it in your coverage notes as not judged.

## Shared rules

Do not report:
- Formatting, naming, or style that a configured formatter, linter, or type checker enforces
- Issues that exist only in unchanged code, unless the change makes them reachable or worse
- Anything without a concrete scenario: input or state, and the wrong outcome it produces
- Theoretical risks that need an unlikely precondition, such as an attacker who already has the access the finding would grant
- Defense-in-depth suggestions when the primary defense is adequate
- "Consider using library X" or other alternative-approach suggestions when the current approach works
- Personal preference, or a different but equally valid way of doing the same thing
- Something the project's `AGENTS.md` or `CLAUDE.md` explicitly allows or chooses
- A finding already raised by a human or an earlier review, unless the new commits made it worse

A lens with nothing to report says "no findings". Five findings that are certainly real beat fifteen that might be.

## Correctness

Flag: behavior that is wrong for a reachable input or state; error paths that swallow, mistranslate, or leak failure; resources not released on every path; changed behavior for existing callers that nothing accounts for; in front-end code, incorrect React hook and state usage (see `frontend.md`).

Do not flag:
- Missing null, bounds, or type checks that the types, callers, or an upstream validator already guarantee
- Missing handling for states the project's invariants rule out
- Concurrency problems you cannot describe as a concrete interleaving
- Error handling that differs from your taste but behaves correctly
- Micro-optimizations and readability rewrites

## Requirements and tests

Flag: requirements that are missing, partially met, or untested; behavior added that nobody asked for; tests that cannot fail, assert the wrong thing, or mock away the behavior they claim to cover.

Also flag tests that verify the implementation instead of the behavior, as `minor` non-blocking comments:
- Tautological tests: the expectation is computed with the same logic as the code under test, asserts a value the test itself set up (a mock's return value, a constant), or would still pass if the implementation were replaced by a stub
- Tests coupled to internals: they assert private methods, call counts, call order, or internal structure, so a refactor that keeps the behavior would break them
- Snapshots of the implementation's output that no assertion about behavior backs

When such a test is the only coverage of a requirement, report the requirement as untested instead.

Do not flag:
- Missing tests for trivial code (getters, pass-through wiring, constants) or behavior outside the requirements
- Interaction assertions at a real boundary, where the call is the behavior (a payment request sent, an event published)
- Test style, naming, or structure preferences
- Coverage percentages
- Requirements you inferred yourself but the issue or description never states, except as a `needs decision` question

## Security and access control

Flag: new or changed paths that depart from the project's established authorization, authentication, crypto, input, or logging mechanism; each walked against the checklist categories.

Do not flag:
- Theoretical risks that require unlikely preconditions, a compromised dependency, or an already-privileged attacker
- Defense-in-depth additions when the primary defense is adequate
- Issues in unchanged code the diff does not touch or newly expose
- "Use library X" or "add a WAF or rate limiter" suggestions without a specific abuse scenario in this change
- Generic hardening advice not tied to a line of the diff
- Things only an environment or infrastructure review could know. Put these in coverage as not judged

## Design and consistency

Flag: duplicated logic that already exists elsewhere in the codebase (name where); deviation from an established project pattern (name the pattern and where it lives); compatibility breaks in public APIs, schemas, or migrations; boundaries violated in a way that will cause the next change to break.

Also flag, as `minor` non-blocking comments, comments the change adds that explain how the code works instead of why: they restate or narrate the next line, so deleting them loses nothing. A comment that contradicts the code it describes is also flagged, because it misleads the next reader. The project's comment conventions in `AGENTS.md` or `CLAUDE.md` take precedence.

Do not flag:
- Architecture you would have chosen differently when the chosen one is consistent with the project
- Abstractions you think are missing or premature
- Comments that give a reason: a constraint, a workaround, a non-obvious decision, a link to the ticket or spec; doc comments the project requires on public APIs; license headers
- File organization, naming, or comment density preferences
- Patterns the project does not actually follow, even if they are common elsewhere
- Refactors of code the change does not touch

## Performance and operations

Flag: N+1 queries and unbounded work or memory on a path that is hot or user-driven; missing indexes for a new query shape; blocking calls on a hot path; retries without backoff or bounds; new failure modes with no observability the project would normally have.

Timeouts on external calls (HTTP, database, queue, RPC) are part of this lens. Flag:
- A call with no timeout where the client's default is none or effectively infinite. Check the client library's default before reporting
- A timeout longer than the caller's own deadline, such as a 60 second call inside a request that is cut off at 30
- An inner timeout, or retries multiplied by their timeouts, that exceeds the outer budget
- A timeout so long that the user or the calling job gives up first

In front-end code, flag performance problems that follow `frontend.md`.

Do not flag:
- Calls whose client or framework supplies a suitable default, or where a deadline is propagated from the caller
- Optimizations without a load, size, or frequency that makes them matter
- Performance of code that runs once, at boot, or in a bounded small loop
- Caching suggestions without a demonstrated cost
- Logging, metrics, or tracing the project does not use elsewhere

## Configuration and deployment

Flag: configuration the code reads that is not declared everywhere the project declares it; defaults that are unsafe in production or fail late and silently; feature flags that are checked but never created; deploy, migration, and flag orderings that break during a rolling deploy or cannot be rolled back.

Do not flag:
- Configuration the project deliberately keeps out of its templates or manifests
- Values that are already validated at boot by the project's config layer
- Environment differences the project already handles for every setting in the same way
- Rollout concerns for changes that are additive, backward compatible, and flagged off
