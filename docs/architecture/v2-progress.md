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

## Phase 2.5 — Architectural governance + lifecycle closure ✅ complete (soak gate closed 2026-05-16 via test fixtures — [[../decisions/019-lifecycle-loop-closure-pattern|Decision 019 annotation]])

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
- ✅ `prismo capture "<text>"` CLI — POSTs to `/workflow/capture`; lives in workflow-state-service as `pending-review` operational state per Decision 018, NOT canon. Per [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]] (2026-05-17), captures are now consumed by synthesis-service which emits ReviewItems to the review-queue; the legacy `prismo capture promote` path is deprecated. MCP tools: `capture_signal`, `list_captures`.
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

## Phase 3 — Layer 2 maintenance intelligence ⏳ resequenced 2026-05-17

Revised scope (Decisions 013, 017, 020, **021**): trio collapses to two services,
and the build order flips per [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]].

**Build order (current):**

1. ✅ **ReviewItem contract + endpoints** (shipped 2026-05-17) — 7 endpoints at `/review/queue` prefix in `workflow/review.py`, `review_items` table in workflow DB, 14 tests covering all flows + categorized rejection_reason enforcement. Service Rule: 35 routes documented.
2. ✅ **synthesis-service minimal** (shipped 2026-05-17) — `synthesis/` package with prompt template, four quality gates (parse, backpressure, confidence ≥ 0.7, dedup ≥ 0.85), pure-ish runner with injected I/O, `POST /synthesis/run` endpoint. 14 tests. **First live run emitted 2 ReviewItems** from pending captures (confidence 0.82 + 0.75). The Decision 021 loop is operational end-to-end. Initial thresholds env-tunable; observation week will calibrate.
3. **`prismo review` CLI** — terminal TUI for approve/reject/edit. CLI first, NOT web UI (ontology validation needed before UI investment).
4. **Observation week** — track emission rate, approval rate, rejection reasons, edit frequency, time-to-decision, dedup. Empirical tuning of synthesis-service quality gate.
5. **doctrine-service Day-1 capabilities** per [[../decisions/020-doctrine-service-structural-coherence-engine|Decision 020]] — resequenced as the post-approval guardrail. All Decision 020 scope remains authoritative; only order changes.

**Deferred (build after the above lands):**
- Sukuna refactor as synthesis-service consumer
- Web UI ReviewItem dashboard
- WhatsApp / mobile / ambient adapters
- Auto-approval tiers, per-contributor profile-based synthesis tuning
- Auth on review endpoints (when non-workstation surfaces are imminent)

**Retired:**
- [[../proposed-ideas/012-drafts-as-adapter-ritual|Proposed-idea 012]] — superseded by Decision 021
- `prismo capture promote` — deprecated; will be removed once synthesis-service is the sole capture consumer
- `drafts/` folder — legacy, no new files land there
- **"Sukuna v2" as a separate Layer 2 service** — dropped. Per Decision 021, Sukuna becomes a synthesis-service consumer (scheduled passes that emit ReviewItems), not a separate service. doctrine-service inherits the metadata-reconciliation responsibilities previously assigned to Sukuna v2.

(Sukuna's 2026-05-17 audit caught a botched edit here: synthesis-service was incorrectly listed under Retired even though it is the thing that shipped as Phase 3 step 2 above. Corrected 2026-05-17.)

---

## Phase 4 — Runtime abstraction ⏳ in progress

Per roadmap: runtime provider interface, local inference, provider routing, persistent session
systems.

**Shipped (2026-05-26/28):**
- `runtime/registry.py` — CapabilityRegistry (Decision 024)
- `runtime/interfaces.py` — SynthesisProvider, EmbeddingProvider, AnalysisProvider Protocols
- `ClaudeCodeSynthesisProvider`, `ClaudeCodeAnalysisProvider` — second providers proving abstraction
- `runtime/topology.py` + `GET /runtime/topology` + `GET /runtime/roles/{id}` — live intelligence topology (Decision 025)
- Four named runtime roles: coding_runtime, synthesis_runtime, analysis_runtime, embedding_runtime (+ collaboration_runtime reserved)
- `prismo runtime topology` CLI command

**Status of Sukuna's "runtime router earlier" critique:** Resolved. Law 3 + Service Rule
(Decision 017) prevent Claude-coupling without requiring a router. Router stays in Phase 4,
to be built when there is a second runtime to route to.

**Adjacent open question (resolved — Decision 024):** whether `SynthesisProvider` and
`EmbeddingProvider` should be unified under a single `RuntimeProvider`
(see [[../decisions/015-synthesis-provider-abstraction|Decision 015]]).
Resolved: `CapabilityRegistry` pattern adopted — routes capability → provider, not monolithic
`RuntimeProvider`. See [[../decisions/024-capability-registry-phase-4-runtime-abstraction|Decision 024]].

**Remaining Phase 4 work:**
- Topology in operational state (PostgreSQL migration scope) — durable snapshots, per-ReviewItem provenance
- LiteLLM wiring inside api-mode providers
- Three-axis env var naming migration (`SYNTHESIS_ROLE_MODE` / `SYNTHESIS_ROLE_PROVIDER`)
- Two-provider completion criterion audit surface

---

## Phase 5 — Human interaction layer ⏳ partially redefined

Per roadmap: web UI, contribution capture, mobile/ambient interfaces.

**Key reframing (ChatGPT 2026-05-16):** "Layer 4 = interaction surface, not browser." A CLI
is already Layer 4 in the abstraction the masterplan defines.

Minimal Layer 4 slice now planned in parallel with Phase 3:

- `prismo brief <project>` — OperationalBrief viewer (CLI)
- `prismo capture "this matters"` — contribution capture (CLI, POSTs to `/workflow/capture`; consumed by synthesis-service per [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]])
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
