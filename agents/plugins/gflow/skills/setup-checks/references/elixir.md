# Elixir

Defaults to propose for Elixir and Phoenix projects. What the repository already uses wins over anything here. Not derived from a specific project, so verify each command against the project's Elixir version and dependencies before proposing it.

## Tools by category

| Category | Default | Notes |
|---|---|---|
| Format | `mix format` | `--check-formatted` in hooks and CI; add `Phoenix.LiveView.HTMLFormatter` as a plugin for HEEx |
| Lint | Credo | `--strict` for `standard` |
| Types | Compiler warnings, plus Dialyzer via `dialyxir` | Dialyzer is slow: pre-push or CI, with the PLT cached |
| Unused code and dependencies | `mix compile --warnings-as-errors` for unused functions, variables, aliases; `mix deps.unlock --check-unused` | Unused dependencies are only caught by the second command |
| Security | `mix_audit` (`mix deps.audit`), `mix hex.audit`, Sobelow for Phoenix | Advisory lookups: CI or pre-push only |
| Secrets | gitleaks, or secretlint when Node is already present | Per-file; pre-commit |
| Tests | `mix test` | Slowest tier; often needs the database |

## Strictness presets

- **relaxed**: `mix format --check-formatted`, `mix compile`, `mix credo`
- **standard**: `mix compile --warnings-as-errors`, `mix credo --strict`, `mix format --check-formatted`
- **strict**: standard plus Dialyzer, `mix deps.unlock --check-unused`, and Credo's opt-in checks enabled in `.credo.exs`

## Commands

- Staged files, pre-commit: `mix format --check-formatted <files>`, secret scan. Credo can take file paths but gives its best results on the whole project; run it at pre-push if per-file output is noisy
- Pre-push: `MIX_ENV=test mix compile --warnings-as-errors --force`, `mix credo --strict`, `mix deps.unlock --check-unused`, the fast test suite. Force-recompile, since warnings are only emitted on compile
- CI: the single entry point, then Dialyzer and the audits
- Count violations before enabling: `mix credo --strict --format json`, `mix compile --force 2>&1 | grep -c warning`

## Single entry point

A mix alias is the idiomatic entry point and doubles as the hook install step:

- `mix check`: format check, compile with warnings as errors, Credo, unused deps
- `mix check.fix`: `mix format` and any auto-fixable step
- `ex_check` is an option when the project wants parallel runs and one report; do not add it only for the alias

## Hooks and installation

- No hook manager is native to the ecosystem: use `lefthook` (committed `lefthook.yml`), installed from a mix alias such as `setup` that fresh clones already run
- Document the one-time `mix setup` (or the existing equivalent) in `AGENTS.md`

## Pitfalls

- `--warnings-as-errors` on a cached build passes without compiling; force the compile in the check
- Dependency warnings are not the project's: `mix compile --warnings-as-errors` applies to project code only
- Dialyzer's first run builds the PLT and can take many minutes; cache `priv/plts` (or the configured path) in CI and gitignore it
- Run checks in `MIX_ENV=test` when the project's `test` environment compiles extra paths (`elixirc_paths`), or tests and support files go unchecked
- Umbrella projects: run from the root so the single entry point covers every app, and share one `.formatter.exs` import chain
- `_build`, `deps`, `.elixir_ls`, and the PLT directory go in `.gitignore`

## Phoenix

- Sobelow: `mix sobelow --config` with a committed `.sobelow-conf`; skip checks through the config file, not inline, so ignores are reviewable
- Format templates through the HEEx formatter plugin; leave generated migration timestamps and `priv/static` alone
- Gettext: `mix gettext.extract --check-up-to-date` keeps translations in sync when the project uses them
- Ecto: `mix ecto.migrate` and `mix ecto.rollback` are not checks, but a migration test or `mix ecto.dump` diff in CI catches schema drift when the project commits `structure.sql`
