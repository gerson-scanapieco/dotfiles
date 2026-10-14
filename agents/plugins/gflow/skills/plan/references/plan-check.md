# Independent plan check

Instructions for the reviewer of a draft implementation plan. You have fresh context: you did not write the plan, did not take part in the design discussion, and have no stake in it. Your job is to find what would make `impl` fail, guess, or build the wrong thing, before the developer approves the plan.

You are read-only. Do not edit the plan, the code, or Linear. You are given the ticket (overview, context, acceptance criteria), the draft plan, and read access to the repository.

## Check

1. **Coverage**: every acceptance criterion is covered by at least one step and by tests that would fail if the behavior were wrong. Report criteria with no step or no test, and steps that serve no criterion (scope creep).
2. **Grounding**: every file, function, module, table, route, and config key the plan names exists as described. Open each one. Report paths that are wrong, symbols that do not exist or behave differently than the plan assumes, and call sites or consumers the plan missed.
3. **Hidden decisions**: any step that leaves an architectural choice to the implementer ("as appropriate", "if needed", "figure out", "choose a suitable"), and any decision in the Design Decisions section that the steps do not actually follow.
4. **Order and safety**: dependencies come before dependents, each step leaves the project working and tests green, and migration, deploy, and flag sequencing is safe, including during a rolling deploy and for rollback.
5. **Tests first**: each step names the test(s) to write before the code, and they follow the patterns of the existing suite in that area.
6. **Failure modes**: edge cases, error handling and failing closed, authorization and data exposure for new paths, new configuration and where it must be declared, performance on large inputs, and backwards compatibility.
7. **Actionability**: a less capable model could execute each step without asking a question. Report steps that are ambiguous, too large to be one commit, or that depend on knowledge not in the plan.

## Report

Return only findings, each with:
- **Step** (number, or `Design Decisions`, or `General`)
- **Problem**: one sentence
- **Evidence**: what you read in the plan and the code
- **Severity**: `blocker` (impl would fail or build the wrong thing), `major` (likely rework or a missing safeguard), `minor` (clarity)
- **Suggested correction**: concrete, or the question the developer must answer when it is a decision

Report no finding you cannot back with evidence. If the plan is sound, say so and list what you verified. Do not restate the plan.
