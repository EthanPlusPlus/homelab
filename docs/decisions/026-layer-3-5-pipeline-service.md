---
id: "026"
title: Layer 3.5 realized as Pipeline Service — Activation, Assembly, Response Processing
status: active
record_type: canonical
date: 2026-05-30
---

# Decision 026 — Layer 3.5 realized as Pipeline Service

## Status
Adopted

## Date
2026-05-30

## Context

Proposed-idea 015 introduced Layer 3.5 as "Runtime Cognition Shaping" — the concept that
cognition should be shaped before and after the model runs, not inside the model's own
reasoning turn. It named the problem clearly: SKILL.md Facets ask the model to fetch context
inside its own turn, making fetching and reasoning the same actor. Law 3 is violated because
the capability contract is encoded in a Claude Code-specific adapter.

015 left the activation mechanism open. The `/architect` SKILL.md was explicitly called a V1
prototype. The concrete realization — how activation is detected, how context is assembled,
and where this logic lives — was the remaining design question.

Two additional insights arrived in the session that produced this decision:

1. **The activation abstraction should be generic, not Facet-specific.** A router that
   understands only Facets must be rewritten when Prismo later needs to activate workflows,
   memory packs, personas, or toolsets. The foundational abstraction is `Activation` —
   Facets are one `ActivationType`.

2. **The pipeline is a service, not a layer.** The layers (1–4) describe ownership and
   authority, not request flow. A request traversing multiple governance tiers is normal.
   The pipeline owns sequencing; the layers still own their domains. Layer 3.5 is a
   *conceptual* position (between interface and runtime); the pipeline's *code* lives in
   context-server (Layer 2 territory), where retrieval, topology, and workflow state are
   already coordinated.

## Decision

### Layer 3.5 is realized by the Pipeline Service

Layer 3.5 (Runtime Cognition Shaping) now has a concrete implementation: a pipeline service
consisting of three components — Activation Router, Context Assembler, Response Processor.

```
Layer 4 (Interface)
    ↓ submits message ↓
Layer 3.5 — Pipeline Service (lives in context-server)
    ├── Activation Router    → consults Layer 1 Facet/Activation registry, Layer 2 embeddings
    ├── Context Assembler    → executes context_loaders against Layer 1+2 services
    └── Response Processor   → emits capture candidates, adapts output per interface
    ↓ delivers assembled context ↓
Layer 3 (Runtime) — model reasons with pre-built context
```

The pipeline owns sequencing. It does not own retrieval, topology, workflow state, or runtime
execution — it calls the services that do.

---

### The Activation interface is the foundational abstraction

Facets are one activation type. The pipeline contract is defined over `Activation`, not `Facet`.

```
Activation
  id          — unique identifier
  type        — ActivationType enum
  hint        — ActivationHint (structured matching spec)
  priority    — integer, for conflict resolution
  version     — for staleness tracking
```

Current activation types:
- `FACET` — runtime cognition shaping module (loads context, attaches heuristics)

Reserved for future use (no implementation yet):
- `WORKFLOW` — triggers a defined workflow execution sequence
- `MEMORY_PACK` — activates a curated memory bundle
- `CONSTRAINT` — applies operational constraints to the runtime
- `TOOLSET` — exposes a specific set of tools for the task

The router does not need to change when a new ActivationType is introduced. It matches,
scores, and returns `ActivationMatch[]` — the assembler handles type-specific execution.

---

### Activation hint schema

A single string hint is too brittle for embedding comparison. Each Activation declares a
structured hint:

```yaml
activation:
  examples:
    - "Let's redesign the API layer"
    - "How should we structure this service?"
    - "What architecture should we use for X?"
  keywords:
    - architecture
    - design
    - layer
    - service
    - system
  exclusions:
    - UI color
    - CSS styling
    - frontend layout
  threshold: 0.82
```

---

### Two-stage routing

Stage 1 — Keyword filter (cheap, synchronous):
- Check message against `keywords` set across all registered Activations
- Returns candidate set for Stage 2 (or empty — skip entirely)

Stage 2 — Embedding validation:
- Embed the message
- Compare against `examples` embeddings for each candidate
- Score each candidate: `max(cosine_similarity(message, example) for example in examples)`
- Filter out `exclusions` matches
- Return `ActivationMatch[]` sorted by score

The two-stage design keeps the common case (no activation warranted) cheap.

---

### Scoring and policy

The router returns scored matches, not a boolean:

```
ActivationMatch
  activation_id  — string
  type           — ActivationType
  score          — float (0.0–1.0)
```

Callers apply a policy to the scored list. Default policy: all matches above threshold.
Future policies (not implemented yet): top-k, highest-scoring workflow only, interface-specific
suppression.

Returning scores rather than a filtered list preserves policy flexibility without revisiting
the router contract.

---

### HTTP contract (Law 3)

Primary endpoint:

```
POST /pipeline/process
{
  "message": string,
  "session_id": string,          // optional, for session-scoped loaders
  "interface": string,           // optional, for response adaptation hints
  "policy": {                    // optional, defaults applied if absent
    "min_score": float,          // default: activation threshold per-activation
    "max_activations": int       // default: unlimited
  }
}

→ 200 PipelineResult {
  "activations": ActivationMatch[],
  "bundle": {
    "<activation_id>": {         // one key per matched activation
      "type": ActivationType,
      "context": { ... },        // assembled context for this activation
      "heuristics": string       // optional, for FACET type
    }
  },
  "assembled_at": "ISO8601",
  "session_id": string
}
```

