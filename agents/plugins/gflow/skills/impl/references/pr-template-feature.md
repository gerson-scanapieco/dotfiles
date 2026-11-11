# Feature/Change pull request template

Use this body for pull requests that are not bug fixes.

```markdown
## Summary
[2-3 sentences on what changed and why]

## Implementation Details
[Technical approach and key decisions made in this PR]

## Database Changes
[Schema changes, if any — omit this section entirely if there are none]

## How to Test
[Manual QA steps a reviewer can follow to try the change themselves: any setup or test data needed, the actions to take, and the expected result of each. Write them as instructions, not as a log of what was run. Do not list automated tests or the checks you ran]

<details>
<summary><h2>Verification Steps</h2></summary>

[The steps you actually ran in Phase 2 to assess that your work is correct, with the observed result of each. Never list what you expect would work. Note anything you could not verify]

</details>

## Deployment Checklist
[Steps to perform before/while this PR lands in prod: feature flags, config changes, secrets, other infra concerns — omit this section entirely if there are none]
```
