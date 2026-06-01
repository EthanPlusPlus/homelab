---
name: Prismo system overview
description: What Prismo is, the hardware, services, directory structure, and repos — shared across all team sessions
type: project
---

## Who You Are

You are Claude Code running on or connected to Prismo.
You execute changes only after the person you are working with has reviewed and approved a plan.

---

## The System

The whole system — Proxmox host, VM, services, projects, docs, and workflow — is called **Prismo**.

- **Proxmox host** — bare metal on a 2017 iMac, IP 192.168.1.9
- **Ubuntu Server VM** — Ubuntu 24.04, static IP 192.168.100.10 (vmbr0 internal subnet), Tailscale IP 100.92.226.121. Internet access via Tailscale subnet router on Proxmox — NAT/MASQUERADE does not work on this setup.
- **Code projects** — ~/projects/context-server, ~/projects/devcamp (sparse — no docs/), ~/projects/flight-planner, ~/projects/even (sparse — no docs/)
- **Knowledge** — ~/canon/prismo, ~/canon/context-server, ~/canon/exam-prep, ~/canon/flight-planner, ~/canon/even

## Active Services

| Service | Access |
|---------|--------|
| context-server API | http://localhost:8000 |
| context-server MCP | http://localhost:8001/mcp |
| Flight Planner | http://ubuntu-server.tail58b10c.ts.net:8080 |
| Portainer | http://100.92.226.121:9000 |
| Tailscale | ubuntu-server.tail58b10c.ts.net |

---

## Directory Structure

Two sibling directories separate code from knowledge:

```
~/projects/    ← code repos only (sparse-checkout — no docs/ present)
  context-server/
  devcamp/
  flight-planner/  ← no git repo, copied directly

~/canon/       ← knowledge only (docs worktrees + knowledge bases)
  prismo/      ← primary clone of prismo repo (docs-only)
  context-server/  ← linked git worktree, docs/ only
  exam-prep/   ← study materials (no git repo)
  flight-planner/  ← local canon only (no git repo)
```

**Prismo canon** (`~/canon/prismo`) — docs-only repo. The **Prismo system canon**: it owns cross-cutting governance (V2 masterplan/roadmap, architectural laws, lifecycle decisions, shared memory, prismo CLI) AND the literal homelab infrastructure (hardware, Proxmox/VM setup, services).

**Component canons** (`~/canon/<name>/`) — own implementation-level decisions for that component (e.g. `context-server/decisions/008` for lifecycle-aware-retrieval implementation, but the Three Laws governing it live in `prismo/decisions/017`).

**Code projects** (`~/projects/<name>`) — code only, no docs/ in working tree. Docs live as linked worktrees in `~/canon/<name>/`.

### Where do new decisions go?

- **Cross-cutting / system-wide** → `~/canon/prismo/docs/decisions/`. Examples: V2 governance (013–019), shared memory model (010), session bootstrap (012, 016), capability contracts.
- **Component-specific implementation** → `~/canon/<component>/docs/decisions/`. Examples: context-server stack choice, MCP transport, code indexer design.
- **When in doubt:** if the decision affects multiple components or how Prismo-the-system works, it's prismo. If it only affects one component's internals, it's component-local.

Every project repo is self-contained — each carries its own STRUCTURE.md, CLAUDE.md, and docs/context/.

---

## If Something Looks Wrong

Check recent-changes.md and constraints.md in ~/canon/prismo/docs/context/ before assuming anything.
If the docs contradict reality, that is worth surfacing — propose a correction through the workflow.
