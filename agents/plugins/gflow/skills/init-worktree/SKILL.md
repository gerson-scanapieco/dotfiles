---
name: init-worktree
description: Convert the current git repository into a bare-repo worktree layout (`.bare/` plus one directory per branch) so several branches can be worked on in parallel. Use when starting parallel work on a repo, or when the developer wants to work on multiple branches or agents at once without stashing or re-cloning.
argument-hint: "[optional: name for the first worktree directory]"
allowed-tools: Bash(git:*), Bash(direnv:*), Bash(command:*), Bash(ls:*), Bash(mv:*), Bash(mkdir:*), Bash(cp:*), Bash(rm:*), Bash(printf:*), Bash(pwd:*), Bash(chmod:*), Read(*), Grep(*), Glob(*), Write(*), Edit(*)
---

## Context

You convert the repository in the current directory to the bare-repo worktree layout:

```
repo/
├── .bare/        # the git database (bare repository)
├── .git          # file containing "gitdir: ./.bare"
├── .envrc        # shared environment, loaded by direnv in every worktree
├── main/         # worktree for main
└── feature-x/    # worktree for another branch, added later
```

The `.git` pointer file lets every git command work from the container directory and from inside each worktree, while each branch lives in its own folder. Nothing needs stashing or re-cloning to switch tasks.

direnv looks for `.envrc` in the current directory and then in each parent, so the container's `.envrc` applies to every worktree automatically. It sits outside all worktrees, so it is never committed and holds the variables (secrets, local config) that every branch shares.

Projects can also define lifecycle hooks, executable files in a tracked `.wt/` directory, that the `wt new` and `wt rm` fish functions run for each worktree (see Phase 4). They are how a project makes parallel worktrees safe to run side by side: a per-worktree `.env.local` with its own port and database name, dependency installs, cleanup on removal.

$ARGUMENTS is an optional name for the first worktree directory. The default is the current branch name with `/` replaced by `-`.

The conversion rewrites the working directory. Nothing is moved or deleted before the developer approves the plan in Phase 2.

## Phase 1: Inspect

Run from the repository root. Stop and report if any check fails.

1. **Is a normal repo.** `git rev-parse --show-toplevel` must equal the current directory. If `git rev-parse --is-bare-repository` is `true`, or `.bare/` already exists, the repo is already converted: say so, show `git worktree list`, and stop.
2. **No existing linked worktrees.** `git worktree list` must show only this directory. Otherwise stop and ask the developer to remove or re-create them after conversion.
3. **Clean tree.** `git status --porcelain` must be empty. If not, ask the developer to commit or stash first; do not do it for them.
4. **Not detached.** `git branch --show-current` must return a branch. Otherwise ask which branch the first worktree should check out.
5. **Facts to carry over:**
   - remote: `git remote -v` (the conversion needs `origin`; if there is none, the fetch-refspec step is skipped)
   - submodules: if `.gitmodules` exists, warn that submodules are fragile with this layout and ask whether to continue
   - ignored files that matter: `git status --ignored --porcelain`. Anything ignored (`.env*`, `node_modules`, build output, local config) would be lost with the old working tree, so list them for the developer.
   - direnv: `command -v direnv`. If missing, tell the developer the shared `.envrc` will be created but inert until direnv is installed and hooked into their shell.
   - env files: whether `.envrc` exists and whether it is tracked (`git ls-files --error-unmatch .envrc`), and any ignored `.env*` files. Read them to decide what is shared; never print secret values back, only the variable names.

## Phase 2: Plan and approval

Present the plan in a few lines: the container path, the branch and directory name of the first worktree, the ignored files found and which of them you propose to copy into it (secrets and local config yes; `node_modules` and build output no, they are cheaper to reinstall than to move across paths), how the shared environment will be set up (see Phase 3 step 6), and a note that the old working tree contents are replaced by the worktree checkout. Mention that Phase 4 afterwards offers to set up `.wt/` hooks so worktrees can run in parallel; it is optional and nothing in it is committed. Wait for approval.

## Phase 3: Convert

Use `<branch>` for the current branch and `<dir>` for the worktree directory name. Work in the repository root.

1. **Park the old working tree** outside the repo so nothing is lost if a step fails:
   ```bash
   park=$(mktemp -d)
   mv .git "$park/git"
   find . -mindepth 1 -maxdepth 1 -exec mv {} "$park/" \;
   mv "$park/git" .bare
   ```
2. **Make the git directory bare and point to it:**
   ```bash
   printf 'gitdir: ./.bare\n' > .git
   git config core.bare true
   ```
3. **Restore remote-tracking branches.** A bare clone does not map remote branches by default, which breaks `git fetch` and upstream tracking:
   ```bash
   git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
   git fetch origin
   ```
4. **Create the first worktree** on the original branch:
   ```bash
   git worktree add <dir> <branch>
   git -C <dir> branch --set-upstream-to=origin/<branch> <branch>
   ```
   Skip the upstream line if `origin/<branch>` does not exist.
