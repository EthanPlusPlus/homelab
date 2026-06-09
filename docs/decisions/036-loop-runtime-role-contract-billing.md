---
record_type: canonical
id: "036"
title: loop_runtime — role, capability contract, and billing
date: 2026-06-09
status: active
category: architecture
supersedes: []
superseded_by: []
---

# Decision 036 — loop_runtime: role, capability contract, and billing

## Status

Adopted. Designed across the 2026-06-07 → 2026-06-09 agentic loop planning sessions
(PI-006 promotion). Implementation tracked in `fergie/loop-build-plan.md`.

## Context

PI-006 reframed the agentic loop as Prismo's **primary interaction harness** — the
surface where real work happens (ideation, planning, triage, conversation-driven
action), not an ambient companion to Claude Code. Decision 025 requires new
intelligence to have a named runtime role before implementation. Decision 030
locked subscription billing for the "main intelligence" without anticipating a
second primary role. Both gaps had to close before design could proceed.

Two further questions surfaced during design:

1. Decision 025 reserved a `collaboration_runtime` slot for non-technical
   contributors (Decision 029 set its authority). The loop serves *everyone* with
   the same cognitive responsibility — are these two roles or one?
2. What makes the role swappable, given its capability surface is far wider than
   synthesis/analysis?

## Decision

### The role

```
loop_runtime
  role:       Multi-turn conversational harness — Prismo's primary interaction
              surface. Owns conversation state, per-turn activation routing,
              per-response processing, and session lifecycle. Heaviest adapter
              against the Decision 035 normalised interface.
  mode:       api (pay-per-token). Local-first direction — see execution strategy.
  provider:   Anthropic Sonnet-class (v1, single model — no complexity routing).
  authority:  Defined by the tool set passed at session init (see below).
  scope:      Prismo API surface only. No filesystem access, no direct OS access,
              no canon writes outside the ReviewItem boundary.
```

### loop_runtime absorbs collaboration_runtime

Decision 025 defines roles by cognitive responsibility. "Conversational primary
interface" is one responsibility regardless of who is talking. The reserved
`collaboration_runtime` slot is superseded by `loop_runtime`; Decision 029's
authority set transfers as the loop's v1 tool set. Keeping both roles would
reintroduce the role/authority conflation Decision 025 was written to eliminate.

### Tool-set-as-authority

The model is given Prismo API endpoints as native tool definitions. **The tool
list passed at session init IS the authority boundary** — no abstract permission
layer. v1 tool set (all contributors, no RBAC):

- `read_canon` (search/query canon, project state)
- `capture_signal`
- `reviewitem_approval`
- `proposed_idea_creation`
- `workstream_create` (added by this decision — see Decision 029 annotation)

Not granted v1: synthesis invocation, analysis invocation, workflow admin, canon
authoring. Operational actions beyond the tool set happen in the web UI/CLI.
When RBAC becomes a real need, per-contributor tool sets differentiate *within*
the role — the loop architecture does not change.

### Capability contract (the swappability criterion)

Any model fills this slot if it provides:

1. **Structured tool use** — reliable multi-step function calling
2. **Multi-turn message history** with coherent context across turns
3. **Context window ≥ 32k tokens** — also the design floor for context assembly
   regardless of provider (forces compaction discipline, makes local swap a
   non-event)
4. **Natural language output** parseable by `POST /pipeline/process-response`

These are measurable. A substitute is validated by running the FakeProvider test
suite plus a live tool-chain validation, not by judgment.

### Execution strategy — local-first, API permanently first-class

Built for local as the primary direction (executive decision, 2026-06-09):

- **Provider abstraction from day one**: `LoopProvider` interface; Anthropic SDK
  and Ollama implementations; normalised streaming and incremental tool-call
  assembly; per-provider prompt adaptation hook; FakeProvider for deterministic
  tests.
- **API is not a temporary scaffold.** It stays first-class forever — it is how
  the loop rides frontier models while local catches up.
