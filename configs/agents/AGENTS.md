## General coding style guidelines

-- **MANDATORY**: Don't write redundant, obvious or self-explanatory code comments. If you need to use them as guidance during the implementation, remember to remove them before finishing your tasks.


## Browser Automation

Use `agent-browser` for web automation. Run `agent-browser --help` for all commands.

Core workflow:
1. `agent-browser open <url>` - Navigate to page
2. `agent-browser snapshot -i` - Get interactive elements with refs (@e1, @e2)
3. `agent-browser click @e1` / `fill @e2 "text"` - Interact using refs
4. Re-snapshot after page changes
