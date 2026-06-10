---
record_type: canonical
title: Agentic loop build plan — phases A0–E
date: 2026-06-09
status: active
category: architecture
---

# Agentic Loop Build Plan

Implementation tracking for Decisions
[[../decisions/036-loop-runtime-role-contract-billing|036]] /
[[../decisions/037-loop-conversation-continuity|037]] /
[[../decisions/038-workstream-phase-gate|038]].
Each phase is independently shippable. Telemetry from phase A onward.

Status legend: ⬜ not started · ⏳ in progress · ✅ done

---

## Phase A0 — Foundations ✅ 2026-06-10

- ✅ PostgreSQL migration of workflow-state-service — **was already done**
  (2026-05-29 pgvector migration covered workflow.db; verified live).
  SQLite fallback intact for tests.
- ✅ `contributors` table + per-contributor bearer tokens —
  `loop_server/identity.py` (create/list/revoke CLI, sha256 hashes,
  `resolve_contributor()` seam)
- ✅ Optimistic concurrency on workstream writes — `version` column,
  `expected_version` on PATCH, 409 with current_version on conflict. Also
  fixed positional INSERT that the new column would have broken.
- ✅ Backup: `scripts/pg-backup.sh` (nightly pg_dump, 14-day retention,
  tested — 3.3M dump). **Cron install pending Ethan** (`crontab /tmp/crontab.proposed`,
  which also fixes the re-index crons that have been silently 401ing since
  Decision 033 deployed — found during this build).
- ✅ `messages` table (+ embedding-backlog partial index)

## Phase A — Core loop ✅ core shipped 2026-06-10 (telemetry dashboards remain)

- ✅ `loop-server` service: `loop_server/` module, compose service on port
  8002, routes documented in capability-contracts.md
- ✅ `LoopProvider` interface (`providers/base.py`): normalised event
  vocabulary (text / tool_call / turn_end), error taxonomy (RateLimited /
  Overloaded / ContextOverflow / MalformedToolCall), prompt-adaptation hook
- ✅ `AnthropicLoopProvider` — async streaming, in-provider tool-call assembly
- ✅ `FakeProvider` — scripted turns + raisable errors, records chat() inputs
- ✅ Malformed tool-call policy — 2 bounded reprompt retries, then surfaced
- ✅ Turn guards — LOOP_MAX_TOOL_ITERATIONS=10, session token ceiling
  (LOOP_SESSION_TOKEN_CEILING), input size limit (413)
- ✅ Message persistence with crash semantics (user immediate, assistant on
  completion, `turn_status` marks incompletes) + char-budget recent window +
  tool-result truncation (2k, re-fetchable)
- ✅ v1 tool set — 9 tools mapping the 5 authorities; reject/approve/capture
  request shapes verified against the live API
- ✅ System prompt v1 — `loop_server/prompts/system.md` (identity, grounding
  discipline, judgment boundary, capture awareness). Iteration expected.
- ✅ Token recording per turn (`loop_tokens` operational_events, per session)
  · ⬜ Grafana panel + spend alerts on top of it (Decision 034 stack)
- ✅ 8 engine tests green (FakeProvider, SQLite); existing suite unaffected
  (13 pre-existing env-dependent failures on master, verified by baseline run)
- ✅ **Live smoke test passed**: real turn → search_canon tool call → grounded
  streamed answer → persisted messages → session ended via adapter calls

Early Phase B items that landed with A: versioned SSE events incl.
tool_activity (no dead air) and human-readable errors; session start/end
endpoints; async fire-and-forget process-response per turn.

## Phase B — Surface ⬜

- ⬜ SSE event protocol spec: versioned events from day one; text deltas,
  **tool-activity events** (no dead air during chains), error events
  (human-readable for non-technical users — never stack traces), checkpoint
  prompts
- ⬜ Chat page in prismo-ui → loop-server
- ⬜ Session lifecycle: explicit close, idle timeout, context-pressure prompt
  (~70% budget: checkpoint or compact)
- ⬜ Per-turn pipeline integration: `POST /pipeline/process` on user turns
  (activation routing), `POST /pipeline/process-response` async fire-and-forget
  on assistant turns (concatenated assistant text only, tool payloads excluded)
