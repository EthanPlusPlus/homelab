# V2 Progress — Living Index

Tracks Prismo V2 progress against [[v2-roadmap]]. Updated alongside phase completions.

Adopted as canon by [[../decisions/013-v2-masterplan-adopted|Decision 013]] on 2026-05-16.

---

## Phase 0 — Canon audit ✅ complete

Deliverables (all in `architecture/v2-audit/`):

- `v1-survivors.md` — V1 patterns that survive intact into V2
- `v1-coupling-map.md` — what is tightly Claude-coupled and needs abstraction
- `v1-deprecated-patterns.md` — accidental complexity to drop in V2
- `v1-service-map.md` — V1 service inventory

Outcome: invariant structures identified, Claude-coupling surfaced, lifecycle gaps named.

---

## Phase 1 — Stable architectural contracts ✅ complete

Deliverables (all in `architecture/phase1/`):

- `canon-object-model.md` — Decision, Proposal, Project, Session, Workstream, ContextBundle,
  OperationalBrief, RuntimeProfile, Contributor
- `capability-contracts.md` — `retrieve / query / summarize / synthesize / plan / codegen /
  review / analyze / hydrateSession / generateOperationalBrief`
- `lifecycle-semantics.md` — `active / proposed / experimental / superseded / archived`,
  staleness rules, transition rules
- `retrieval-architecture.md` — 5-layer retrieval pipeline
- `design-notes.md` — reasoning under the decisions

Outcome: stable internal semantics before implementation expansion.

---

## Phase 2 — Layer 2 cognition shipped ✅ complete

### context-server v2

- Frontmatter indexing, lifecycle-aware retrieval
- `/context`, `/project-state`, `/stale-items` endpoints
- ChromaDB metadata filtering across `doc_type`, `category`, `status`
- 821+ docs indexed

### EmbeddingProvider abstraction

- Provider-independent capability interface
- `EMBEDDING_MODEL` env var, sentence-transformers default
- Layer 2 no longer hard-coupled to a specific embedding model

### Workflow-state-service

- Three-object model: Session, Workstream, SessionContext
  (see [[../decisions/014-workflow-state-service-architecture|Decision 014]])
- SQLite persistence; 6 MCP tools; HTTP `/workflow/*` endpoints
- `operational_events` table pre-positioned for future event-driven evolution

### Operational brief engine

- Live `get_context` endpoint producing ContextBundle structurally
- Live `/brief` endpoint producing prose via Layer 3 slice
- SynthesisProvider abstraction
  (see [[../decisions/015-synthesis-provider-abstraction|Decision 015]])
- Layer 2 has no direct Anthropic coupling

### Session hydration

- Hydrated-start pattern replaces the warm-up ritual
  (see [[../decisions/016-session-hydration-replaces-warmup|Decision 016]])
- ContextBundle: `core_operational_state → active_doctrine → recent_context →
  historical_context → expandable_context`

---

## Phase 3 — Layer 2 maintenance intelligence ⏳ not started

Per roadmap: doctrine-service, synthesis-service, Sukuna v2, continuity systems.

**Prerequisite blocker (Sukuna 2026-05-15):** the lifecycle enforcement loop is not closed.
`get_stale_items` is callable but nothing scheduled invokes it; no notification surfaces stale
items to humans. Build the trigger before building more services.

**Open architectural question:** Sukuna 2026-05-15 argued the three Phase 3 services overlap
heavily (stale detection, supersession tracking, drift detection appear in two of three each)
and should be collapsed. See [[../decisions/013-v2-masterplan-adopted|Decision 013 — open architectural questions]].

---

## Phase 4 — Runtime abstraction ⏳ not started

Per roadmap: runtime provider interface, local inference, provider routing, persistent session
systems.

**Adjacent open question:** whether `SynthesisProvider` and `EmbeddingProvider` should be
unified under a single `RuntimeProvider` (see [[../decisions/015-synthesis-provider-abstraction|Decision 015]]).
That call is explicitly deferred to Phase 4.

---

## Phase 5 — Human interaction layer ⏳ not started

Per roadmap: web UI, contribution capture, mobile/ambient interfaces.

**Sukuna 2026-05-15 framed Phase 5 as the actual blocker** ahead of further Layer 2 work:
without a Layer 4 surface, Layer 2 capabilities are designed against imagined Claude-Code-shaped
use cases. Web UI for Shrey/Kyle is the team-access prerequisite. Open question whether Phase 5
should jump ahead of Phase 3.

---

## Phase 6 — Governance and observability ⏳ not started
## Phase 7 — Advanced research ⏳ not started

---

## How to update this doc

- Mark phase status with ✅ / ⏳ / ⚠️
- Link to decision records, audit files, and source modules — do not paste content
- Sukuna passes inform this doc, but Sukuna does not write it (drafts-only constraint applies)
- When a phase completes, write the closing decision record first, then update this index
