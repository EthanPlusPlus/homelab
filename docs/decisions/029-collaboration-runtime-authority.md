---
id: "029"
title: collaboration_runtime authority boundaries
status: active
record_type: canonical
category: governance
date: 2026-05-30
---

# Decision 029 — collaboration_runtime authority boundaries

## Status
Adopted

> **Annotation 2026-06-09 — Decision 036:** `collaboration_runtime` is merged
> into `loop_runtime`. The authority set defined below survives intact as the
> loop's v1 tool set for **all** contributors (including Ethan — no RBAC v1),
> with one addition: `workstream_create`. Rationale: creating a named work
> container is a deterministic Layer 2 operation (PI-020), not the
> session/infrastructure control that the `workflow_admin` exclusion protects.
> Conversational workstream creation is core loop UX. The RBAC posture below
> (design from real friction) is unchanged — when differentiation becomes real,
> it lands as per-contributor tool sets within `loop_runtime`.

## Date
2026-05-30

## Context

Decision 025 declared `collaboration_runtime` as a reserved slot for non-technical
contributors (Shrey, Kyle, future collaborators) with a conservative placeholder authority
of `["read_canon", "capture_signal"]`. The comment noted: "Authority boundary to be decided
before any Layer 4 surface ships for non-technical contributors."

Phase 5 (WhatsApp, web UI) is approaching. The authority boundary needs to be set now.

The principle from Decision 025: "If you cannot name the role, the intelligence should not
exist." The corollary for authority: if you cannot name what the role is permitted to do,
the surface should not ship.

## The Usage Model

Shrey and Kyle interact with Prismo through conversation — they ask questions, share ideas,
react to proposals, give strategic input. They are not operators. They do not run CLI tools
or manage infrastructure.

What they should be able to do via Prismo's intelligence layer:
- Read and query canon (project state, active decisions, recent changes)
- Create captures from conversation (signal Prismo preserves for later)
- Approve or reject ReviewItems (they are stakeholders in organizational direction)
- Write proposed-ideas (their strategic input should enter the canon pipeline)

What they should NOT be able to do:
- Direct canon authoring (no bypassing the ReviewItem boundary)
- Trigger synthesis runs (operational infrastructure control)
- Invoke analysis/prior-art research (cost-bearing operations without explicit initiation)
- Modify workflow state directly (sessions, workstreams are operator-controlled)

## Decision

`collaboration_runtime` authority:

```python
authority: [
    "read_canon",
    "capture_signal",
    "reviewitem_approval",
    "proposed_idea_creation",
]
```

**Not granted:**
- `canon_authoring` — all writes go through the ReviewItem boundary
- `synthesis_invocation` — synthesis runs are operator-initiated
- `analysis_invocation` — cost-bearing, requires explicit operator initiation
- `workflow_admin` — session/workstream management stays with the operator

## On Role-Based Access Control

A contributor-level RBAC system (different authority per contributor, not just per runtime
role) may be needed eventually. Not now. The current model is coarse: the collaboration
runtime has a single authority set for all non-technical contributors. When the team grows
and authority differentiation becomes a real need, that is the time to design RBAC.

The forcing function: a specific conflict between what two contributors should be allowed
to do. Design from real friction, not speculation.

## Consequences

- `collaboration_runtime` authority updated in `runtime/topology.py`
- Phase 5 surface design (WhatsApp, web UI) can proceed knowing what the intelligence
  behind it is permitted to do
- ReviewItem approval via WhatsApp/web is in scope from day one
- Proposed-idea creation via conversation is in scope from day one
- Canon authoring remains operator-only (Ethan via coding_runtime)

## Related

- [[025-runtime-intelligence-layer-topology]] — defines the runtime role model
- [[021-reviewitems-as-judgment-boundary]] — the boundary collaboration_runtime respects
- [[013-v2-masterplan-adopted]] — multi-user design context (Shrey/Kyle roles)