- ⬜ Context assembly per Decision 037 (fixed order, stable prefix, 32k floor,
  char-based compaction trigger, tool-result truncation, input size limits)
- ⬜ Activation stickiness: session-lifetime, manual release, re-fetch on
  re-fire
- ⬜ Token paste onboarding flow (one-time, localStorage)

## Phase C — Continuity ⬜

- ⬜ Workstream API (PI-020 surface): start/end/list/detail, retroactive
  session assignment, no required FK
- ⬜ `phase` + `lightweight` fields (Decision 038)
- ⬜ Checkpoint generation: structured fields (decisions / assumptions / open
  questions / next steps / active activations); auto-draft + async review;
  skip heuristic for trivial sessions; clean turn boundaries only
- ⬜ Workstream-scoped hydration: brief engine extension (Decision 018
  provenance), regenerate on checkpoint write, cached between
- ⬜ Assumption/question capture subtypes with disposition lifecycle
  (open/validated/accepted-as-risk) — response processor detection patterns
  (Decision 028 extension)
- ⬜ `GET /workflow/workstream/:id/assumptions` + UI panel
- ⬜ Unreviewed-checkpoint banner on next workstream visit

## Phase D — Gate ⬜

- ⬜ `POST /workflow/workstream/:id/transition` with gate evaluation
  (harness-agnostic, Layer 2)
- ⬜ Deterministic preflight: plan doc resolves, zero open
  assumptions/questions across ALL workstream sessions, research citations on
  external deps. Items reference artifacts that resolve — no booleans.
- ⬜ Adversarial review: analysis_runtime, artifacts only (never the planning
  conversation), structured findings (claim/severity/evidence);
  zero-findings-on-nontrivial = blocking anomaly
- ⬜ Findings → ReviewItems (existing contract)
- Deferred by design: gate-audit cadence (build when the gate first misses
  something real)

## Phase E — Local provider ⬜

- ⬜ `OllamaLoopProvider` against the LoopProvider interface
- **Blocker (verified in context/progress.md):** VM RAM upgrade to 32GB is the
  named prerequisite for Ollama. Until then, provider development tests against
  FakeProvider; live local validation waits on hardware.
- ⬜ Tool-use validation on target model (Qwen-class 32B+ is the 2026-06
  reliability floor; smaller models only validate plumbing, not quality)
- ⬜ Telemetry review → hardware sizing input (the abundance-mindset purchase
  is data-driven: measured tokens/turn, context distribution, tool-call rates)
- ⬜ Nightly embedding batch job over eligible messages (substantive assistant
  turns, checkpoints, capture-linked) — retrieval stays off until designed

## After the loop ships (tracked, not scheduled)

- OpenCode adapter for coding_runtime (HTTP API from Python, not the TS SDK;
  custom tool definitions can expose Prismo endpoints natively to the coding
  agent) — removes the last subscription dependency
- WhatsApp gateway as the next loop surface (masterplan: meet Shrey/Kyle where
  they are)
- Semantic retrieval over conversation history (flag-flip per Decision 037)
- PI-022 model routing policy — trigger conditions in the PI
- LiteLLM wiring for synthesis/analysis providers (Decision 030 remainder,
  backseated 2026-06-09)
- Per-contributor tool sets (RBAC within loop_runtime) — trigger: real
  authority conflict between contributors

---

## Settled-position ledger (design sessions 2026-06-07 → 2026-06-09)

Single model v1 (Sonnet-class, no Haiku, no routing) · local-first direction
with API permanently first-class · `claude -p` rejected as loop engine ·
separate loop-server service · multi-user v1 (executive decision) ·
per-contributor bearer tokens, never network-topology identity (Decision 033
conflict caught in design) · tool-set-as-authority · loop_runtime absorbs
collaboration_runtime · one new object type (Message) · assumptions are capture
subtypes · session cycling primary, compaction fallback · checkpoint = judgment
artifact decoupled from window size · activations sticky, phase adds never
removes · shared sessions out of scope v1 · embedding batched off the hot
path · 32k context design floor · gate = deterministic preflight + fresh-eyes
adversarial review + human disposition.
