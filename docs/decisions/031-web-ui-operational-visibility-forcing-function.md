---
id: "031"
title: Web UI — operational visibility as primary forcing function
status: active
record_type: canonical
date: 2026-05-31
---

# Decision 031 — Web UI: operational visibility as primary forcing function

## Status
Adopted

## Date
2026-05-31

## Context

The Phase 5 roadmap deferred the web UI until "non-CLI contributors actually need access
(Shrey/Kyle)." That framing assumed the forcing function was collaborative access for
non-technical contributors.

Phases 0–4 are now complete. The system has grown to:

- 30+ decisions, 50+ API routes, 4 named runtime roles
- synthesis-service, doctrine-service, pipeline-service, workflow-state-service all live
- `prismo` CLI with 14 subcommands across the surface area
- 1316+ indexed docs

Understanding the state of the system now requires running 10+ CLI commands and
mentally joining results across them. That is a builder-visibility problem — independent
of whether Shrey/Kyle are ready to use Prismo. Phase 6 (observability) names the same
problem at the infrastructure level.

All the data exists today in the API. No new backend work is required for a first slice.

## Decision

### Operational visibility is the primary forcing function for Phase 5

The web UI ships as an internal operational visibility tool for the builder first.
Collaborative access (Shrey/Kyle) is a second slice, not the gate.

Phase 5 begins now, not when collaborators are ready.

### First slice — minimal ops dashboard

A coherent visual window into system state, consuming existing API endpoints:

| Panel | Endpoint |
|-------|----------|
| ReviewItem queue | `GET /review/queue` |
| Synthesis metrics | `GET /workflow/metrics` |
| Doctrine health | `GET /doctrine/validate` |
| Runtime topology | `GET /runtime/topology` |
| Stale items | `GET /workflow/stale-items` |
| Pipeline activations | `GET /pipeline/activations` |
| Capture list | `GET /workflow/captures` |

Design constraint: operational visibility and continuity, not dashboards-first (per
v2-roadmap Initiative 5.1). The UI should answer "what is the system doing right now"
before it answers "what are the project metrics."

### Auth

Tailscale-gated network access. The VM is already on the Tailnet. No new auth
infrastructure required for the first slice. Login/RBAC deferred until collaborative
access is the actual next forcing function.

### Stack

Per v2-roadmap Initiative 5.1: Next.js / TypeScript / Tailwind / shadcn/ui frontend,
served independently, consuming the existing FastAPI context-server API directly.

### Phase 6 runs in parallel, not after

The Phase 6 infra observability stack (Prometheus / Grafana / Loki) is a background
track — service metrics and Docker log aggregation added incrementally. It is not a
prerequisite for Phase 5. The web UI is the primary visibility layer; infra tooling
augments it.

### Second slice — collaborative access

When Shrey/Kyle are onboarded, the same shell receives:

- conversational interface (project-aware queries)
- contribution capture (natural language → ReviewItem)
- organizational dashboards

Authentication, multi-user session tracking, and RBAC are second-slice concerns.

## Rationale

- The system is large enough that coherent visual state is useful to the builder,
  independent of any collaboration use case
- All first-slice data exists in the API today — no new backend work required
- Tailscale-gated access costs zero new infrastructure
- Starting visibility-first avoids over-engineering for collaboration patterns that
  aren't yet known
- Phase 5 and Phase 6 address the same underlying problem (system legibility at scale)
  and are better run in parallel than sequenced

## Consequences

- Phase 5 no longer waits on collaborator readiness — work begins immediately
- v2-progress.md Phase 5 updated to reflect new primary forcing function
- Phase 6 infra stack added incrementally alongside Phase 5, not after
- When Shrey/Kyle need access, the web shell is already built — conversation and
  contribution surfaces are additive

## Related

- [[021-reviewitems-as-judgment-boundary|Decision 021]] — primary data the dashboard surfaces
- [[020-doctrine-service-structural-coherence-engine|Decision 020]] — doctrine health panel
- [[025-runtime-intelligence-layer-topology|Decision 025]] — runtime topology panel
- [[026-layer-3-5-pipeline-service|Decision 026]] — pipeline activations panel
- v2-roadmap Phase 5 + Phase 6 — original scope this decision reframes
