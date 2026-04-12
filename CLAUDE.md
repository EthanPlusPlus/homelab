# Prismo — Homelab Docs

You are working in the Prismo homelab docs repo. Prismo is the name for the
whole system: Proxmox host, Ubuntu Server VM, services, projects, and the
workflow that governs all of them.

This repo contains only docs — no application code. It is Prismo's knowledge
base: decisions, runbooks, architecture, and live context.

## Doc Conventions

See `docs/STRUCTURE.md` for folder purposes, naming rules, and what belongs where.

## MCP

The context-server MCP provides semantic retrieval over all indexed docs.

To add it (run from this repo directory):

    claude mcp add context-server --transport http \
      http://ubuntu-server.tail58b10c.ts.net:8001/mcp

Always retrieve context via MCP before reasoning or planning.

## Workflow

1. Retrieve context from MCP
2. Check `docs/context/` — progress.md, recent-changes.md, constraints.md
3. Propose a plan — wait for approval before touching anything
4. Execute the approved plan
5. Update `docs/context/` and any affected docs
6. Re-index: `curl -X POST http://localhost:8000/index`
7. Commit and push
