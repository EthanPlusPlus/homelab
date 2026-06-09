---
id: "025"
title: Runtime Intelligence Layer — topology, roles, and execution modes
status: active
record_type: canonical
category: architecture
date: 2026-05-28
---

# Decision 025 — Runtime Intelligence Layer: topology, roles, and execution modes

## Status
Adopted

> **Annotation 2026-06-09 — Decision 036:** A fifth runtime role is registered:
> `loop_runtime` (multi-turn conversational harness, Prismo's primary interaction
> surface). The reserved `collaboration_runtime` slot (registered in
> `runtime/topology.py`, authority set by Decision 029) is superseded by merge
> into `loop_runtime` — same cognitive responsibility, one role. Decision 036
> also defers a structural extension this decision does not yet model: a
> **routing policy** axis between role and provider (per-turn model selection
> within one role). The three-axis model stands until PI-022 is built; when it
> is, this decision gains the fourth axis explicitly.

## Date
2026-05-28

## Context

Decision 024 established the CapabilityRegistry and proved the provider abstraction with two
working implementations. It solved "how do we swap providers." It did not solve "how do we
govern, observe, and reason about the intelligence running across the system."

By 2026-05-28, Prismo has:
- A main intelligence (the AI the human talks to — currently Claude Code)
- Multiple side intelligences (synthesis-service, analysis-provider, embedding)
- Multiple execution modes (API, subscription CLI, local on roadmap)
- No unified view of what intelligence is deployed where, at what cost, with what authority

Configuration is scattered across env vars (`SYNTHESIS_PROVIDER`, `ANALYSIS_PROVIDER`,
`SYNTHESIS_MODEL`). There is no way to observe the full intelligence topology. There is no
governance layer defining what each runtime is permitted to do.

The deeper problem: Decision 024's CapabilityRegistry conflates three distinct concepts.
`SYNTHESIS_PROVIDER=claude-code` simultaneously declares the *role* (synthesis), the
*execution mode* (subscription CLI), and the *provider* (Anthropic). These are not the
same thing. Conflating them produces hidden coupling that will become painful as Prismo
adds more runtimes.

The session that produced this decision also surfaced the correct framing:

> Prismo is not calling AI. Prismo is orchestrating an intelligence topology.

## Decision

### Separate three concepts that Decision 024 conflated

| Concept | Definition |
|---|---|
| **Runtime Role** | The cognitive responsibility that exists in the system — what work this intelligence does |
| **Execution Mode** | How the cognition executes economically and operationally |
| **Provider** | Which vendor or implementation fulfills the role in the current deployment |

These are independent axes. A synthesis_role can run in api mode via Anthropic, or in
subscription_cli mode via Claude Code, or in local mode via Ollama. Changing the execution
mode does not change the role. Changing the provider does not change the role or mode.

### Define the four execution modes

**Mode 1 — api**: Calls a REST endpoint with an API key. Pay-per-token. Provider-agnostic
via LiteLLM normalization. Covers Anthropic, OpenAI, Google, Mistral, and any OpenAI-compatible
endpoint. Variable cost.

**Mode 2 — subscription_cli**: Spawns a first-party binary authenticated to a subscription.
`claude -p` today. Flat monthly cost. Model is whatever the subscription provides. This is the
current default for synthesis and analysis. Zero surprise billing.

**Mode 3 — local**: Runs a model process on Prismo's own hardware. Ollama, llama.cpp, MLX.
Zero marginal cost. Hardware-limited. Latency depends on local resources. Privacy-preserving.
Primary path 12–18 months out as model quality continues to close the gap.

**Mode 4 — agentic**: Submits a task with tools to a provider that runs an autonomous loop
and returns an outcome. Billed per task or per outcome, not per token. Emerging frontier —
Anthropic extended thinking, OpenAI deep research, future agent APIs.

### Name the runtime roles

Runtime roles are named slots in the intelligence topology. Current roles:

- **coding_runtime**: The main intelligence. The AI the human is actively talking to.
  Currently occupied by Claude Code (subscription_cli, Anthropic). Not hardcoded — this is
  a role, not an identity. Claude currently occupies this slot.
- **synthesis_runtime**: Generates ReviewItems from captures. Bounded, non-recursive,
  quality-gated. Currently subscription_cli.
- **analysis_runtime**: Interpretive augmentation with tool use and web search. Currently
  subscription_cli. Also powers `POST /chat` (Decision 035) — natural language queries
  against live system state, using Anthropic SDK directly (ANALYSIS_MODEL env var).
- **embedding_runtime**: Dense vector embeddings for semantic retrieval. Currently local
  (sentence-transformers).

New intelligence added to Prismo must be assigned a named runtime role before implementation.
Unregistered intelligence is not permitted.

### Introduce Capability Contracts

