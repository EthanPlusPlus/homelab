# Prismo — System Overview

Prismo is the name for the whole system: the Proxmox host, the Ubuntu Server VM,
the services running on it, the projects being developed, and the docs and workflow
that govern all of it.

## Components

| Component | Description |
|-----------|-------------|
| Proxmox host | Bare metal on a 2017 iMac, IP 192.168.1.9 |
| Ubuntu Server VM | Ubuntu 24.04, IP 192.168.100.10, Tailscale 100.92.226.121 |
| context-server | AI context layer — doc indexer, code indexer, MCP server |
| Portainer | Docker management UI |
| Tailscale | Mesh VPN, hostname ubuntu-server.tail58b10c.ts.net |

## Directory Structure

Two sibling directories separate code from knowledge:

```
~/projects/          ← code repos only (sparse — no docs/)
  context-server/
  devcamp/

~/canon/             ← knowledge only (docs worktrees + knowledge bases)
  homelab/           ← primary clone of homelab repo (docs-only)
  context-server/    ← linked git worktree from context-server repo (docs/ only)
  exam-prep/         ← study materials (no git repo)
```

## Repos

| Repo | Primary location | Purpose |
|------|-----------------|---------|
| homelab | `~/canon/homelab/` | Prismo's own docs — decisions, runbooks, architecture, context |
| context-server | `~/projects/context-server/` (code) + `~/canon/context-server/` (docs) | The AI context retrieval service |
| devcamp | `~/projects/devcamp/` | Active development project |

## Working Model

- Code work happens in `~/projects/<name>/` — no docs present (sparse-checkout)
- Doc editing happens in `~/canon/<name>/` — deliberate context switch
- context-server indexes from `~/canon/` via `CANON_PATH=/canon`
- The homelab repo lives entirely in `~/canon/` — it is knowledge, not code

## Obsidian Sync Pipeline

Edits made in Obsidian on a Mac flow through two asynchronous hops before the index reflects them:

```
Obsidian edit
  → launchd (every 5 min) → git push to GitHub
    → server cron (every 2 min) → git pull + POST /index
```

**Timing:**
| Scenario | Lag |
|----------|-----|
| Worst case | ~7 min (5 min launchd + 2 min cron) |
| Average case | ~3.5 min (timers are independent, mid-cycle on average) |
| Manual sync | ~2 min (run `~/bin/canon-sync.sh` on Mac, then wait for next cron tick) |

**Implications:**
- MCP queries in a Claude session started within 7 minutes of an Obsidian edit may not reflect those changes. If freshness matters, run the sync script manually before starting the session.
- The server cron re-indexes every 2 minutes unconditionally — `git pull --ff-only` exits 0 even when nothing changed, so the index POST fires regardless. Acceptable background cost for now.
- The parallel session protocol (always `git pull` before committing from the server) is the safety net if a Claude session and an Obsidian edit touch the same file in the same window.
