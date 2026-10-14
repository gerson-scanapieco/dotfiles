---
name: setup-checks
description: Audit a project's deterministic verification (formatters, linters, type checkers, secret scans, and similar tools), work with the developer to add the missing ones, and wire them into git hooks and a single check command. Use when starting on a project, or when a project has no automatic guardrails before code is committed.
argument-hint: [optional: ecosystem, tool, or area to focus on]
---

## Context

You set up the project's deterministic verification: the tools that give the same answer for the same code, with no model involved. They run locally in git hooks and in CI, so mistakes are caught before a human or an agent has to notice them.

Input in $ARGUMENTS is an optional focus (an ecosystem, a tool, or "hooks only"). Without it, cover the whole repository.

You audit first, propose second, change third. Nothing is installed, configured, or reformatted before the developer approves it.

## Phase 1: Discover

Read the repository; ask the developer only what you cannot observe.

1. **Ecosystems**: languages, frameworks, and package managers in use, from manifests and lockfiles (`package.json`, `mix.exs`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `Gemfile`, and so on). A monorepo may have several.
2. **Existing mechanisms**: tool configs (`.eslintrc*`, `eslint.config.*`, `.prettierrc*`, `biome.json`, `ruff.toml`, `.formatter.exs`, `.credo.exs`, `.rubocop.yml`, `tsconfig.json`, `.golangci.*`, `rustfmt.toml`, `.editorconfig`), package scripts, `Makefile` or `justfile` targets, mix aliases, and the checks CI runs (`.github/workflows/*`, `.gitlab-ci.yml`, and similar).
3. **Existing hooks**: the hook manager in use (husky, lefthook, pre-commit, simple-git-hooks, a custom `core.hooksPath`), `.git/hooks/*` that are not samples, and how hooks get installed for a fresh clone.
4. **Conventions**: `AGENTS.md`/`CLAUDE.md`, `README`, and `CONTRIBUTING` instructions about running checks.

For each ecosystem found, read its reference before Phase 2 and again before proposing tools: `references/js-ts.md` (JavaScript, TypeScript, Next.js) or `references/elixir.md` (Elixir, Phoenix). These are defaults, not rules: what the repository already uses takes precedence, and an ecosystem with no reference file is handled from its own conventions.

Run each existing check once on the current tree to learn whether it passes today, how long it takes, and whether it can fix issues automatically. Record the results; do not fix anything yet.

## Phase 2: Report

Present a compact table with one row per category and ecosystem:

| Category | Tool | Status | Runs in | Speed |
|---|---|---|---|---|

Categories to cover, skipping those that do not apply to the project:

- **Format**: code formatter
- **Lint**: static analysis and style rules
- **Types**: type checker or compiler warnings-as-errors
- **Unused code and dependencies**: dead code, unused imports and dependencies
- **Security**: secret scanning, dependency audit, static security rules
- **Commit hygiene**: commit message lint, large-file and merge-conflict-marker guards
- **Config and docs**: JSON/YAML/TOML validity, shell script lint, markdown lint, workflow lint
- **Tests**: the fast unit suite (included only as the slowest tier of checks, never as a replacement for the above)

Status is one of `configured`, `configured but failing`, `partial`, `missing`, or `not applicable`. `Runs in` lists where it is enforced: hook, CI, both, or neither. Call out checks that CI runs but no hook does, hooks that run something CI does not, and checks that are failing today.

## Phase 3: Decide with the developer

Turn each gap into a proposal and ask for decisions. Group them so the developer answers once, not per tool.

For each missing or partial mechanism, propose:
- The tool, preferring the ecosystem's de facto standard and what the repository already depends on over introducing a new one
- The configuration that fits the project's existing conventions, at the strictness level described below
- What it will flag today (run it in a scratch check, or with its dry-run flag, to count violations)
- Which tier it belongs to

Strictness is a decision per tool, not an accident of its defaults. Use three levels:
- **relaxed**: the tool's baseline rules; warnings are reported but do not fail the check
- **standard** (default): the tool's recommended ruleset, with warnings treated as errors so nothing is silently ignored
- **strict**: the standard ruleset plus the tool's opt-in rules (stricter type options, pedantic lint groups)

Propose `standard` for every tool unless the project's existing configuration is clearly looser or stricter, in which case propose that level and say why. State the level and how warnings are treated for each tool in the proposal, and let the developer change it per tool. Use the tool's own mechanism for warnings-as-errors (for example `--max-warnings 0`, `--warnings-as-errors`, `-D warnings`). When existing violations make `standard` fail today, handle them through the baseline options below rather than lowering the level.