5. **Copy approved ignored files** from `$park/` into `<dir>/`, preserving relative paths. Leave out the env files handled in the next step.
6. **Set up the shared environment** in the container directory:
   - Ignored env files (`.env`, `.env.local`, and similar) move from `$park/` to the container, and the container `.envrc` loads them with `dotenv .env`, `dotenv .env.local`, and so on. They are then shared by every worktree instead of copied into each.
   - If the repo has no tracked `.envrc`, write the container `.envrc` with those `dotenv` lines, plus any exports the developer chose to share. If there is nothing to share, write a minimal file with a `dotenv_if_exists .env` line so adding `.env` later just works.
   - If the repo has a tracked `.envrc`, it stays in the worktree (it is part of the project). The container `.envrc` holds only the shared, untracked variables. Because direnv uses the nearest `.envrc`, the tracked one would shadow the container's, so tell the developer to add `source_up` as its first line; propose that change, do not commit it.
   - If an ignored, untracked `.envrc` existed, move it to the container instead of the worktree.
   - Run `direnv allow` on the container `.envrc` only if the developer approved it in Phase 2.
7. **Verify**: `git worktree list` shows the bare root and `<dir>`; `git -C <dir> status` is clean; `git -C <dir> log -1` matches the commit from Phase 1. With direnv installed and the file allowed, `cd <dir> && direnv exec . env` includes the shared variable names.
8. **Clean up** `$park` only after the verification passes, and only after the developer confirms nothing is missing from the new worktree. If any step fails, restore by moving `$park/*` back and `.bare` back to `.git`, and report what happened.

## Phase 4: Customize for parallel worktrees

Offer this after the conversion is verified; skip it if the developer declines. Several worktrees running at once will collide on anything global to the machine, so find what the project shares and give each worktree its own.

### Hook contract

`wt new <branch>` and `wt rm <name>` run these executables from the worktree's tracked `.wt/` directory when they exist. Any language works; a failing `pre-rm` aborts the removal, a failing `post-new` or `post-rm` only prints a warning, and `--no-hooks` skips all of them.

| Hook | Runs | Working directory |
|---|---|---|
| `.wt/post-new` | after the worktree is created | the new worktree |
| `.wt/pre-rm` | before removal | the worktree being removed |
| `.wt/post-rm` | after removal (copied to a temp file first, since the worktree is gone) | the container |

Each gets `WT_HOOK`, `WT_ROOT` (the container), `WT_BRANCH` and `WT_DIR` in its environment. Hooks run only through `wt`, not through plain `git worktree add`, and the worktree created in Phase 3 never ran `post-new`; offer to run it by hand with those variables set.

### Find what collides

Search the project (compose files, `Procfile`, scripts, `package.json`, framework config, `.env*`) and list, with file references:

- fixed ports: dev server, test server, debugger, anything bound in docker compose
- database, cache, queue, and search-index names or URLs (a shared dev database across branches with different migrations breaks)
- container names, compose project names, tunnels, and other resources that must be unique per checkout
- dependency installs and generated files each worktree needs on creation
- resources that need explicit teardown when a worktree goes away

### Propose, then write

Present a short proposal: for each finding, which variable or step changes and how it is derived from `WT_BRANCH` (for example a stable port in a fixed range from a hash of the branch, a database name suffixed with the sanitized branch). Ask about anything you cannot infer, such as port ranges or whether to drop databases on removal. After approval, write only the hooks that have something to do:

- `post-new`: write `.env.local` with the per-worktree overrides, copy any needed secrets from `$WT_ROOT`, install dependencies, create the database if the project needs one.
- `pre-rm`: stop that worktree's services and drop its per-branch resources, reading names back from its `.env.local`. Teardown belongs here, where the worktree still exists.
- `post-rm`: only for cleanup that must happen after the directory is gone.

Make them idempotent and quiet on success, and `chmod +x` each one. Make sure the app actually reads `.env.local`; if it does not, say how to load it, for example a worktree-level `.envrc` written by `post-new` that begins with `source_up` and then `dotenv_if_exists .env.local`. Add `.env.local` to `.gitignore` if it is not ignored (propose the edit).

Do not commit the hooks; the developer decides. Remind them that they only appear in other branches' worktrees once merged or rebased in, and that the `wt` function must be installed in their shell for any of this to run. Offer a dry run in a scratch worktree (`wt new tmp/hook-test`, then `wt rm tmp-hook-test`) and report what each hook did.

## Phase 5: Hand off

Tell the developer, briefly:

- Work now happens in `<dir>/`, not the container. Tools, editors, and terminals that were open in the old path must be reopened there.
- Add a worktree for a new branch: `git worktree add <name> -b <branch> origin/<default-branch>`; for an existing remote branch: `git worktree add <name> <branch>`.
- List and remove: `git worktree list`, `git worktree remove <name>`, `git worktree prune`.
- A branch can be checked out in only one worktree at a time.
- Shared environment lives in the container's `.envrc` (and the `.env*` files it loads). Edit it there once and every worktree sees it after `direnv allow`; a worktree can still add its own `.envrc` that starts with `source_up`.
- Dependencies (`node_modules`, virtualenvs, build caches) are per worktree and need installing in each new one; a `post-new` hook can do it.
- If hooks were set up: create and remove worktrees with `wt new <branch>` and `wt rm <name>` so they run, and `--no-hooks` bypasses them.

## Rules

- Never run the conversion on a dirty tree, and never `rm -rf` the parked working tree without the developer's confirmation.
- Do not commit, push, or change remotes. Hooks and `.gitignore` edits are written but left uncommitted.
- Never print secret values from env files, and never run `direnv allow` without approval.
- If the repository is a worktree of another repository or sits inside a larger repository (`--show-toplevel` mismatch), stop instead of converting.
