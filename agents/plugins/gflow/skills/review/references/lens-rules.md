# Reviewer rules

Every lens receives the **Shared rules** and its own section, and nothing else from this file. Telling a reviewer what not to flag is what keeps its output worth reading: a finding that is true but not worth the author's time still costs them attention.

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

Say "no findings" rather than inventing one. Five findings that are certainly real beat fifteen that might be.

## Correctness

Flag: behavior that is wrong for a reachable input or state; error paths that swallow, mistranslate, or leak failure; resources not released on every path; changed behavior for existing callers that nothing accounts for.

Do not flag:
- Missing null, bounds, or type checks that the types, callers, or an upstream validator already guarantee
- Missing handling for states the project's invariants rule out
- Concurrency problems you cannot describe as a concrete interleaving
- Error handling that differs from your taste but behaves correctly
- Micro-optimizations and readability rewrites

## Requirements and tests

Flag: requirements that are missing, partially met, or untested; behavior added that nobody asked for; tests that cannot fail, assert the wrong thing, or mock away the behavior they claim to cover.

Do not flag:
- Missing tests for trivial code (getters, pass-through wiring, constants) or behavior outside the requirements
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

Do not flag:
- Architecture you would have chosen differently when the chosen one is consistent with the project
- Abstractions you think are missing or premature
- File organization, naming, or comment density preferences
- Patterns the project does not actually follow, even if they are common elsewhere
- Refactors of code the change does not touch

## Performance and operations

Flag: N+1 queries and unbounded work or memory on a path that is hot or user-driven; missing indexes for a new query shape; blocking calls on a hot path; retries without backoff or bounds; new failure modes with no observability the project would normally have.

Do not flag:
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