> **Terminology note (2026-05-30):** "Capability Contracts" in this decision means the
> tags a runtime role advertises (`supports_tool_use`, `low_latency`, etc.). This is
> distinct from `architecture/contracts/capability-contracts.md` (now titled "Service
> Contracts"), which defines HTTP interface contracts between layers. Two different
> concepts, same original name. Read this section as "Runtime Capability Tags."

Each runtime role advertises the capabilities it exposes. This is how the orchestration layer
routes tasks without hard-coding provider assumptions.

Examples:
- `supports_tool_use` — can invoke external tools during execution
- `supports_web_search` — has access to live web search
- `deterministic_json` — reliably produces structured JSON output
- `low_latency` — suitable for synchronous user-facing paths
- `long_context` — handles large context windows without degradation
- `deep_reasoning` — appropriate for complex multi-step analysis

The CapabilityRegistry from Decision 024 becomes the place where these contracts are
declared alongside provider registration.

### Introduce Authority boundaries

Each runtime role has an explicit authority boundary — what it is permitted to do, not just
what it is capable of doing.

Examples:
- `coding_runtime`: canon authoring, synthesis invocation, full tool access
- `synthesis_runtime`: ReviewItem generation only — cannot write canon, cannot invoke other runtimes
- `analysis_runtime`: web search, ReviewItem generation — cannot write canon
- `embedding_runtime`: read-only — encode only, no write operations

Authority is enforced at the architectural level (synthesis-service has no canon volume mount,
cannot call workflow endpoints that write). It is documented here as the governance record.

### The runtime registry lives in operational state

The runtime topology is not a config file. It lives in the same SQLite (soon PostgreSQL)
operational state as sessions, captures, and review items. This makes it:
- Observable at runtime via API
- Queryable for audit (`which runtime touched this ReviewItem?`)
- Changeable without editing files
- A first-class operational artifact, not deployment configuration

The full topology — roles, current providers, execution modes, capability contracts,
authority boundaries — is inspectable via `GET /runtime/topology`.

> **Implementation note (2026-05-28):** `GET /runtime/topology` and `GET /runtime/roles/{id}`
> were built in the same session this decision was written. See `runtime/router.py` and
> `runtime/topology.py`. The current implementation builds the topology from env vars at
> query time (env-var mirror). The "topology in operational state" goal — durable snapshots,
> per-ReviewItem provenance — is the next step, scoped to the PostgreSQL migration.

## Rationale

**Why separate Role, Mode, Provider.** Provider transitions are inevitable (Anthropic →
OpenAI, API → local). Execution mode transitions are also inevitable (subscription_cli →
local as hardware matures). If role and mode and provider are conflated, every transition
requires reasoning about all three simultaneously. Keeping them separate means: changing
the model requires changing only the provider config, changing the billing model requires
changing only the execution mode, and the role — the cognitive contract — never changes.

**Why name runtime roles before implementation.** Most agent systems fail by accumulating
hidden model calls — invisible costs, fragmented cognition, unpredictable operational semantics.
Naming a role before implementing it is the forcing function that prevents this. If you cannot
name the role, the intelligence should not exist.

**Why authority boundaries.** Prismo's synthesis-service must never become an autonomous
agent that rewrites canon or invokes other agents without human review. Authority boundaries
are the architectural expression of Decision 021's human-judgment principle applied to the
intelligence layer specifically.

**Why operational state over config files.** Env vars are write-once and invisible at runtime.
A topology in operational state can be queried, diffed over time, and audited. When a
ReviewItem is generated, the system should be able to answer: which runtime role produced it,
what execution mode was it using, what model, at what cost.

**Why the main intelligence is a managed role.** The worst outcome for Prismo's architecture
is:
> "Prismo is Claude."

Claude currently occupies the coding_runtime slot. That slot could be occupied by GPT, a
local model, or a future runtime. Making it a named role instead of an assumed identity is
the enforcement mechanism for this.

## Immediate consequences

- The env var naming convention changes from `SYNTHESIS_PROVIDER=claude-code` to a
  three-axis config: `SYNTHESIS_ROLE_MODE=subscription_cli`, `SYNTHESIS_ROLE_PROVIDER=anthropic`.
  This is a migration, not a breaking change — old env vars are supported until deprecated.
- `GET /runtime/topology` was built in the same session as this decision (see implementation
  note above). The Layer 3 build gate it set has been cleared.
- Every new intelligence added to Prismo requires a named role entry in the runtime registry
  before implementation begins.
- LiteLLM is the internal implementation detail for `mode=api` providers. It is not a
  foundational dependency — it lives inside the provider implementation, not at the interface layer.

## What this does NOT change

- The CapabilityRegistry from Decision 024 remains. This decision adds structure above it.
- The existing provider implementations (AnthropicSynthesisProvider, ClaudeCodeSynthesisProvider,
  AnthropicAnalysisProvider, ClaudeCodeAnalysisProvider) remain valid. They are renamed and
  re-registered under the new role/mode/provider taxonomy.
- The human-judgment boundary from Decision 021 is unchanged.
- The synthesis quality gates from Decision 021/023 are unchanged.

## Related

- [[024-capability-registry-phase-4-runtime-abstraction]] — this decision extends and
  supersedes the topology aspects of 024
- [[015-synthesis-provider-abstraction]] — origin of the provider abstraction
- [[017-three-architectural-laws]] — Law 3: capability contracts are primary
- [[013-v2-masterplan-adopted]] — Layer 3 Runtime Intelligence Layer is the parent concept
- [[021-reviewitems-as-judgment-boundary]] — authority boundaries inherit from this principle
