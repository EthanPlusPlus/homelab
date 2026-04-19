---
name: Prismo system overview
description: What Prismo is, the hardware, services, directory structure, and repos — shared across all team sessions
type: project
---

## Who You Are

You are Claude Code running on or connected to Prismo — Ethan's homelab system.
You execute changes only after the person you are working with has reviewed and approved a plan.

---

## The System

The whole system — Proxmox host, VM, services, projects, docs, and workflow — is called **Prismo**.

- **Proxmox host** — bare metal on a 2017 iMac, IP 192.168.1.9
- **Ubuntu Server VM** — Ubuntu 24.04, IP 192.168.100.10, Tailscale IP 100.92.226.121
- **Code projects** — ~/projects/context-server, ~/projects/devcamp (sparse — no docs/)
- **Knowledge** — ~/canon/homelab, ~/canon/context-server, ~/canon/exam-prep

## Active Services

| Service | Access |
|---------|--------|
| context-server API | http://localhost:8000 |
| context-server MCP | http://localhost:8001/mcp |
| Portainer | http://100.92.226.121:9000 |
| Tailscale | ubuntu-server.tail58b10c.ts.net |

---

## Directory Structure

Two sibling directories separate code from knowledge:

```
~/projects/    ← code repos only (sparse-checkout — no docs/ present)
  context-server/
  devcamp/

~/canon/       ← knowledge only (docs worktrees + knowledge bases)
  homelab/     ← primary clone of homelab repo (docs-only)
  context-server/  ← linked git worktree, docs/ only
  exam-prep/   ← study materials (no git repo)
```

**Homelab** (`~/canon/homelab`) — docs-only repo. The knowledge base for all of Prismo.
**Code projects** (`~/projects/<name>`) — code only, no docs/ in working tree. Docs live as linked worktrees in `~/canon/<name>/`.

The homelab repo documents homelab-level concerns only. Project-specific docs live in `~/canon/<project-name>/docs/`.

Every project repo is self-contained — each carries its own STRUCTURE.md, CLAUDE.md, and docs/context/.

---

## If Something Looks Wrong

Check recent-changes.md and constraints.md in ~/canon/homelab/docs/context/ before assuming anything.
If the docs contradict reality, that is worth surfacing — propose a correction through the workflow.
