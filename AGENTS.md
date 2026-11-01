## gflow plugin

Any change under `agents/plugins/gflow/` other than its README must bump `version` in both `agents/plugins/gflow/plugin.json` and `agents/plugins/gflow/.claude-plugin/plugin.json`, to the same value: patch for fixes, minor for new or changed skills, major for breaking changes. The `.githooks/pre-commit` hook rejects commits that skip it.
