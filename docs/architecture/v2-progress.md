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

Deliverables (all in `architecture/contracts/`, moved from `phase1/`):

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

## Phase 3 — Layer 2 maintenance intelligence ✅ complete 2026-05-30

Revised scope (Decisions 013, 017, 020, **021**): trio collapses to two services,
and the build order flips per [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]].

**Build order (current):**

1. ✅ **ReviewItem contract + endpoints** (shipped 2026-05-17) — 7 endpoints at `/review/queue` prefix in `workflow/review.py`, `review_items` table in workflow DB, 14 tests covering all flows + categorized rejection_reason enforcement. Service Rule: 35 routes documented.
2. ✅ **synthesis-service minimal** (shipped 2026-05-17) — `synthesis/` package with prompt template, four quality gates (parse, backpressure, confidence ≥ 0.7, dedup ≥ 0.85), pure-ish runner with injected I/O, `POST /synthesis/run` endpoint. 14 tests. **First live run emitted 2 ReviewItems** from pending captures (confidence 0.82 + 0.75). The Decision 021 loop is operational end-to-end. Initial thresholds env-tunable; observation week will calibrate.
3. ✅ **`prismo review` CLI** (shipped — exact date unrecorded) — `prismo review [list|show|approve|reject|edit]`. Approve writes the canon file, commits, and re-indexes. Full human-judgment loop is closed end-to-end.
4. **Observation week** — track emission rate, approval rate, rejection reasons, edit frequency, time-to-decision, dedup. Empirical tuning of synthesis-service quality gate. No canon closure record exists yet.
5. ✅ **doctrine-service Day-1 capabilities** per [[../decisions/020-doctrine-service-structural-coherence-engine|Decision 020]] — **complete 2026-05-30.** `doctrine/rules.py`: pure rule evaluators for `validate_metadata`, `validate_supersession`, `validate_provenance`, `resolve_relationships`, `build_supersession_graph`. `doctrine/router.py`: 5 endpoints (`/doctrine/validate`, `/doctrine/supersession`, `/doctrine/provenance`, `/doctrine/relationships`, `/doctrine/graph`). `tests/test_doctrine.py`: 29 tests green. MCP tools for all 5 endpoints (34 total). `prismo doctrine validate|supersession|provenance|relationships|graph` CLI. Service Rule: 51 routes, all documented.

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

## Phase 4 — Runtime abstraction ✅ complete 2026-05-31

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

**Shipped (2026-05-29):**
- PostgreSQL + pgvector migration — replaces ChromaDB (docs + code_symbols) and both SQLite DBs (workflow.db + code_graph.db) with a single PostgreSQL instance. `db/postgres.py`: `VectorStore` (ChromaDB-compatible interface backed by pgvector HNSW), `PgConn` (sqlite3-compatible wrapper for workflow callers), `init_pg_schema()` (idempotent, creates all tables). `workflow/db.py` delegates to PostgreSQL when `DATABASE_URL` is set, SQLite fallback otherwise (tests unaffected). `docker-compose.yml` uses `pgvector/pgvector:pg16`; `chroma_store` volume removed.
- `runtime_topology_snapshots` table — `snapshot_topology()` writes on API startup. Closes Decision 025's "topology in operational state" gap. Durable before-after audit trail before per-ReviewItem provenance is wired.
- `produced_by_role` column on `review_items` — in schema, ready for synthesis-service to populate. **Wired 2026-05-30** — `ReviewItemCreate.produced_by_role` field added; synthesis runner sets `"synthesis_runtime"` on every emission.

**Shipped (2026-05-30):**
- [[../decisions/026-layer-3-5-pipeline-service|Decision 026]] — Layer 3.5 Pipeline Service: Activation Router, Context Assembler, Response Processor. Generic `Activation` interface (FACET, SEQUENCE, MEMORY_PACK, CONSTRAINT, TOOLSET). Two-stage routing, scored `ActivationMatch[]`, `POST /pipeline/process` + `POST /pipeline/activate` + `GET /pipeline/activations`. `architect/facet.yaml` + thin `SKILL.md` + `README.md`. UserPromptSubmit hook wired. 25 tests green. Proposed-idea 015 superseded.
- [[../decisions/027-observation-week-closure|Decision 027]] — Observation week closed. Findings: confidence/dedup thresholds appropriate; `wrong-artifact-type` dominated rejections (synthesis prompt issue, not gate issue). Doctrine-service Day-1 and proposed-idea 013 unblocked.
- [[../decisions/028-response-processor-auto-capture|Decision 028]] — Response Processor auto-creates captures from model output (elegant automation). Pattern-based detection, max 3/response, `source=response_processor`. Human judgment at ReviewItem level (Decision 021 unchanged). `POST /pipeline/process-response` endpoint reserved; Claude Code hook wiring deferred to Phase 5 (avoids transcript-format coupling).
- [[../decisions/029-collaboration-runtime-authority|Decision 029]] — `collaboration_runtime` authority set: `read_canon`, `capture_signal`, `reviewitem_approval`, `proposed_idea_creation`. Not: `canon_authoring`, `synthesis_invocation`, `analysis_invocation`. RBAC deferred to real friction.
- Proposed-idea 016 — `routing_runtime` (Haiku-class model to replace embedding Stage 2). `routing_runtime` reserved slot in topology.
- Three-axis env var migration: `SYNTHESIS_ROLE_MODE` / `SYNTHESIS_ROLE_PROVIDER` supported in `_resolve_role` (legacy `SYNTHESIS_PROVIDER` as fallback).
- `collaboration_runtime` + `routing_runtime` reserved slots in `topology.py`.
- `pipeline/processor.py` built — pattern-based capture detection, auto-creates captures via `workflow.db`.
- Context-server component canon updated (was frozen at 2026-05-13).
- 12 Sukuna 2026-05-30 findings actioned (typos, status fixes, annotations, stale references).

