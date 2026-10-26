# Front-end review guidance

Load this file in the correctness and performance lenses when the diff contains front-end code (React components or hooks). It adds to the lens rules and the shared rules. Follow the framework and version the project actually uses: check its `package.json`, its lint configuration, and whether it uses server components or the React Compiler before applying a rule.

## Correctness

Flag, with the scenario in which the user sees the wrong result:

Hooks
- A hook called conditionally, in a loop, after an early return, in a nested function, or in a class
- A dependency array that omits a value the effect, memo, or callback reads, which leaves a stale closure; or that includes a new object, array, or function on every render, which re-runs the effect each time
- A suppressed `react-hooks/exhaustive-deps` warning with no reason that holds up
- An effect without cleanup for what it starts: subscriptions, timers, event listeners, in-flight requests
- A fetch in an effect that can resolve out of order, with no abort or ignore flag, so a slow earlier response overwrites a newer one
- An effect that is not safe to run twice, which breaks under Strict Mode's double invocation

State and rendering
- State derived from props or other state, copied into its own state and kept in sync by an effect, when it can be computed during render
- State or props mutated in place, or an update computed from a stale value where a functional update is needed
- State initialized from a prop that never updates when the prop changes
- Reading or writing `ref.current` during render
- Index keys on lists that reorder, insert, or remove items, or keys that change every render
- A `&&` condition that can render `0` or `NaN`
- A component that switches between controlled and uncontrolled inputs
- When the project uses server components: hooks or browser APIs in a server component, or a missing `'use client'` boundary

Do not flag:
- Missing dependencies the project's lint rule accepts because the value is stable (a setter, a ref, a module constant)
- Effects the project uses on purpose to synchronize with an external system
- Patterns the project's React version or compiler already handles

## Performance

Flag only where the change makes the cost reachable by users, with the scenario (list size, update frequency, bundle weight):

- A re-render storm: a new object, array, or function passed to a memoized child or into a context value on every render, or state held higher than the components that use it so unrelated components re-render on every keystroke
- Expensive work in render (sorting, filtering, parsing large data) that repeats on every render, or a long list rendered in full with no pagination or virtualization
- Request waterfalls (a fetch that waits on another that it does not depend on), duplicate requests, and input-driven requests with no debounce
- A whole library imported for one function, a heavy dependency pulled into the main bundle, or a large route or component that could load lazily
- Images with no dimensions (layout shift) or served far larger than displayed
- Polling or intervals that never stop, and listeners or timers that accumulate

Do not flag:
- `useMemo`, `useCallback`, or `React.memo` additions or omissions without a measured or clearly large cost. When the project uses the React Compiler, manual memoization advice does not apply
- Micro-optimizations in components that render rarely or with small data
- Bundle size concerns for a dependency the project already ships
