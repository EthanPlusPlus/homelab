---
record_type: canonical
id: "037"
title: Loop conversation continuity — messages, checkpoints, session cycling
date: 2026-06-09
status: active
category: architecture
supersedes: []
superseded_by: []
---

# Decision 037 — Loop conversation continuity: messages, checkpoints, session cycling

## Status

Adopted. Companion to Decision 036 (the role) and Decision 038 (the gate).

## Context

The loop (Decision 036) needs a conversation memory model. The dominant usage
pattern (Ethan, 2026-06-09): long ideation/planning arcs followed by execution,
spanning many sessions over days. The named failure modes to design against:
proceeding on unvalidated assumptions, insufficient research, incomplete
requirements. Context windows are finite today but growing — the design must not
bake small-window assumptions into the architecture.

Decision 014 gives Session/Workstream/SessionContext; PI-020 proposed the
workstream build-out; neither models conversation content.

## Decision

### One new object: Message

`Message` is the single ontology addition — turns persisted under sessions.

```
Workstream → Session → Message → Capture
```

- Stored in PostgreSQL (workflow-state migration is a build prerequisite — A0)
- Write semantics: user message immediately; assistant message on turn
  completion; tool calls/results as they land. Crash mid-turn loses only the
  in-flight assistant turn; UI shows an explicit "turn incomplete" state.
- Captures gain message-level provenance (which exchange produced this capture)

Assumptions and open questions are **capture subtypes with a disposition
lifecycle** (`open` / `validated` / `accepted-as-risk`), detected automatically
by the response processor (Decision 028 extension) — not new object types.
Explicit logging never happens in flow; that lesson is why Decision 028 exists.

### Stored transcript ≠ assembled context

The transcript is the durable record. The per-turn context is a derived,
budgeted view the loop assembles, in fixed order (stable prefix → prompt/KV
cache hits on both API and local):

```
1. System prompt      (versioned canon artifact, loaded at session start)
2. Facet block        (replaced on activation change — never accumulated)
3. Rolling summary    (compacted older history)
4. Recent window      (last N turns verbatim)
5. Current message
```

- Design floor: 32k usable context regardless of provider
- Compaction triggers on an approximate character budget (provider tokenizers
  differ; precision is not worth the coupling)
- Large tool results are truncated after the turn completes — tool call + 
  reference retained, payload re-fetchable
- Input size limits with graceful rejection (oversized pastes)

### Session cycling over workstreams is the primary continuity mechanism

Instead of one endless conversation repeatedly squashed by lossy background
compaction, the context window filling is a **deliberate checkpoint**: end the
session, write a structured checkpoint, start fresh hydrated from the
workstream. In-session compaction remains as the fallback when flow can't break.

**The checkpoint is a structured judgment artifact, not a freeform summary:**

- Decisions made this session (and which went to canon)
- Assumptions made — flagged, carried forward until dispositioned
- Open questions / unresolved threads
- Next steps
- Active activations (so the next session re-fires them)

Checkpoint mechanics:

- **Auto-draft, async review** — never a blocking modal at session end (it would
  be rubber-stamped). Next session opens with an "unreviewed checkpoint" banner.
- Trivial sessions (below a turn/capture threshold) skip the checkpoint — a
  one-line summary suffices. Abandoned sessions are the common case for
  non-technical contributors.
- Checkpoints fire only at clean turn boundaries (never mid-tool-chain)
- Idle timeout auto-closes sessions with checkpoint; explicit close and
  context-pressure prompt ("~70% — checkpoint or compact?") both exist
- Stored in workflow-state (operational state, feeds hydration) — not canon

**Scaling decoupling (explicit):** the checkpoint conflates two functions with
different futures. Context-pressure relief fades as windows grow; judgment
checkpointing (decisions/assumptions made explicit and reviewable) is valuable
at any window size. The cycling *trigger* is therefore a tunable parameter —
as windows grow, the trigger migrates from "window full" toward "milestone
reached / phase transition." Nothing structural changes; messages are persisted
regardless.

### Workstream-scoped hydration

A fresh session in a workstream hydrates from: goal, phase, accumulated
decisions, **outstanding assumptions**, open questions, last checkpoint(s).
Implemented as a workstream scope on the existing brief engine (Decision 018
provenance rules apply). The brief regenerates on checkpoint write and is
cached between — one interpretive call per checkpoint, not per session start.
Multi-contributor workstreams merge checkpoints from all contributors' sessions
(interpretive merge — Law 2).

### Activation stickiness

- Activations are sticky for the session lifetime
- Phase transitions can only **add** (raised priors for build/deploy facets in
  execution) — never remove; the architect facet's reasoning is needed during
  build (Ethan ruling, 2026-06-09)
- Release is manual only ("drop the architect facet")
- Checkpoints record active activations; the next session re-fires them with
  **re-fetched** context (current canon, not a stale snapshot)
- This partially implements PI-019 (session-aware activation)

### Multi-user semantics

- Sessions are per-contributor; concurrent sessions in one workstream are
  allowed and expected
- Workstream state writes (checkpoints, phase) use optimistic concurrency
  (version column, retry on conflict)
- Shared sessions (two users, one conversation) are out of scope v1 — named
  to prevent creep

### Embedding: batch, not write-path

Messages are persisted on the hot path; embedding happens in a nightly batch
job (Sukuna-pattern maintenance) over eligible messages only — substantive
assistant turns, checkpoints, capture-linked messages. Conversation latency
never depends on the embedding model. Semantic retrieval over history is
deferred; when it ships it is a flag-flip, not a migration. Naive RAG over raw
chat turns retrieves anaphoric noise — granularity revisited when retrieval
actually ships.

## Rationale

- A deliberate, reviewable checkpoint beats silent lossy compaction for work
  whose failure modes are unvalidated assumptions and lost decisions
- Storing everything while assembling selectively keeps every option open
  (longer windows, retrieval, audits) at minimal cost
- One new object type honours the masterplan's ontology-creep warning; reusing
  captures for assumptions composes instead of duplicating
- Persisted transcripts make conversations first-class material for the
  response processor, synthesis, and future Sukuna passes

## Consequences

- PostgreSQL migration of workflow-state-service becomes build phase A0
  (concurrent writers are SQLite's failure zone); operational DB backup story
  verified in the same phase
- `messages` table + `contributors` table land in A0/A
- The system prompt becomes a versioned canon artifact with per-provider
  adaptation — authoring is a named Phase A task
- `POST /pipeline/process-response` receives concatenated assistant text
  segments (tool payloads excluded), invoked async fire-and-forget per turn
- Assumption ledger gets a query surface (`GET /workflow/workstream/:id/assumptions`)
- PI-019 partially implemented; PI-020 absorbed (workstream API ships in
  Phase C)

## Related

- [[036-loop-runtime-role-contract-billing|Decision 036]] — the role this serves
- [[038-workstream-phase-gate|Decision 038]] — consumes assumption/question state
- [[014-workflow-state-service-architecture|Decision 014]] — the service extended
- [[028-response-processor-auto-capture|Decision 028]] — assumption detection extends it
- [[018-synthesis-provenance-and-recursion-prevention|Decision 018]] — brief provenance rules apply to workstream briefs
- [[../proposed-ideas/019-session-aware-facet-activation|PI-019]] — partially implemented
- [[../proposed-ideas/020-workstream-session-grouping|PI-020]] — promoted into this decision
