---
id: "032"
title: Portability as a first-class constraint for commercial viability
status: active
record_type: canonical
category: governance
date: 2026-05-31
---

# Decision 032 — Portability as a first-class constraint for commercial viability

## Status
Adopted

## Date
2026-05-31

## Context

Phases 0–4 are complete. The system is architecturally sound: loose coupling,
HTTP-first, provider abstraction, Docker containers, open protocols. The
masterplan's foundational principles (durable over trendy, no vendor lock-in,
composable services) were written with portability in mind.

The strategic direction has sharpened: Prismo is being built toward commercial
viability. The product model is deliberately undefined — B2B SaaS, open-source,
consulting, or something else. That ambiguity is intentional. What is not
ambiguous is the floor: the system must be deployable on any standard
infrastructure, not just the current Proxmox/Ubuntu/Tailscale setup.

The foundations are right. The coupling is at the edges — specific hardcoded
values and assumptions accumulated during rapid iteration that are now worth
addressing explicitly.

## Decision

### Portability is a first-class build constraint

Every future build decision must pass the test: **does this run on any standard
infrastructure?** Hardcoded hostnames, paths, identities, and networking
assumptions are now first-class technical debt, not acceptable shortcuts.

### Current coupling inventory

The specific edges to address, roughly in priority order:

**Hardcoded hostname** — `ubuntu-server.tail58b10c.ts.net` appears in:
- `prismo-ui` `.env.local` and `docker-compose.yml`
- CLAUDE.md files across every project repo
- MCP server address in machine-setup runbooks
- `prismo` CLI default `CONTEXT_API` value

Must be replaced with a single configurable `PRISMO_HOST` (or equivalent)
that flows through all surfaces via environment variable.

**Tailscale as access control** — Tailscale is the current security layer.
A portable system cannot assume Tailscale is present. Auth (API keys at
minimum) must replace Tailscale as the mechanism that makes the system safe
to expose. Tailscale remains a valid *deployment option* for private setups,
but must not be a *requirement*.

**Path assumptions** — `/home/ethan/canon/`, `/home/ethan/projects/`, the
`prismo` symlink from `~/canon/homelab/scripts/`. These must be configurable:
- `CANON_PATH` already exists but is not consistently used
- The `prismo` CLI must be installable independently of the homelab repo
  (pip package or standalone binary pointing at any Prismo API)
- Docker volume mounts must reference env-var paths, not user home directories

**GitHub identity** — `git@github.com:EthanPlusPlus/` is baked into setup
runbooks. Portable means any git remote, any org, any user.

**Split docker-compose** — context-server and prismo-ui have separate
`docker-compose.yml` files. Commercial-grade onboarding means a single
`docker compose up` that starts the full stack from one directory with one
`.env` file.

### What this does not change

The architecture is sound and does not require rework:
- HTTP-first service design
- Provider abstraction (EmbeddingProvider, SynthesisProvider, AnalysisProvider)
- Docker containerisation
- PostgreSQL + pgvector
- The ReviewItem contract and synthesis loop
- Canon as git-backed markdown

This decision is about edges, not foundations.

### Build priority order (follows from this decision)

1. **Env var audit** — replace all hardcoded hostnames, paths, and identities
   with configuration; establish a canonical `.env.example` covering the full stack
2. **Auth** — API key auth at minimum; replaces Tailscale as the access layer
   and makes the system network-agnostic
3. **Single compose** — one `docker compose up` story, one env file, full stack
4. **Observability** (Phase 6) — metrics, structured logging, alerting; required
   to operate reliably on any infrastructure
5. **Conversational UI** — the product interface; builds on top of the
   portable, authenticated, observable stack

## Rationale

- Undefined product model is intentional — portability keeps all doors open
- Commercial grade requires being deployable without a call to Ethan
- Auth is not optional once Tailscale is removed as the security layer
- The masterplan already stated these principles; this decision makes them
  operational constraints, not aspirations

## Consequences

- All new code and config must use env vars for host, path, and identity
- Tailscale-specific docs move to "optional deployment" section of runbooks,
  not the default setup path
- The `prismo` CLI becomes a standalone installable, not a homelab-repo symlink
- A single `.env.example` becomes the canonical onboarding artifact

## Related

- [[013-v2-masterplan-adopted|Decision 013]] — founding masterplan; portability
  was always a principle, this decision makes it a constraint
- [[031-web-ui-operational-visibility-forcing-function|Decision 031]] — Phase 5;
  the conversational UI is now positioned as the product interface, not just a
  collaboration surface
- [[030-billing-architecture-intelligence-tiers|Decision 030]] — billing
  architecture remains valid; LiteLLM already supports model-string swapping
  across providers
- [[025-runtime-intelligence-layer-topology|Decision 025]] — runtime topology
  already provider-abstracted; no changes needed
