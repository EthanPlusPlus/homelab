# Decision 008 — Docs worktree branch merges into master

## Status
Adopted

## Context
When a linked git worktree is created with `git worktree add`, git requires
it to be on a separate branch — two worktrees cannot share the same branch.
For context-server, this means:

- `~/projects/context-server/` — branch `master` (code)
- `~/canon/context-server/` — branch `context-server` (docs)

Doc commits land on the `context-server` branch, not `master`. Left unaddressed,
docs and code history diverge onto separate branches.

## Decision
After editing docs in `~/canon/<name>/`, merge the docs branch back into master.
Docs and code share one unified git history on master.

## Workflow

```bash
# After committing doc changes in ~/canon/context-server/:
cd ~/projects/context-server
git merge context-server
git push
```

## Why not keep them on separate branches permanently?
A single master branch keeps doc and code history aligned — you can see what
changed in the codebase and in the docs at the same point in time. Separate
branches make `git log` on master code-only, losing that alignment.

## Consequences
- Every doc editing session in a canon worktree ends with a merge to master
- The docs branch (`context-server`) is a working branch, not a permanent one
- This applies to any future code repo that gets a docs worktree in ~/canon/