**Shipped (2026-05-30, continued):**
- `migrate`, `sukuna`, `review` Facets — `facet.yaml` definitions in `scripts/facets/`. All 4 facets registered at runtime (architect + 3 new). Activation examples, keywords, context loaders, and heuristics defined for each.
- `produced_by_role` wired — `ReviewItemCreate` model + INSERT updated; synthesis runner sets `"synthesis_runtime"` on every emission.

**Shipped (2026-05-31):**
- [[../decisions/030-billing-architecture-intelligence-tiers|Decision 030]] — billing architecture locked: subscription for coding_runtime, LiteLLM for side intelligences (synthesis_runtime, analysis_runtime).
- LiteLLM wired into `AnthropicSynthesisProvider` — raw anthropic SDK replaced with `litellm.completion()`. Model string-swappable via `SYNTHESIS_MODEL` env var. `AnthropicAnalysisProvider` stays on raw SDK (Anthropic beta web_search tool not supported by LiteLLM). `litellm` added to requirements.txt.
- Two-provider completion criterion met — `ClaudeCodeSynthesisProvider` + `AnthropicSynthesisProvider` (LiteLLM) satisfy Decision 024 audit surface.
- `prismo pipeline capture-response` — Stop hook wired in `settings.json`. Reads `transcript_path` from hook JSON, extracts last assistant text, POSTs to `/pipeline/process-response`. Closes Decision 028 Phase 5 hook wiring.
- `processor.py` bugfix — `contributor_id='system'` set on auto-captures (was silently failing NOT NULL constraint).
- Proposed-idea 013 closed as superseded by Decision 026 + 028.
- Proposed-idea 017 written — Capability Orchestrator (meta-router, future).
- doctrine-service Day-1 complete:
  - `detect_supersession_cycles()` — DFS cycle detection over superseded_by graph
  - `detect_source_hash_drift()` — pure function, compares stored hashes vs current content; indexer stores `source_hashes` as JSON from frontmatter
  - `GET /doctrine/validate` expanded to run all rules (metadata + supersession + cycles + provenance + drift)
  - `GET /doctrine/supersession` + `/doctrine/provenance` include new violations
  - 43 tests green
- Canon repairs: 11 decisions missing frontmatter (005/007/010/012-019 — predated convention), 2 broken supersession chains (short-form IDs), `deprioritised` → `closed` on 011, draft captures `pending-review` → `archived`. Doctrine validate: 0/102 violations.
- `duplicate_id` rule fixed — now scoped within category (decisions and proposed-ideas have independent numbering).

## Phase 4 ✅ complete 2026-05-31

---

## Phase 5 — Human interaction layer ⏳ in progress

Per roadmap: web UI, contribution capture, mobile/ambient interfaces.

**Key reframing (ChatGPT 2026-05-16):** "Layer 4 = interaction surface, not browser." A CLI
is already Layer 4 in the abstraction the masterplan defines.

**Forcing function reframing ([[../decisions/031-web-ui-operational-visibility-forcing-function|Decision 031]], 2026-05-31):**
Web UI no longer waits on collaborator readiness. The system (Phases 0–4 complete, 30+
decisions, 50+ routes, 4 services) is large enough that coherent visual state is a
builder-visibility need independent of Shrey/Kyle. All first-slice data exists in the API today.

**CLI Layer 4 (shipped — Phases 2.5/3):**
- `prismo brief <project>` — OperationalBrief viewer
- `prismo capture / review / stale / synth / metrics / doctrine / pipeline` — full surface

**Web UI — first slice: minimal ops dashboard ✅ shipped 2026-05-31**

Stack: Next.js 15 / TypeScript / Tailwind / shadcn/ui, consuming existing FastAPI API directly.
Auth: Tailscale-gated (zero new infrastructure). Deployed at port 3000 via docker-compose.

