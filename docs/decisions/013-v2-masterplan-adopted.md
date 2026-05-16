# Decision 013 — Prismo V2 masterplan and roadmap adopted as governing architecture

## Status
Adopted

## Date
2026-05-16

## Context

`architecture/v2-masterplan.md` and `architecture/v2-roadmap.md` define Prismo V2:

- A four-layer architecture (substrate / services / runtime / interfaces)
- Seven engineering programs and a phased execution order (Phase 0 → 7)
- Five strategic V2 priorities and five execution principles
- The reframing from "runtime-assisted organizational memory" to "persistent organizational cognition substrate"

These are the most architecturally consequential documents in canon. Sukuna 2026-05-15 flagged
that they live as `architecture/` files with no decision record adopting them — they cannot be
superseded cleanly because they were never formally adopted. Phase 0, 1, and 2 work was being
done against an unadopted plan.

## Decision

Adopt `v2-masterplan.md` and `v2-roadmap.md` as the governing architecture for Prismo V2.

- The masterplan defines philosophy, layering, and direction.
- The roadmap operationalises the masterplan: workstreams, deliverables, dependencies, phase ordering.
- Both are now adopted canon. Edits to either are governance changes and require a new decision.
- The five execution principles in v2-roadmap.md ("FINAL EXECUTION PRINCIPLES") are binding:
  context-abundance architecture, structural workflow enforcement, loose coupling everywhere,
  human authority remains central, build for organizational cognition.

## Phase status at adoption

- **Phase 0 (canon audit)** — complete. Deliverables in `architecture/v2-audit/`.
- **Phase 1 (object model, capability contracts, lifecycle semantics, retrieval architecture)** — complete.
  Deliverables in `architecture/phase1/`.
- **Phase 2 (context-server v2, metadata system, operational brief engine, session hydration, workflow-state-service)** — complete.
  See [[014-workflow-state-service-architecture|Decision 014]], [[015-synthesis-provider-abstraction|015]], and `architecture/v2-progress.md`.
- **Phase 3 (doctrine-service, synthesis-service, Sukuna v2, continuity systems)** — not started.

## Consequences

- New architectural work must reconcile with masterplan layering and roadmap phase order.
- Phase 3 cannot start until lifecycle enforcement loop is closed (see Sukuna 2026-05-15 finding).
- `architecture/v2-progress.md` becomes the living index of progress against this roadmap.
- Future decisions superseding parts of the masterplan or roadmap must be explicit, not implicit.
- Sukuna's recommendation to consider collapsing the Phase 3 trio (doctrine/synthesis/Sukuna v2)
  into fewer services is captured as an open architectural question — not resolved by this decision.

## Open architectural questions deferred

- Whether the doctrine-service / synthesis-service / Sukuna v2 trio should be collapsed (Sukuna 2026-05-15)
- Whether Layer 2 should live under `~/canon/prismo-v2/` rather than `~/canon/homelab/`
- Whether `RuntimeProvider` should unify the SynthesisProvider and EmbeddingProvider abstractions
  ([[015-synthesis-provider-abstraction|see 015]])