Use three tiers, and keep each fast enough for its trigger:
- **Pre-commit**: seconds. Operates on staged files only: formatter, linter, secret scan, file-hygiene guards. Auto-fixes are re-staged only when the developer opted into that
- **Commit-msg**: validates the commit message, only if the project already follows or wants a convention
- **Pre-push**: tens of seconds to a few minutes. Type check, unused code, the fast test suite
- **CI**: everything, authoritative. Hooks are a convenience that can be skipped; CI is the guarantee

Ask the developer about:
- Which proposed tools to add, and which to leave out
- The strictness level for each tool, and whether warnings fail the check
- How to handle existing violations when a tool is new: fix them in a separate commit, record a baseline or ignore list, or enable the tool only for changed files. Never mass-reformat or mass-fix without approval
- The hook manager when none exists (see Phase 4), and whether pre-push should run tests
- Whether CI should be updated in the same change

Do not propose a tool just to fill a category. A project with no TypeScript does not need a type checker, and an extra slow tool costs more than it catches.

## Phase 4: Implement

After approval, do the work yourself: create the files, install the dependencies, and register the hooks. Everything the checks need is committed to the repository so every developer, agent, and CI run goes through the same checks. Do not leave setup steps for the developer to perform by hand, other than the one-time install command that fresh clones run.

1. **Branch**: if on the default branch, create a branch for this work (for example `setup-checks`). Otherwise stay on the current branch.
2. **Dependencies**: install the approved tools with the project's package manager, as development dependencies, pinned the way the project already pins them. Commit the resulting manifest and lockfile changes. Use project-local installs, never global ones, so every developer gets the same versions.
3. **Tool configuration**: create the config files for each approved tool, following the project's existing conventions and `.editorconfig` where present.
4. **A single entry point**: add one command that runs the whole set (for example `npm run check`, `make check`, `mix check`, or a `scripts/check` file), plus a `--fix` or `fix` variant where the tools support it. Hooks and CI call this entry point or the same underlying commands, so they cannot drift.
5. **Hooks**:
   - Extend the hook manager already in use. Do not introduce a second one.
   - With none present, prefer the manager native to the ecosystem (husky or simple-git-hooks for a JavaScript project) and `lefthook` for polyglot or non-JavaScript projects. Use the `pre-commit` framework only if the project is already Python-centric.
   - Hook definitions live in the repository (the manager's config file and hook scripts), never only in `.git/hooks`.
   - Make installation automatic for every developer: a `prepare`/`postinstall` script, a `mix` alias, or the project's existing setup script. If the project has no install step that developers always run, add one and document it.
   - Install the hooks in this clone too, so they are active immediately.
   - Pre-commit hooks run on staged files and complete quickly. Pre-push hooks run the heavier tier.
   - Never set `core.hooksPath` or any git config globally, and never write hooks into `~/.config`.
6. **CI**: when approved, make CI run the entry point so the same checks are enforced there. Do not weaken or remove existing CI steps.
7. **Documentation**: add the check command, the fix command, and the hook behavior to `AGENTS.md` (or `CLAUDE.md` if that is what the project uses) so people and agents know to run them before committing. State that hooks must not be bypassed with `--no-verify`.
8. **Commit**: commit the work in coherent commits (dependencies and config, hooks, CI, docs, and any approved fix-up of existing violations in its own commit). Commit messages follow the repository's conventions. Do not commit scratch or cache files; add the tools' cache directories to `.gitignore`.

## Phase 5: Prove it

A setup that was never exercised is a draft.

1. Run the entry point on the clean tree and show it passing, or list the known failures that the developer chose to baseline.
2. Prove each hook fires: stage a deliberately bad change in a scratch file (a formatting error, a lint violation, a fake secret that matches the scanner's pattern), attempt the commit or push, and show that the hook blocks it. Then discard the scratch change and confirm the working tree is exactly as the developer left it.
3. Prove a fresh-clone install path works: run the documented install step and confirm the hooks are registered.
4. Report how long each tier takes. If pre-commit exceeds about 10 seconds on a typical change, move work to pre-push.

## Final report

Report:
- The audit table before and after
- What was added: the dependencies installed, the files created, and the commits made
- Existing violations and how each was handled (fixed, baselined, or left)
- How to run the checks, fix automatically, and install the hooks
- What was proven in Phase 5 and anything that could not be verified
- Anything deliberately left out and why

## Constraints

- Only deterministic tools: the same input gives the same result, with no model or network service in the loop. Dependency audits that query an advisory database are allowed but belong in CI or pre-push, never pre-commit
- Never edit product code beyond what an approved auto-fix changes
- Never bypass hooks with `--no-verify` or disable them to get something committed, including during your own proof step
- Never touch global or user-level git configuration
- One setup per repository run. In a monorepo, ask which packages to cover and share one entry point and one hook manager at the root
- Commit the setup so it is versioned, but do not push or open a pull request unless the developer asked
- Everything required to run the checks must be in version control: configuration, hook definitions, and the dependency manifest and lockfile. Nothing may depend on state that exists only on this machine
