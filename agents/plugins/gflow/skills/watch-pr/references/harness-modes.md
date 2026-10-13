# Watcher modes by harness

The script is `<this skill's directory>/scripts/watch-pr`. Use the first mode your harness supports.

- **Streaming monitor** (Claude Code's `Monitor` tool, or opencode v2 with the `opencode-monitor` plugin): run `<this skill's directory>/scripts/watch-pr <PR URL> <state file> 300` with the maximum timeout. Each printed line wakes the agent. A monitor expires after at most 30 minutes; when it expires without the PR being merged or closed, that loop is over, so start the next loop with the same command and state file.
- **Background job that announces completion** (opencode v2 shell tool with `background`): run `<this skill's directory>/scripts/watch-pr <PR URL> <state file> 300 --once 1800`. The job exits at the first feedback, error, merge, close, or after 30 minutes, and its completion wakes the agent. Each exit is one loop.
- **Background subagent** (Codex with `features.multi_agent` enabled, or any harness with background agents): spawn a subagent whose only task is to run the `--once 1800` command in the foreground and return the printed lines unchanged. Its completion wakes the parent. Each return is one loop.