Secondary endpoint for direct activation without routing:

```
POST /pipeline/activate
{
  "activation_id": string,
  "args": string,                // optional
  "session_id": string           // optional
}

→ 200 { same bundle shape, single activation }
```

---

### Implementation home

`pipeline/` module in context-server, peer to `synthesis/`, `workflow/`, `runtime/`:

```
context-server/
  pipeline/
    __init__.py
    activations.py   — Activation base class, ActivationType enum, ActivationHint
    registry.py      — loads Activation definitions from FACETS_DIR + future registries
    router.py        — two-stage routing, scoring, ActivationMatch
    assembler.py     — executes context_loaders per activation type
    bundle.py        — PipelineResult schema
    processor.py     — Response processor (capture detection, interface adaptation)
    api_router.py    — POST /pipeline/process, POST /pipeline/activate
```

---

### Facet definition format

Facet definitions move from SKILL.md markdown to YAML, stored in canon:

```
~/canon/homelab/scripts/facets/<name>/facet.yaml
```

This makes them:
- Machine-parseable by the assembler (no model involvement)
- Git-tracked in canon (Law 1 — structural truth)
- Stale-checkable by doctrine-service
- Runtime-agnostic (no Claude Code format assumptions)

The SKILL.md adapter remains for Claude Code invocation. It becomes a stub:
- Registers the skill with Claude Code
- States that context is pre-assembled by the pipeline
- Provides a fallback for when context-server is unreachable

---

### Activation detection in Claude Code (hook pattern)

The UserPromptSubmit hook already runs before the model. Extend it:

```bash
# prismo pipeline process "$PROMPT"
# → calls POST /pipeline/process
# → returns PipelineResult JSON
# → formats as [FACET: architect] block
# → written to stdout, injected as system reminder
```

The model receives `[FACET: architect]` alongside `[V2 HYDRATED CONTEXT]` before its turn
begins. No MCP calls inside the model's reasoning turn. The SKILL.md fallback fires only if
context-server is unreachable.

For automatic activation (no explicit `/architect`): the hook calls `/pipeline/process` on
every prompt and injects results when the router finds matches above threshold. This is the
mechanism that eliminates manual Facet invocation.

For explicit activation: `/architect` still works — SKILL.md triggers `/pipeline/activate`
directly.

---

### Response Processor (reserved for Phase 4 completion)

The response processor sits between the model's output and the interface. It is not built in
this decision's initial implementation; the slot is reserved.

Anticipated first capabilities:
- **Capture detection** — detect architectural decisions or observations in model output,
  surface as `CaptureSuggestion` (emitted to review queue, not auto-submitted)
- **Interface adaptation** — same model response formatted differently per interface
  (CLI verbosity vs WhatsApp brevity vs voice SSML)

The processor must not auto-write canon or create ReviewItems without human confirmation.
Decision 021's human-judgment boundary applies here as it does everywhere.

---

## Rationale

**Why generic Activation, not Facet-specific router.** Router rewrites are expensive.
The `Activation` abstraction costs nothing extra to introduce now and prevents the entire
pipeline contract from being revisited when the first non-Facet activation type is needed.
Facets become `ActivationType.FACET` — privileged in implementation order, not in contract.

**Why two-stage routing.** Most messages don't need any activation. A keyword pre-filter
eliminates the embedding call in the common case, preserving the Activation Ladder principle
from 015: cheap by default, cost incurred only when warranted.

**Why scores, not filtered lists.** Policy belongs at the call site, not in the router.
Returning scores gives every adapter the data to apply its own policy without changing the
router contract.

**Why the pipeline lives in context-server.** All its dependencies are already there:
vector store (for embedding comparison), retrieval infrastructure (for context loaders),
workflow state (for session-scoped loaders), runtime topology (for topology loaders). No new
service boundary is justified until the pipeline's complexity warrants it.

**Why not a new architectural tier.** The four-layer governance model describes ownership
and authority, not request flow. Layer 3.5 is a conceptual position (between interface and
runtime); the pipeline code lives in Layer 2 territory where coordination already happens.
Introducing a "Runtime Orchestrator" super-tier would contradict the masterplan's warning
against monolithic god objects and speculative mega-systems.

## Consequences

- `pipeline/` module ships in context-server as part of Phase 4 completion
- `POST /pipeline/process` and `POST /pipeline/activate` are documented in capability-contracts.md
- Facet YAML definitions replace SKILL.md as the authoritative Facet spec; SKILL.md becomes a thin adapter
- UserPromptSubmit hook gains pipeline awareness — replaces ad-hoc Facet-keyword detection
- Proposed-idea 015 status → `superseded` by this decision (015 named the problem and the concept; this decision provides the implementation architecture)
- Existing `/architect` SKILL.md migrates to thin adapter in the same session as `pipeline/` is built
- v2-masterplan Layer 3.5 annotation: "realized by the Pipeline Service per Decision 026"

## Related

- [[015-facets-runtime-cognition-shaping]] — superseded; the concept survives as ActivationType.FACET
- [[025-runtime-intelligence-layer-topology]] — topology is one context_loader type the assembler executes
- [[017-three-architectural-laws]] — Law 3 governs the pipeline's HTTP-first contract
- [[021-reviewitems-as-judgment-boundary]] — response processor cannot auto-create ReviewItems
- [[016-session-hydration-replaces-warmup]] — pipeline injection follows the same hook pattern