- **Local adoption ladder**: side intelligences (synthesis, Sukuna passes)
  migrate to local first — bounded, low-stakes, measurable. The loop migrates
  last, when local models prove out on easier roles. Qwen-class 32B+ is the
  current floor for reliable local tool calling (2026-06 research).
- **Telemetry is the buy signal**: per-turn tokens, context sizes, tool-call
  rates measured from day one. Hardware purchase happens when data says a spec
  pays for itself.
- `claude -p` as a loop engine is rejected — no proper multi-turn state, no tool
  definition control, brittle to CLI changes.

### Billing

Decision 030's subscription commitment is scoped to `coding_runtime` only (see
annotation there). `loop_runtime` bills api pay-per-token with mandatory
guardrails: per-contributor token telemetry into the existing observability
stack (Decision 034), spend alerts, max tool iterations per turn, per-session
token ceiling. LiteLLM wiring (Phase 4 remainder) is explicitly backseated —
not abandoned.

### Identity — per-contributor bearer tokens

Multi-user is v1 scope. Contributor identity uses per-contributor bearer tokens —
the iteration Decision 033 explicitly anticipated ("per-client keys are a future
iteration when Shrey/Kyle are active contributors"). A `contributors` table holds
token hashes; the loop-server resolves token → contributor behind a
`resolve_contributor()` interface.

**Network topology is not identity.** A tailnet-identity approach was considered
and rejected — Decision 033 forbids the auth layer knowing about network
topology, and the conflict was caught by checking canon before building.
Tailscale remains transport-level defense in depth only.

**Accepted risk (recorded):** loop-server holds one service API key to
context-server and enforces per-contributor tool sets itself. Compromise of
loop-server = full API authority. Acceptable inside the tailnet at current
scale; first thing RBAC-era work revisits.

### Deployment shape

Separate `loop-server` service (not a context-server module): it holds long-lived
SSE connections — a different scaling and restart profile — and a conversation
engine inside context-server feeds the Layer-2-sprawl risk the masterplan warns
about. Service Rule applies: every endpoint documented in capability-contracts.md
from day one. The chat surface ships as a page in prismo-ui talking to
loop-server.

## Rationale

- Decision 025 demands named roles; the loop is the largest unregistered
  intelligence Prismo has contemplated
- Tool-set-as-authority makes the authority boundary enforceable and auditable
  in one place, and makes future RBAC a tool-list concern instead of an
  architecture change
- Local-first with API-first-class resolves the "invested too deep in API" fear
  and the "fall behind waiting for local" fear with the same mechanism
- The capability contract turns "swappable" from aspiration into a test

## Consequences

- Runtime topology gains `loop_runtime`; `collaboration_runtime` slot retired
  (Decision 025 annotation)
- Decision 029 authority set becomes the loop v1 tool set + `workstream_create`
  (Decision 029 annotation)
- Decision 030 scope narrowed (annotation)
- New service `loop-server` enters the compose stack; endpoints documented per
  Service Rule
- `POST /chat` survives as a lightweight state-query endpoint; it is not the
  loop and never was the foundation for it (PI-006)
- Model routing policy (complexity routing between models within the role) is
  explicitly deferred — see PI-022

## Related

- [[../proposed-ideas/006-mobile-gateway|PI-006]] — promoted into this decision (+ 037, 038)
- [[025-runtime-intelligence-layer-topology|Decision 025]] — role registry this extends
- [[029-collaboration-runtime-authority|Decision 029]] — authority set inherited as v1 tool set
- [[030-billing-architecture-intelligence-tiers|Decision 030]] — billing scope narrowed
- [[033-api-key-auth-layer|Decision 033]] — identity model extends its anticipated iteration
- [[035-harness-adapter-pattern|Decision 035]] — the loop is the heaviest adapter against its interface
- [[037-loop-conversation-continuity|Decision 037]] — conversation/memory model
- [[038-workstream-phase-gate|Decision 038]] — shift-left QA gate
- [[../proposed-ideas/022-loop-model-routing-policy|PI-022]] — deferred routing axis
