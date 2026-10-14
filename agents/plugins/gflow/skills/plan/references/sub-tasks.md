# When to use sub-tasks

Default to a single issue. Create a sub-task only when the piece of work is independently valuable AND at least one of these holds:
- It ships as its own PR/release (e.g. a migration that must deploy first)
- It will be owned by a different person or team
- It can be worked in parallel with the rest
- It needs its own acceptance criteria and review, not just a "done" tick

Never create a sub-task just because something is a step in the implementation. Layers (data, business logic, UI) are implementation steps in the plan, not sub-tasks. If in doubt, keep a single issue.
