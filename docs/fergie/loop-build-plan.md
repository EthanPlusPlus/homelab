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

## Phase A0 — Foundations ⬜

- ⬜ PostgreSQL migration of workflow-state-service (sessions, workstreams,
  session_context, operational_events) — pgvector instance already runs; add
  operational schema. SQLite fallback stays for tests (Decision 014 pattern).
- ⬜ `contributors` table + per-contributor bearer tokens (Decision 033's
  anticipated iteration). `resolve_contributor()` interface in loop-server.
- ⬜ Optimistic concurrency on workstream writes (version column)
- ⬜ Verify operational DB backup story; create dump schedule if absent
- ⬜ `messages` table schema (lands with A, designed here)

## Phase A — Core loop ⬜

- ⬜ `loop-server` service scaffold (FastAPI, compose entry, Service Rule
  registration in capability-contracts.md)
- ⬜ `LoopProvider` interface: `chat(messages, tools, stream) → normalised
  event stream`; error taxonomy (rate limit, context overflow, malformed tool
  call); incremental tool-call assembly; per-provider prompt adaptation hook
- ⬜ `AnthropicLoopProvider` (SDK, Sonnet-class)
- ⬜ `FakeProvider` — scripted record/replay for deterministic tests (also how
  the malformed-JSON retry policy is tested without burning tokens)
- ⬜ Malformed tool-call policy: bounded retries with reprompt (start: 2), then
  surface to user
- ⬜ Turn guards: max tool iterations per turn (start: 10), per-session token
  ceiling with warning before hard stop
- ⬜ Message persistence (user immediate / assistant on completion / tools as
  they land)
- ⬜ v1 tool set wired (Decision 036): read_canon, capture_signal,
  reviewitem_approval, proposed_idea_creation, workstream_create
- ⬜ **System prompt authoring** — versioned canon artifact: Prismo identity,
  canon discipline, capture awareness, tool policy, checkpoint behaviour.
  Expect iteration; this is real authoring work, not config.
- ⬜ Per-contributor token telemetry → Grafana (Decision 034 stack) + spend alerts

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
