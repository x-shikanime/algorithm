# Algorithm

A sketchbook of algorithms and data structure implementations for study and
reference.

**Language:** C++

## Structure

- `src/` — Implementation files
- `tests/` — Validation tests for each algorithm
- `docs/` — Complexity analysis and explanations

## Build

- Use cmake for building
- Run tests with `ctest` or directly via the test executables

## Commit Style

- Plain-text capitalized title, no conventional-commit prefix
- Body with labels: `Design:`, `Related:`, `Closes #`
- Keep Markdown lines wrapped at 80 columns and run `nix fmt` before shipping

## Stack

- 1 commit == 1 PR via ghstack (1 commit is 1 logical atomic change)
- Split work into stacked PRs to keep each PR small and reviewable
- To pull down an existing stack: `ghstack checkout <PR_NUMBER>`
- To update a PR: edit files, then `jj squash` (or `git commit --amend`) into the
  **target commit** of the stack — the one that PR represents
- Resubmit with `ghstack` after squashing
- `ghstack land` on the head PR to land the entire stack
- Never `gh pr merge` (creates poisoned commits)
- Never force-push ghstack branches


## Editing Pull Requests

- The commit title and description **are** the pull request title and body.
- To edit the PR body after creation, use `gh pr edit <PR_NUMBER>`:
  - `gh pr edit <PR_NUMBER> --title "New title"` — update the title
  - `gh pr edit <PR_NUMBER> --body "New body"` — update the body
  - `gh pr edit <PR_NUMBER> --body-file /path/to/file.md` — set body from file
- Amending the commit (`jj squash` / `git commit --amend`) and resubmitting
  with `ghstack` will also update the PR automatically.
## Protect `main`

- Require 1 approving review
- Require linear history (no merge commits)
- Require signed commits
- Squash+rebase merge only

_Focus on time/space complexity and correctness. Always use worktrees when
making changes._