| Panel | Endpoint |
|-------|----------|
| ReviewItem queue | `GET /review/queue` |
| Synthesis metrics | `GET /workflow/metrics` |
| Doctrine health | `GET /doctrine/validate` |
| Runtime topology | `GET /runtime/topology` |
| Stale items | `GET /workflow/stale-items` |
| Pipeline activations | `GET /pipeline/activations` |
| Capture list | `GET /workflow/captures` |

**Web UI — second slice (deferred):**
Conversation, contribution capture, RBAC, multi-user — when Shrey/Kyle need access.

**Agentic loop — primary harness ⏳ designed 2026-06-09, build not started**

The biggest Phase 5 build and the realisation of the masterplan's "runtime
abstraction" milestone: Prismo's primary interaction surface becomes a harness
Prismo owns. Fully designed across 2026-06-07 → 2026-06-09 sessions; PI-006
promoted into three decisions:

- [[../decisions/036-loop-runtime-role-contract-billing|Decision 036]] —
  `loop_runtime` role (absorbs collaboration_runtime), tool-set-as-authority,
  capability contract, local-first execution strategy, api billing with
  guardrails, per-contributor bearer tokens (Decision 033 iteration)
- [[../decisions/037-loop-conversation-continuity|Decision 037]] — Message
  object, stored-transcript/assembled-context split, session cycling over
  workstreams with structured checkpoints, workstream-scoped hydration,
  activation stickiness
- [[../decisions/038-workstream-phase-gate|Decision 038]] — shift-left QA:
  deterministic preflight + adversarial fresh-eyes review + human disposition
  on planning→executing transitions

Multi-user is v1 scope (executive decision). Build phases A0–E tracked in
`../fergie/loop-build-plan.md` — detail lives there, not here. Supersedes the
"second slice" framing above: the loop IS the conversational surface.

---

## Phase 6 — Governance and observability ⏳ parallel with Phase 5

Per Decision 031: Phase 6 infra observability (Prometheus / Grafana / Loki) runs as a
background track alongside Phase 5, not after it. Service metrics and Docker log aggregation
added incrementally; the web UI is the primary visibility layer.

**Architecture locked ([[../decisions/034-phase-6-observability-layer|Decision 034]], 2026-06-05):**
Hard boundary: Prometheus owns infra health; `GET /workflow/metrics` + web UI own cognitive
health. Cognitive alerting via Prometheus is a Law 1/Law 2 violation — out of scope.

**Phase 6 slice 1 build spec:**
- `prometheus-fastapi-instrumentator` → `/metrics` on context-server (no domain coupling)
- `prom/prometheus` + `grafana/loki` + `grafana/promtail` + `grafana/grafana` in docker-compose
- Config files committed under `context-server/observability/` — portable, no manual setup
- Grafana at port 3001; starter dashboard: request rate, latency p50/p95/p99, error rate, log stream
- Alert rules (Grafana only, no Alertmanager): service down >2m, error rate >5%, p99 >2s
- **Shipped 2026-06-05.** Deploy: `docker compose up --build -d` from `context-server/`. Grafana at `:3001`, Prometheus at `:9090`.
- **Hardened 2026-06-07.** `noDataState: OK` on `prismo-api-down` alert rule — fixed false-positive 6am alerts caused by Prometheus cold-start NoData state.

**Harness portability ([[../decisions/035-harness-adapter-pattern|Decision 035]], 2026-06-07):**
Finding: system is more portable than assumed. Session identity is Prismo-generated (not sourced from Claude Code). Only harness-specific code is `capture-response` (~20 lines, JSONL transcript parsing). Three-endpoint normalised interface defined: `POST /workflow/session/start`, `POST /pipeline/process-response`, `POST /workflow/session/:id/end`. Claude Code adapter retroactively named; conversational UI adapter defined (three direct HTTP calls, no CLI dependency).

**POST /chat endpoint (2026-06-07):**
Natural language queries against live system state. `analysis_runtime` (Anthropic Sonnet via ANALYSIS_MODEL). Returns grounded response + context counts. Does not take actions — directs to CLI. `chat/router.py` + `tests/test_chat.py` (9 tests). Registered in `capability-contracts.md` as `conversationalQuery` capability.

**doctrine-service: detect_broken_xrefs() (PI-021, 2026-06-07):**
Cross-reference integrity as a Law 1 rule. `detect_broken_xrefs(all_docs, current_contents)` in `doctrine/rules.py`. Exposed via `GET /doctrine/xrefs` and included in `GET /doctrine/validate`. 12 tests. Part of Sukuna structural distillation — first structural Sukuna check fully mechanised.

## Phase 7 — Advanced research ⏳ not started

---

## How to update this doc

- Mark phase status with ✅ / ⏳ / ⚠️
- Link to decision records, audit files, and source modules — do not paste content
- Sukuna passes inform this doc, but Sukuna does not write it (drafts-only constraint applies)
- When a phase completes, write the closing decision record first, then update this index
