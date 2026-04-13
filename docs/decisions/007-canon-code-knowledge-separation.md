# Decision 007 — ~/canon/ — Separate code and knowledge

## Status
Adopted

## Context
Docs were committed inside code repos (e.g. `~/projects/context-server/docs/`).
When working in a repo, Claude could — and did — read docs directly from the filesystem,
bypassing the MCP context-server. This violated the founding principle:

> Claude should not be used as a search engine, only as a reasoning engine.

## Decision
Introduce `~/canon/` as a dedicated knowledge directory, separate from `~/projects/`.

- `~/projects/` — code repos only, sparse-checkout configured to exclude `docs/`
- `~/canon/` — knowledge only: docs worktrees, knowledge bases, study materials

Each code repo that has docs gets a linked git worktree in `~/canon/<name>/` scoped
to `docs/` only. The main working tree in `~/projects/<name>/` has no `docs/` present.

## Implementation

- `~/canon/homelab/` — primary clone of homelab repo (docs-only, no change needed)
- `~/canon/context-server/` — linked worktree from context-server repo (`docs/` only)
- `~/canon/exam-prep/` — moved from `~/projects/exam-prep/` (no git repo)
- context-server doc indexer now uses `CANON_PATH=/canon` instead of `PROJECTS_PATH`
- `PROJECTS_PATH` retained for the code indexer (unchanged)
- Per-worktree git hooks: `~/canon/context-server/` fires `POST /index` on pull;
  `~/projects/context-server/` continues to fire `POST /index/code?project=context-server`

## Consequences
- Claude working in `~/projects/<name>/` has no docs to scan — MCP is the only path
- Doc editing is a deliberate context switch to `~/canon/<name>/`
- `doc_type` names unchanged (`homelab`, `context-server`) — no MCP query changes needed
- New projects: create `~/canon/<name>/docs/`, run `POST /index` — auto-discovered
- New machine setup requires: clone to projects/ (sparse), worktree add to canon/, hook install
