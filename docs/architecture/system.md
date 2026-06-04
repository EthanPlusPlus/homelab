# Prismo — System Overview

Prismo is the name for the whole system: the Proxmox host, the Ubuntu Server VM,
the services running on it, the projects being developed, and the docs and workflow
that govern all of it.

## Services

| Component | Description |
|-----------|-------------|
| context-server | AI context layer — doc indexer, code indexer, MCP server, synthesis + doctrine services |
| prismo-ui | Ops dashboard — ReviewQueue, metrics, doctrine health, topology (port 3000) |
| PostgreSQL + pgvector | Primary data store — vector embeddings, workflow state, doctrine |
| Portainer | Docker management UI |
| Tailscale | Mesh VPN (current access layer — see Decision 032 for portability direction) |

For hardware and network details see `docs/infra/`.

## Directory Structure

Two sibling directories separate code from knowledge:

```
~/projects/          ← code repos only (sparse — no docs/)
  context-server/
  devcamp/
  flight-planner/
  even/
  prismo-ui/

~/canon/             ← knowledge only (docs worktrees + knowledge bases)
  prismo/            ← primary system canon (this repo)
  context-server/    ← linked git worktree from context-server repo (docs/ only)
  exam-prep/         ← study materials (no git repo)
  flight-planner/    ← linked git worktree from flight-planner repo (docs/ only)
  even/              ← linked git worktree from even repo (docs/ only)
  prismo-ui/         ← linked git worktree from prismo-ui repo (docs/ only)
```

## Repos

| Repo | Primary location | Purpose |
|------|-----------------|---------|
| prismo | `~/canon/prismo/` | System canon — decisions, runbooks, architecture, context |
| context-server | `~/projects/context-server/` (code) + `~/canon/context-server/` (docs) | AI context retrieval + synthesis + doctrine service |
| devcamp | `~/projects/devcamp/` | Active development project |
| flight-planner | `~/projects/flight-planner/` (code) + `~/canon/flight-planner/` (docs) | Personal flight optimiser |
| even | `~/projects/even/` (code) + `~/canon/even/` (docs) | iOS receipt-splitting app |
| prismo-ui | `~/projects/prismo-ui/` (code) + `~/canon/prismo-ui/` (docs) | Ops dashboard — http://ubuntu-server.tail58b10c.ts.net:3000 |

## Working Model

- Code work happens in `~/projects/<name>/` — no docs present (sparse-checkout)
- Doc editing happens in `~/canon/<name>/` — deliberate context switch
- context-server indexes from `~/canon/` via `CANON_PATH=/canon`
- The prismo repo lives entirely in `~/canon/` — it is knowledge, not code

## Adding a New Project

When a new repo joins the system, add it to the repos table above and the directory tree.
See `runbooks/new-project.md` for the full setup procedure.
