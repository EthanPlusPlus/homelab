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

## Phase 2.5 — Architectural governance + lifecycle closure ✅ shipped (soak in progress)

Inserted between Phase 2 and Phase 3 after the Sukuna 2026-05-15 review and ChatGPT
architectural pass (2026-05-16). Phase 3 cannot start until the two-week soak completes.

### Governance (adopted as decisions)

- [[../decisions/017-three-architectural-laws|Decision 017]] — Three Permanent Laws + Layer 2 Service Rule
  - Law 1: Structural truth is deterministic
  - Law 2: Interpretation is probabilistic
  - Law 3: Capability contracts are primary
- [[../decisions/018-synthesis-provenance-and-recursion-prevention|Decision 018]] — Provenance metadata on all synthesis; `record_type` separation; permanent exclusion from `active_doctrine`
- [[../decisions/019-lifecycle-loop-closure-pattern|Decision 019]] — Detect → surface → acknowledge → propagate, with acknowledgment schema

### Implementation (shipped 2026-05-16)

- ✅ `record_type` ChromaDB metadata field — indexer defaults all canon files to `canonical`
- ✅ `/search/docs` filters by `record_type` (default `canonical`, `any` opt-in)
- ✅ `/context`, `/project-state`, `/brief` hard-filter `active_doctrine` to canonical
- ✅ `/brief` emits provenance block (`generated_by`, `source_ids`, `source_hashes`, review state)
- ✅ `stale_acknowledgments` table in workflow-state-service
- ✅ `POST /workflow/stale/ack` + `GET /workflow/stale/acks`
- ✅ `/stale-items` filters acknowledged items (until `reviewed_through` expires)
- ✅ MCP tools: `acknowledge_stale`, `list_stale_acks`
- ✅ `prismo stale` / `prismo stale ack` / `prismo stale acks` CLI
- ✅ `prismo brief <project>` CLI — fetches `/brief`, displays prose + provenance footer
- ✅ `prismo capture "<text>"` CLI — writes signal candidate to project `drafts/`
- ✅ Cron installed: daily 0800 UTC, `prismo stale` → `~/.prismo-stale.log`

### Remaining Phase 2.5 work

- ⏳ Two-week soak — observe loop behavior, sustainability of acknowledgment pattern
- ⏳ HTTP contract documentation backfill for workflow-state-service (Service Rule debt
  from Phase 2 — endpoints exist but are not in `capability-contracts.md`)
- ⏳ Decision 018 retrofit: existing `/brief` callers must surface provenance to humans
  (currently CLI does; future web UI must too)

---

## Phase 3 — Layer 2 maintenance intelligence ⏳ gated on Phase 2.5

Revised scope (Decisions 013, 017): trio collapses to two services.

- **doctrine-service** — Law 1 territory. Lifecycle, supersession graph, metadata reconciliation,
  source-hash drift detection (per Decision 018). No LLM calls. Starts as a module inside
  context-server; splits when boundaries get loud.
- **synthesis-service** — Law 2 territory. Onboarding, continuity reports, contradiction analysis,
  organizational narration. Inherits Decision 018 provenance discipline from day one.
- **"Sukuna v2" as a service is dropped.** "Sukuna" survives as the scheduled-maintenance brand
  (nightly pass, weekly audit) invoking doctrine-service + synthesis-service.

---

## Phase 4 — Runtime abstraction ⏳ not started

Per roadmap: runtime provider interface, local inference, provider routing, persistent session
systems.

**Status of Sukuna's "runtime router earlier" critique:** Resolved. Law 3 + Service Rule
(Decision 017) prevent Claude-coupling without requiring a router. Router stays in Phase 4,
to be built when there is a second runtime to route to.

**Adjacent open question:** whether `SynthesisProvider` and `EmbeddingProvider` should be
unified under a single `RuntimeProvider` (see [[../decisions/015-synthesis-provider-abstraction|Decision 015]]).
Still deferred to Phase 4. Likely resolution: a `CapabilityRegistry` that routes capability →
provider, rather than a monolithic `RuntimeProvider`.

---

## Phase 5 — Human interaction layer ⏳ partially redefined

Per roadmap: web UI, contribution capture, mobile/ambient interfaces.

**Key reframing (ChatGPT 2026-05-16):** "Layer 4 = interaction surface, not browser." A CLI
is already Layer 4 in the abstraction the masterplan defines.

Minimal Layer 4 slice now planned in parallel with Phase 3:

- `prismo brief <project>` — OperationalBrief viewer (CLI)
- `prismo capture "this matters"` — contribution capture (CLI, writes to a SignalCandidate draft)
- `prismo stale` / `prismo stale ack <id>` — lifecycle inbox (Phase 2.5)

Web UI deferred until non-CLI contributors actually need access (Shrey/Kyle). At that point,
the minimal slice is the same two reads + one write, in a browser.

---

## Phase 6 — Governance and observability ⏳ not started
## Phase 7 — Advanced research ⏳ not started

---

## How to update this doc

- Mark phase status with ✅ / ⏳ / ⚠️
- Link to decision records, audit files, and source modules — do not paste content
- Sukuna passes inform this doc, but Sukuna does not write it (drafts-only constraint applies)
- When a phase completes, write the closing decision record first, then update this index
