# gflow

My development flow as a plugin: scope work in Linear, plan it, implement it, review it locally, open a pull request, and watch it for review feedback.

## Skills

| Skill | What it does |
|---|---|
| `gflow` | Drives the whole flow end to end, invoking the skills below |
| `spec` | Clarifies a vague problem or rough Linear issue into one issue with acceptance criteria (the *what*) |
| `plan` | Scopes the work (splitting it into issues or a project when needed) and defines the architecture, technical approach and ordered steps (the *how*), posted as a comment |
| `impl` | Implements the issue's plan test-first, commits, opens a PR and updates Linear. Requires a plan |
| `watch-pr` | Polls a PR every 5 minutes, assesses new feedback and addresses it after approval (max 3 loops) |
| `address-pr-threads` | Assesses unresolved review threads and review-body remarks on the current branch's PR, then addresses them after approval |
| `explain` | Explains code, a file or a concept in plain language for a non-technical reader |
| `create-verification-skill` | Generates a project-local `verify-<app>` skill that launches and drives the app and captures proof |
| `maintain-verification-skill` | Periodic audit of a verification skill and its feature map against the source and a live run |
| `setup-checks` | Audits a project's formatters, linters and type checkers, adds the missing ones with you, and wires them into git hooks |
| `review` | Parallel specialist reviewers with every finding independently verified, concluding `approve`, `comment` or `request changes`. Produces a personal HTML document, or with `--post` publishes inline comments and a review to the PR |

## Install

Requirements: `git`, an authenticated `gh` CLI, and a Linear MCP server (`linear-server`) configured in your agent.

### Claude Code

Add the plugin directory as a local marketplace and install from it:

```bash
claude plugin marketplace add ~/dotfiles/agents/plugins/gflow
claude plugin install gflow@gflow
```

Skills are namespaced by the plugin, e.g. `/gflow:spec`, `/gflow:watch-pr`.

### Codex

Codex reads the `.claude-plugin/` manifests, so the same directory works as a local marketplace:

```bash
codex plugin marketplace add ~/dotfiles/agents/plugins/gflow
```

Then run `/plugins` in the Codex CLI, pick the `gflow` marketplace and install the plugin. To enable it by config instead, add this to `~/.codex/config.toml`:

```toml
[plugins."gflow@gflow"]
enabled = true
```

Start a new session after installing. Invoke the skills by typing `@` and choosing the plugin or skill.

### opencode

opencode v2 has no plugin marketplace and its plugins (`plugins` in `opencode.json`) are code modules, so install the skills as a skill source. Add the plugin's `skills` directory to `~/.config/opencode/opencode.json`:

```jsonc
{
  "skills": ["~/dotfiles/agents/plugins/gflow/skills"]
}
```

Skills are not namespaced: each ID comes from its directory name, so mention them as `@spec`, `@plan`, `@impl`, `@watch-pr`, `@address-pr-threads`, `@explain`, `@create-verification-skill`, `@maintain-verification-skill`, `@setup-checks`, `@review` and `@gflow`. Alternatively, symlink each skill directory into `~/.agents/skills`, which opencode also scans.

## Get started

1. Make sure `gh auth status` is green and your Linear MCP server is connected.
2. From the repository you want to work in, start the flow with a problem description or an existing Linear issue ID.
3. Answer the questions `spec` and `plan` ask; each skill stops at its approval gates and never answers them for you.
4. Review the pull request `gflow` opens. `watch-pr` then monitors it and asks for your approval before changing anything.

`watch-pr` needs a way to be woken when something happens. Claude Code uses its `Monitor` tool; opencode v2 can use a background shell job (or the `opencode-monitor` plugin); Codex needs `features.multi_agent` so a background subagent can do the waiting. Without any of these, `watch-pr` checks once and stops.

Each skill also works on its own, so you can enter the flow at any stage.

## Examples

Run the whole flow from a description, opening the pull request as a draft:

```
/gflow:gflow "Users can't export their invoices as CSV" --draft
```

Resume the flow for an existing issue. It skips the phases already done (scoped, planned, implemented, PR open):

```
/gflow:gflow ENG-123
```

Run a single stage:

```
/gflow:spec "Add rate limiting to the public API"
/gflow:plan ENG-123
/gflow:impl ENG-123
```

Watch the current branch's pull request, or a specific one:

```
/gflow:watch-pr
/gflow:watch-pr https://github.com/org/repo/pull/42
```
