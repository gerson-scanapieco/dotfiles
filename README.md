# dotfiles

Personal machine setup: shell, terminal, git, and AI agent configuration.

## Layout

| Path | What it holds |
|---|---|
| `setup/` | Setup scripts. `setup/setup` provisions the machine and `setup/init-agents` links the agent configuration |
| `config/` | Dotfiles for the shell, terminal, git, and other tools, symlinked into place by the setup |
| `agents/` | Configuration shared by Claude Code, Codex, and opencode |

### Agents

| Path | What it holds |
|---|---|
| `agents/AGENTS.md` | Global instructions, linked as `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and the opencode equivalent |
| `agents/claude/`, `agents/codex/` | Per-tool settings and rules |
| `agents/skills/` | Standalone skills, linked into `~/.claude/skills` and `~/.agents/skills` |
| `agents/plugins/` | Personal plugins. Each one is its own marketplace and is installed by the setup |

Plugins:

- [`gflow`](agents/plugins/gflow/README.md): a development flow that specifies work in Linear, plans it, implements it, reviews it, opens the pull request, and watches it for feedback.

## Install

Clone this repository:

```bash
cd ~/
git clone git@github.com:gerson-scanapieco/dotfiles.git
```

Run the setup script:

```bash
cd ~/dotfiles
chmod +x setup/setup
setup/setup
```

The setup links the agent configuration and installs the Claude Code plugins, including `gflow` from `agents/plugins/gflow`. It prints the manual steps that remain (authentication and API keys) at the end.

Codex and opencode do not install plugins from the setup. See the plugin's README for how to use it with each tool.

Done! :D

## Adding a plugin

1. Create `agents/plugins/<name>/` with a `.claude-plugin/plugin.json`, a `.claude-plugin/marketplace.json`, and a `skills/` directory.
2. Add `claude plugin marketplace add` and `claude plugin install` for it to the plugin section of `setup/setup`.
3. Enable it under `enabledPlugins` in `agents/claude/settings.json`. Do not commit the `extraKnownMarketplaces` path that Claude Code writes there, since it is specific to one machine.
