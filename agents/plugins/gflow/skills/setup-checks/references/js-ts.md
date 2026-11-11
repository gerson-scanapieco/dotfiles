# JavaScript and TypeScript

Defaults to propose for JavaScript and TypeScript projects. What the repository already uses wins over anything here. The worked example at the end is a real Next.js project at `standard` strictness.

## Tools by category

| Category | Default | Notes |
|---|---|---|
| Format | Prettier | Biome only if the project already uses it for both format and lint |
| Lint | ESLint (flat config) with `typescript-eslint` | Keep `eslint-config-prettier` last so style rules never conflict with the formatter |
| Types | `tsc --noEmit` | Whole-project; cannot run per-file, so pre-push and CI |
| Unused code and dependencies | knip | Whole-project; pre-push and CI |
| Secrets | secretlint (project-local), or gitleaks when the project already has it | Per-file; pre-commit on staged files |
| Dependency audit | `<pm> audit --prod` | Queries an advisory database: CI or pre-push only |
| Tests | vitest or jest, whichever is present | Slowest tier |

## Strictness presets

- **relaxed**: `eslint:recommended` plus `typescript-eslint` `recommended`; `strict: true` in `tsconfig`
- **standard**: `typescript-eslint` `strictTypeChecked` and `stylistic` (type-aware, needs `parserOptions.projectService`), `strict: true`, `noUncheckedIndexedAccess: true`
- **strict**: standard plus `noImplicitOverride`, `exactOptionalPropertyTypes`, `noPropertyAccessFromIndexSignature`, and import-hygiene rules such as `import/no-cycle`

Warnings as errors: `eslint --max-warnings 0` in every invocation (the package script and the pre-commit hook), `prettier --check`; `tsc` already fails on any error. For knip, rules set to `warn` do not fail the run: ask whether they should be `error`.

## Commands

- Staged files, pre-commit: `lint-staged` running `eslint --max-warnings 0`, `prettier --check`, `secretlint`. Use `--check` in hooks and keep writes in the explicit fix command, unless the developer opted into re-staged auto-fixes
- Pre-push: type check, knip, unit tests
- CI: the single `check` script, then the audit
- Count violations before enabling: `eslint . -f json`, `tsc --noEmit | wc -l`, `knip --no-exit-code`

## Hooks and installation

- husky with a `prepare` script (`"prepare": "husky"`) installs hooks on every `install`; `lint-staged` for the staged-file tier
- Package manager comes from `packageManager` or the lockfile; use `pnpm exec` / `npx` the same way the project's scripts do
- `.eslintcache`, `*.tsbuildinfo`, and the framework's build directory go in `.gitignore`

## Pitfalls

- Type-aware lint rules make ESLint slower; if pre-commit exceeds the budget, lint only staged files (lint-staged already does) before dropping rules
- Generated files (database types, route types, lockfiles) belong in ESLint `globalIgnores` and `.prettierignore`; formatting generated output in the fix script keeps it stable
- Config files (`*.mjs`, `*.config.js`) are outside the TypeScript project: disable type-aware rules for them rather than adding them to `tsconfig`
- Test files often need a few `no-unsafe-*` and `no-non-null-assertion` rules relaxed; scope that to the test directory
- Packages with install scripts may be blocked by the package manager; check its allow-list before assuming a tool's binary installed
- Monorepos: one root entry point and one hook manager, with per-package `tsconfig` handled through project references or one `tsc -b`

## Next.js

- **Typegen before checks**: type and lint steps that include route types need `next typegen` first (`"typecheck": "next typegen && tsc --noEmit"`, same for lint), otherwise a fresh clone or CI fails on missing `.next/types`
- **ESLint config**: `next lint` is no longer the way to run lint; call `eslint` directly with `eslint-config-next/core-web-vitals` and `eslint-config-next/typescript` as flat-config entries. Add `typescript-eslint` presets on top, since the Next presets are not strict
- **Ignores**: `.next/**`, `out/**`, `build/**`, and `next-env.d.ts`; the last two are generated and gitignored
- **`tsconfig`**: the `next` plugin and `.next/types/**/*.ts` includes are managed by Next; leave them, and do not remove `incremental`
- **Build in CI**: `next build` is part of the guarantee but is not a pre-push check; cache `.next/cache` keyed on the lockfile and source hashes
- **Environment**: the build needs `NEXT_PUBLIC_*` and server variables; use placeholders in CI rather than real secrets, and keep `.env*` gitignored with only `.env.example` committed
- **knip**: Next's entry points (`app/`, `pages/`, `middleware`, `next.config.*`) are detected by its Next plugin; add ignores only for confirmed false positives

## Example: Next.js with Supabase, pnpm

Real configuration at `standard`, as the target shape for a project that has little or nothing in place.

```json
{
  "lint": "next typegen && eslint",
  "format": "prettier --write .",
  "format:check": "prettier --check .",
  "typecheck": "next typegen && tsc --noEmit",
  "knip": "knip",
  "secrets": "secretlint \"**/*\"",
  "check": "pnpm lint && pnpm format:check && pnpm typecheck && pnpm knip && pnpm secrets",
  "check:fix": "eslint --fix && prettier --write .",
  "check:all": "pnpm check && pnpm audit --prod && pnpm test && pnpm build",
  "prepare": "husky"
}
```

- `.husky/pre-commit`: `pnpm exec lint-staged`
- `.husky/pre-push`: `pnpm typecheck`, `pnpm knip`, `pnpm test`
- `.lintstagedrc.json`: `eslint --max-warnings=0` and `prettier --check` on code files, `prettier --check` on json/md/css/yml, `secretlint` on everything
- `eslint.config.mjs`: `eslint-config-next` core-web-vitals and typescript, `strictTypeChecked`, `stylistic`, `projectService: true`, `eslint-config-prettier` last, a few project rules (`consistent-type-imports`, `no-console` except warn/error, `import/no-cycle`), `disableTypeChecked` for `*.mjs`, relaxed `no-unsafe-*` under `tests/`
- `tsconfig.json`: `strict` and `noUncheckedIndexedAccess`
- `knip.json`: `exports` and `types` rules at `warn`, with `ignoreDependencies` for the secretlint preset, which knip cannot see being used
- CI: one job runs `check` and `audit --prod`, one runs the tests against the database, one runs `build` with placeholder environment and a `.next/cache` cache; install with `--frozen-lockfile`
- Tiers: pre-commit is staged-file lint, format check, and secrets; pre-push is types, knip, and tests; CI adds audit and build
