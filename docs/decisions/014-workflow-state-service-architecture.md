---
id: "014"
status: active
record_type: canonical
---
# Decision 014 — Workflow-state-service architecture

## Status
Adopted

## Date
2026-05-16

## Context

V2 Roadmap Initiative 2.2 calls for a workflow-state-service that moves workflow enforcement
into operational infrastructure — replacing CLAUDE.md rituals, pull-before-commit discipline,
manual synchronization, and session bootstrap loops.

The service was implemented as part of Phase 2 (context-server v2). The shape of the service —
what objects it tracks, what state it owns, how it's invoked — was decided during
implementation but never recorded as a decision. Sukuna 2026-05-15 flagged this gap.

## Decision

The workflow-state-service is built around a three-object model, persisted in SQLite alongside
context-server, exposed through both HTTP and MCP transports.

### Core objects

**Session** — a single working session for one contributor on one project.
- Started by `start_session(project, contributor)`; closed by `end_session(session_id)`.
- Holds session-scoped operational state (current focus, active workstream pointers).
- Operational state only — does not touch canon.

**Workstream** — a named unit of active work that persists across sessions.
- Multiple workstreams per contributor allowed.
- Lifecycle: `active` / `paused` / `closed`.
- Created and updated independently of sessions.

**SessionContext** — operational continuity attached to a session.
- Current focus (string, freeform).
- Active workstream pointers.
- Updated via `update_focus`.

### Service boundaries

- **Owns:** active sessions, active workstreams, session focus, operational concurrency awareness.
- **Does not own:** canon decisions, doctrine state, project metadata, proposals — those live in canon.
- **Feeds into:** `ContextBundle.core_operational_state` (see [[architecture/phase1/canon-object-model|canon-object-model]]).

### Event log

An `operational_events` table is pre-positioned in schema but not yet wired into write paths.
This is intentional: when event-driven evolution becomes necessary, the substrate is already there.
Until then, the service operates on direct state mutations.

### Transports

- HTTP endpoints under `/workflow/*` for service-to-service use.
- MCP tools (`start_session`, `end_session`, `update_focus`, `create_workstream`, `update_workstream`,
  `get_workflow_state`) for runtime consumption.

## Rationale

**Why three objects, not one or many.** The canon object model already names Session, Workstream,
and OperationalBrief / ContextBundle. Collapsing into one object would force overloading; expanding
to more (Task, Activity, EventStream) would replicate V1's accidental complexity. Three is the
smallest set that maps to actual operational reality.

**Why SQLite, not the vector store.** Operational state is structured, mutable, and frequently
queried by exact predicates (session_id, contributor, project). Vector search adds nothing.
Sharing SQLite with the existing code-graph database keeps the runtime footprint small.

**Why operational events are pre-positioned but inert.** The masterplan principle of structural
workflow enforcement implies eventual event-driven flow. But premature event-driven design adds
coupling without payoff at current scale. The table exists; consumers do not.

## Consequences

- Session-start MCP discipline (see [[016-session-hydration-replaces-warmup|016]]) depends on this service.
- Operational concurrency awareness (replacement for pull-before-commit) gains a structural source
  of truth but is not yet built — service tracks active sessions but does not detect conflicts.
- Workflow tracking and canon tracking are explicitly separate. Cross-cutting reports
  (e.g., "what canon did this workstream touch?") will require an explicit join layer in a
  future decision.
