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

The full session workflow lives in `docs/memory/workflow.md` (auto-loaded as shared memory).
That is the authoritative version — includes session bootstrap (step 0), canon discipline
Phases 1 and 2, and the parallel-session protocol. Defer to it.
