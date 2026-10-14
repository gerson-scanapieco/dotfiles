# Publishing the review (`--post`)

Load this file only when `--post` is given. The flag is the authorization to post; do not ask for confirmation. The HTML document is never produced, posted, or attached.

- Create a single pull request review through the GitHub API (`POST /repos/<owner>/<repo>/pulls/<number>/reviews`), pinned to the reviewed head SHA with `commit_id`, with:
  - `event`: `APPROVE`, `REQUEST_CHANGES`, or `COMMENT`, from the verdict. If GitHub rejects the event because the authenticated user authored the PR, post it as `COMMENT` and say why in the body
  - `comments`: one inline comment per confirmed finding (and per `needs decision` item that maps to a line) that lands on a line in the PR's diff, each stating the problem, the scenario, and the suggested fix, in the author's terms and without internal verification chatter. Prefix quality findings with `Quality:` and leave defects unprefixed, so the author can tell a style point from a bug at a glance
  - `body`: the conclusion: the verdict, its explanation, what changed since the previous review when there is one, and anything that could not be placed inline. When there are quality findings, summarize them in their own short section after the defects. A few paragraphs at most
- Findings that cannot be anchored to a diff line go in the body.
- Do not resolve existing threads. Mention in the body which earlier items the new commits addressed.
- Print the review URL and the verdict to the terminal.
