# Decision 010 — Git-Backed Shared Memory

## Status

Adopted

## Context

Claude Code memory was per-machine and per-directory, requiring manual scp to sync across
machines. Proposed-idea 004 identified this as a problem with two failure modes: silent loss
when launching from an unexpected directory, and stale state on secondary machines.

The stated blocker in 004 was that the homelab repo was public on GitHub. This was a stale
assumption — decision 005 chose a private GitHub repo from the start. With that resolved,
the proposed direction in 004 was unblocked.

A second driver: as Prismo grows toward a multi-person team, each collaborator's Claude needs
to bootstrap from the same system knowledge without diverging over time.

## Decision

Split memory into two layers:

**Shared memory** — lives in `~/canon/homelab/docs/memory/`. Four files covering system
overview, workflow, MCP connection, and workflow shorthands. Committed to the private homelab
git repo. Syncs automatically on `git pull`.

**Personal memory** — stays in `~/.claude/projects/<key>/memory/`. User-specific behavioral
feedback, preferences, and session context. Not shared, not committed to any repo.

Shared files are symlinked into each machine's personal memory directory by `prismo new-machine`.
Claude Code loads all `.md` files in the memory directory — shared and personal files are loaded
identically in the same injection pass.

## Rationale

- Symlinks into a directory Claude Code already reads — no new mechanism or tooling needed
- Shared content updates automatically on `git pull` — zero manual sync for collaborators
- Personal content stays private and is never committed
- `prismo new-machine` handles the wiring — no manual steps for a new team member

## Alternatives Considered

- **Separate private repo for memory** — extra complexity with no benefit; homelab is already private
- **Local-only symlink consolidation** — solved multi-directory scoping but not multi-machine or multi-person sync
- **Committing all memory to git** — collapses the personal/shared distinction; behavioral feedback shouldn't be shared

## Consequences

- `~/canon/homelab/docs/memory/` is **not indexed** by context-server — the content is already
  accessible via other indexed docs; duplicating it would add noise to MCP retrieval
- `prismo new-machine` creates symlinks for shared files, then optionally syncs personal files via scp
- `prismo new-project` requires no changes — memory is machine-level, not project-level
- STRUCTURE.md updated to document the `memory/` folder
- Proposed-idea 004 superseded by this decision
