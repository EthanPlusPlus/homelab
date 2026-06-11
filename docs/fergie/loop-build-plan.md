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
  tested — 3.3M dump). Cron installed by Ethan 2026-06-10 (same install fixed
  the re-index crons that had been silently 401ing since Decision 033).
  Gate finding 2026-06-10: no alerting exists on cron failure — backup.log
  goes unwatched. Accepted-as-risk for now; revisit with observability work.
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
  (LOOP_SESSION_TOKEN_CEILING=500000 tokens/session, hard stop with
  graceful message; distinct from the 32k per-turn context floor — ceiling
  bounds cumulative spend, floor bounds assembly), input size limit (413)
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

## Phase B — Surface ✅ shipped 2026-06-10 (compaction summary moved to C)

- ✅ SSE event vocabulary live: text / tool_activity / activations /
  context_pressure / error (human-readable) / turn_complete, all `v: 1`
- ✅ Chat page at `/chat` in prismo-ui: token onboarding (localStorage, 401
  recovery), streamed turns, tool-activity indicators, activation chips,
  pressure + error banners, incomplete-turn state, end-session. Dashboard
  nav link. Dockerfile fix: NEXT_PUBLIC_* as build args (latent bug — runtime
  env never reached the client bundle).
- ✅ Session lifecycle: explicit close, idle reaper (LOOP_IDLE_TIMEOUT_HOURS=4,
  loop sessions only), context_pressure event at 70% window budget
- ✅ Per-turn pipeline integration: `loop_server/activations.py` routes every
  user turn via POST /pipeline/process; process-response async per assistant
  turn (landed in A)
- ✅ Activation stickiness: session-lifetime in operational_events, re-fetch
  on re-fire, facet block replaced never accumulated, never-blocking on
  pipeline failure, manual release endpoint
- ✅ Context assembly: fixed order (system → facets → window → message),
  char budgets, tool-result truncation, input limits.
  ⬜ → moved to Phase C: rolling compaction summary (belongs with checkpoint
  generation — same summarisation machinery)
- ✅ Verified e2e: design-flavored message → architect facet activated +
  persisted sticky → canon tools ran → grounded streamed answer

## Checkpoint quirks found in B (carry into C)

- prismo-ui calls the api service without the service API key — the ops
  dashboard relies on dev-mode/API_KEY-set-at-compose behaviour; chat page is
  unaffected (contributor tokens). Revisit when API_KEY is enforced for ui.

## Phase C — Continuity ✅ shipped 2026-06-10

- ✅ Workstream API: list (+session counts), detail (+open assumptions,
  latest checkpoint), retroactive session assignment (PATCH), no required FK
- ✅ `phase` (ideating/planning/executing, validated) + `lightweight` fields
- ✅ Checkpoints: auto-draft on session end via loop provider (structured
  extraction prompt, lenient JSON parse, graceful degradation on garbage);
  skip heuristic (<4 substantive messages); draft→reviewed lifecycle with
  human edit winning; activations recorded in fields
- ✅ Rolling compaction (resequenced from B): at 90% window pressure, older
  turns summarised into system-block slot 3; messages marked 'compacted',
  never deleted; verified keeps recent verbatim
- ✅ Workstream-scoped hydration: deterministic composition v1 (goal, phase,
  checkpoint fields, open assumptions; drafts flagged provisional).
  Interpretive brief-engine merge deferred until real multi-contributor
  checkpoint collisions exist.
- ✅ Capture subtypes: processor detects assumption/question patterns →
  disposition=open; capture_signal tool gains capture_type; PATCH capture
  gains disposition (the Decision 038 gate lever). Fixed pre-existing bug:
  processor dropped session_id, which would have silently emptied the ledger.
- ✅ `GET /workflow/workstream/:id/assumptions` — cross-session ledger
- ✅ UI: workstream picker (select/create) at session start, checkpoint
  summary on session end, unreviewed-draft banner with one-tap approve
- ✅ Identity injection ("You are speaking with {name}") — the screenshot gap
- ✅ E2E verified: checkpoint extracted decision/assumption/question
  correctly; fresh session recalled all three unaided and flagged the
  draft as provisional; model-logged assumption landed in the ledger
- ⬜ Telemetry dashboards (carried from A — still the standing remainder)

## Quirks found in C

- `docker compose restart` left api/loop with stale network DNS after the
  api container was recreated — force-recreate both when api is rebuilt.
- Service Rule check caught the four new workflow routes before first start
  (the gate doing its job on its own builder).

## Phase D — Gate ✅ shipped 2026-06-10

- ✅ `POST /workflow/workstream/:id/transition` — harness-agnostic gate,
  guards only planning→executing; lightweight bypass (recorded judgment)
- ✅ Deterministic preflight: plan_doc resolves in the index; zero open
  assumptions/questions across ALL workstream sessions (cross-contributor)
- ✅ Adversarial review: `plan_review` analysis type on analysis_runtime —
  receives ONLY plan doc + dispositioned ledger, never the conversation;
  structured findings (claim/severity/evidence); zero-findings-on-substantial
  injected as a blocking anomaly finding
- ✅ State machine via existing ReviewItem contract: review_created (409) →
  awaiting_disposition (409, no re-bill) → approved = pass / rejected =
  fresh pass on next attempt. 7 tests green.
- ✅ **First live run red-teamed this very plan: 12 findings, including two
  true positives** — the stale "cron pending" line (fixed above) and the
  undocumented token ceiling (fixed above). The gate caught its own build
  plan drifting from reality on day one.
- Deviation from D038 noted honestly: the deterministic research-citation
  check needs a structured plan-doc schema that doesn't exist yet — citation
  interrogation lives in the adversarial prompt instead. Revisit if plan
  docs gain structure.
- Deferred by design: gate-audit cadence (build when the gate first misses
  something real)

## Telemetry tail (from Phase A) ✅ 2026-06-10

- ✅ loop-server `/metrics` (instrumentator) + `loop_tokens_total` /
  `loop_turns_total` per contributor; prometheus scrape job added.
  Grafana panel: build in the UI off these series when wanted.

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
