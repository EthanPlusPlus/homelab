---
record_type: canonical
id: "033"
title: API Key Auth Layer
date: 2026-06-05
status: active
category: architecture
supersedes: []
superseded_by: []
---

# Decision 033 — API Key Auth Layer

## Status
Active — implemented 2026-06-05.

## Context

context-server had no application-level auth. Access was gated entirely by Tailscale network
membership: if you were on the Tailscale network, you could hit the API. This conflates two
separate concerns — network transport and application auth. Decision 032 established portability
as a first-class constraint; Tailscale-as-auth is the clearest portability blocker.

### The Tension Named

The iMac uses Tailscale as its *network transport* to reach the VM (not as auth). The VM's
internet access itself is provided by the Tailscale subnet router on Proxmox (see constraints.md).
Tailscale is load-bearing infrastructure, not just an access control mechanism. These must not
be conflated: removing Tailscale-as-auth does not mean removing Tailscale.

## Decision

**Mechanism:** `Authorization: Bearer <API_KEY>` header on all API routes.

**Dev mode:** If `API_KEY` env var is unset or empty, all requests pass. This is explicit and
documented — not a misconfiguration. Local development remains frictionless.

**Exempt routes:** `/health`, `/docs`, `/redoc`, `/openapi.json`. Health is needed for liveness
checks; openapi.json is read by the Service Rule check at startup (Law 1 — structural enforcement
must not be blocked by its own infrastructure).

**Single shared key:** One key for all clients (prismo CLI, MCP server, prismo-ui) at current
homelab scale. Per-client keys are a future iteration when Shrey/Kyle are active contributors.

**No network-topology bypass:** Tailscale-originating requests are not exempt. The auth layer
must not know or care about network topology — that would reintroduce the coupling being removed.

## Implementation

- `api/auth.py` — FastAPI middleware, reads `API_KEY` from env on each request (not cached at
  startup, so key rotation takes effect without restart)
- `api/main.py` — middleware wired at app level; `Authorization` added to CORS allowed headers
- `context_mcp/main.py` — `_client()` factory returns `httpx.AsyncClient` with auth headers
  pre-configured; all MCP → API calls go through it
- `canon/prismo/scripts/prismo` — `_api_curl()` helper wraps all 46 `curl -sf` calls targeting
  `CONTEXT_API`; passes header when `API_KEY` is set
- `docker-compose.yml` — `API_KEY=${API_KEY:-}` in both `api` and `mcp` service env sections
- `.env.example` — `API_KEY=` documented with dev-mode note

## Consequences

- The iMac sets `export API_KEY=<secret>` in `~/.zshrc` (or a sourced `.env` file). Tailscale
  transport is unchanged. One additional env var is required.
- Any deployment without Tailscale can now be secured with just the API key. Portability
  constraint is no longer blocked by auth.
- prismo-ui does not yet pass the API key (it makes direct browser fetch calls that cannot
  carry a server-side secret). prismo-ui auth is a separate concern — addressed when the UI
  gains a server-side layer or when public exposure warrants it.

## Relationship to Other Decisions

- [[032-portability-commercial-constraint]] — auth is step 2 of the portability build order
- [[017-three-architectural-laws]] — Law 1: auth validation is deterministic (key matches or
  not); exempt paths protect structural enforcement infrastructure
- [[025-runtime-intelligence-layer-topology]] — no new runtime role introduced; auth is
  infrastructure, not intelligence
