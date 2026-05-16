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

- ✅ `record_type` ChromaDB metadata field — indexer defaults canon files to `canonical`, `drafts/` to `draft`
- ✅ `/search/docs` filters by `record_type` (default `canonical`, `any` opt-in)
- ✅ `/context`, `/project-state`, `/brief` hard-filter `active_doctrine` to canonical
- ✅ `/brief` emits provenance block (`generated_by`, `source_ids`, `source_hashes`, review state)
- ✅ `stale_acknowledgments` table in workflow-state-service
- ✅ `POST /workflow/stale/ack` + `GET /workflow/stale/acks`
- ✅ `/stale-items` filters acknowledged items (until `reviewed_through` expires)
- ✅ Indexer derives `updated_at` from git last-commit date (with mtime fallback) — closed the circular dep where staleness rules couldn't fire without frontmatter discipline
- ✅ MCP tools: `acknowledge_stale`, `list_stale_acks`
- ✅ `prismo stale` / `prismo stale ack` / `prismo stale acks` CLI
- ✅ `prismo brief <project>` CLI — fetches `/brief`, displays prose + provenance footer
- ✅ `prismo capture "<text>"` CLI — POSTs to `/workflow/capture`; lives in workflow-state-service as `pending-review` operational state per Decision 018, NOT canon. Promotion to `drafts/` is explicit via `prismo capture promote <id>`. MCP tools: `capture_signal`, `list_captures`.
- ✅ `prismo session start/end/current/ensure/focus` CLI — wraps workflow-state-service
- ✅ Cron installed: daily 0800 UTC, `prismo stale` → `~/.prismo-stale.log`

### Structural enforcement layer (shipped 2026-05-16)

Everything below turns a written rule into infrastructure:

- ✅ **Service Rule check — HTTP side** (Decision 017) — `_check_service_rule_compliance` runs at FastAPI startup, parses HTTP Endpoint Mapping table, fails app startup on undocumented routes
- ✅ **Service Rule check — MCP side** (Decision 017, shipped 2026-05-16) — `context_mcp/main.py` AST-parses MCP tool definitions, extracts `client.<method>(f"{API_BASE}/...")` calls, fetches `/openapi.json` from `API_BASE` with retry, set-diffs, fails MCP startup on any tool wrapping a nonexistent HTTP route. Closes the symmetric gap (HTTP-side ensures every route is documented; MCP-side ensures every adapter wraps a real route). Caught a real latent bug on first run: `get_doc_section` MCP tool wrapped `GET /get/doc` which was contract-documented but never implemented; fixed by implementing the route. 28 api routes, 21 MCP tools, both checks green.
- ✅ **Session ensure hook** (Decisions 014, 016) — UserPromptSubmit hook calls `prismo session ensure`, which on new-session creation closes orphan sessions, seeds `current_focus` from stdin (the prompt), and emits a `[V2 HYDRATED CONTEXT]` block surfacing active_doctrine, active_proposals, recent_changes, unresolved_tensions, and unacknowledged stale items. Runtime starts hydrated whether the operator remembers or not.
- ✅ **SessionEnd hook** — calls `prismo session end` when Claude exits
- ✅ **Doctrine-service gate downgraded** (Decision 019 revised) — from arbitrary two-week soak to signal-conditional (first real ack OR confirmed-impossible signal)
- ✅ **`updated_at` derivation** — makes the staleness loop structurally able to fire without per-doc frontmatter discipline

### Remaining Phase 2.5 work

- ✅ **Soak gate closed** (2026-05-16) — replaced by test fixtures (`tests/test_stale_rules.py`). The "wait for real signal" gate was a substitute for not having a test harness; with `evaluate_staleness` extracted as a pure function and 12 tests covering all rules + full closure pattern simulation, the loop is verified deterministically. Thresholds also tuned to iteration cadence (proposed 90d → 14d, experimental 60d → 7d). See [[../decisions/019-lifecycle-loop-closure-pattern|Decision 019 annotation 2026-05-16]]. Phase 3 unblocked.
- ✅ HTTP contract documentation backfill — shipped 2026-05-16
- ✅ Decision 018 retrofit on `/brief` callers — CLI surfaces provenance; future web UI inherits the contract
- ✅ **Service Rule structural enforcement** — shipped 2026-05-16. `api/main.py` `_check_service_rule_compliance` runs at startup; undocumented routes fail-to-start. Turns Decision 017 into infrastructure.

---

## Phase 3 — Layer 2 maintenance intelligence ⏳ scoped 2026-05-16, build pending

Revised scope (Decisions 013, 017, 020): trio collapses to two services.

- **doctrine-service** — Law 1 territory. Scoping locked by [[../decisions/020-doctrine-service-structural-coherence-engine|Decision 020]]: structural coherence engine, owns staleness + supersession-minimal + metadata reconciliation + provenance integrity + structural topology. Lives at top-level `doctrine/` (peer to `api/`, `workflow/`). Core test: self-evident vs arguable. Produces measurements, never judgments. Module-first; split when scaling/ownership/runtime diverges.
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
