---
id: "023"
title: Synthesis-service owns interpretive augmentation — /synthesis/analyze contract
status: active
record_type: canonical
category: architecture
date: 2026-05-19
---

# Decision 023 — Synthesis-service owns interpretive augmentation

## Status
Adopted

## Date
2026-05-19

## Context

Synthesis-service was scoped in Decision 021 with one pattern: captures →
quality-gated ReviewItems. That pattern is operational and running.

During observation week, a second category of synthesis need emerged: on-demand
interpretive reasoning over proposed capabilities — prior-art analysis, overlap
detection, alternatives surfacing, architectural tension analysis. These are not
triggered by captures. They are triggered by human intent: "I'm about to build X,
what should I know?"

Separately, the system's current AI usage has remained implicit. As synthesis-service
grows, the distinction between cheap operational AI and expensive interpretive AI
needs to be explicit, or provider selection will happen by accident.

Two architectural questions this decision answers:

1. Where does interpretive augmentation live?
2. What is the model tier discipline for AI operations in Prismo?

## Decision

### Synthesis-service owns interpretive augmentation

Synthesis-service is the interpretive layer of Prismo. Its scope is:

> probabilistic, context-dependent, model-powered operations that produce
> structured operational artifacts.

This includes two capability classes:

**Class 1 — Internal synthesis (existing)**
Captures + canon context → proposed canon changes → ReviewItems.
Runs on schedule / on-demand via `POST /synthesis/run`.

**Class 2 — Interpretive augmentation (this decision)**
Human-supplied context → structured analysis → ReviewItem or analysis artifact.
Runs on-demand only, human-triggered.
First implementation: prior-art analysis (`analysis_type=prior_art`).

### The invariant that preserves purity

Every synthesis operation — regardless of class — must emit a structured
operational artifact. Not prose blobs, not raw chat, not markdown files.

Acceptable outputs: ReviewItems, AnalysisResult objects, comparison reports,
tension reports. These are durable, searchable, provenance-tracked, and
participate in the review queue.

This invariant is what separates "modular cognitive infrastructure" from
"random LLM utilities."

### The `/synthesis/analyze` endpoint

New endpoint. Generic contract, extensible by `analysis_type`.

```
POST /synthesis/analyze
```

Request:
```json
{
  "project": "homelab",
  "analysis_type": "prior_art",
  "description": "what you're planning to build or decide",
  "context": "optional additional context",
  "emit_review_item": true
}
```

`analysis_type` is a free string — do NOT enumerate until observation produces
real categories. The same lesson as `rejection_reason`.

Response (AnalysisResult):
```json
{
  "analysis_id": "an_<uuid>",
  "analysis_type": "prior_art",
  "description": "...",
  "findings": "...",
  "recommendation": "...",
  "sources": [...],
  "confidence": 0.0,
  "review_item_id": "rv_... | null"
}
```

If `emit_review_item=true` (default), the result is written to the review queue
as a `prior-art-report` ReviewItem. If false, result is returned only.

### `prior-art-report` is a valid artifact_type

Add `prior-art-report` to `VALID_ARTIFACT_TYPES` in `workflow/review.py`.
This is a schema extension — governed by the process defined in the
Decision 021 annotation (2026-05-19).

### No mandatory gates, no lifecycle requirements

This is pull-not-push. The human invokes it when useful. There is no:
- required step before a proposed-idea moves to `experimental`
- lifecycle gate
- automatic trigger (that is a future capability, not day-one)

If it proves valuable, synthesis can later *suggest* running analysis
when it detects a "new capability being scoped" pattern in captures.
That suggestion would itself be a ReviewItem, not a rule.

### Two AI tiers — explicit discipline

| Tier | Model | Use for | Examples |
|---|---|---|---|
| Operational | Haiku | Fast, cheap, bounded, infrastructure-like | Synthesis run (Class 1), brief generation, classification, metadata enrichment |
| Interpretive | Sonnet | Strategic, high-context, judgment-oriented | Interpretive augmentation (Class 2), architectural analysis, prior-art synthesis |

The `/synthesis/analyze` endpoint uses **Sonnet + web search tools**. This is
intentional — interpretive augmentation requires higher capability than the
operational synthesis loop.

Provider selection must never be hardcoded in endpoint logic. The tier is
selected via a new `ANALYSIS_MODEL` env var (default: `claude-sonnet-4-6`),
separate from `SYNTHESIS_MODEL` (Haiku).

### The architectural principle this decision establishes

> AI performs interpretation.
> Services own orchestration.
> Contracts own structure.
> Durable state owns truth.

This sentence governs all future AI integration decisions in Prismo. Any
proposed feature that violates it (e.g. AI directly writing canon, interfaces
embedding prompts, services coupling to model personality quirks) should be
rejected or restructured.

## Rationale

### Why synthesis-service and not a new service

Interpretive augmentation is probabilistic, produces ReviewItems, and sits
at the same architectural layer as synthesis. A new service would fragment
the interpretive boundary. The scope expansion is additive — it doesn't
require refactoring Class 1.

### Why `/synthesis/analyze` not `/synthesis/prior-art`

A specialized endpoint per analysis type would produce endpoint proliferation
as new types emerge (conflict, alternatives, overlap, capability_landscape).
The generic contract with `analysis_type` as a free parameter mirrors the
`rejection_reason` lesson: don't enumerate before observation.

### Why Sonnet for interpretive augmentation

Haiku is the right choice for operational synthesis: fast, cheap, handles
structured JSON output well at volume. Prior-art analysis requires web search
tool use, multi-turn reasoning over external sources, and nuanced comparison —
tasks where capability differences are architecturally material.

### Why no mandatory gates

Mandatory gates create V1-style behavioral compliance. If the capability is
genuinely useful, usage will emerge from value, not obligation. Usage patterns
during observation will inform whether any structural suggestions (not gates)
make sense.

### Why "anti-isolation mechanism" is the right frame

Prismo's danger is not building novel systems — the composite architecture is
genuinely novel. The danger is accidentally rebuilding commodity subcomponents
because the system is internally coherent enough to become self-referential.
Interpretive augmentation keeps Prismo connected to external reality, which is
where the system is intended to operate at the cutting edge.

## Consequences

### Immediate (architecture)

- `prior-art-report` added to `VALID_ARTIFACT_TYPES` in `workflow/review.py`
- `POST /synthesis/analyze` endpoint added to `synthesis/router.py`
- `synthesis/analyze.py` module created (prompt template + runner)
- `ANALYSIS_MODEL` env var added (default: `claude-sonnet-4-6`)
- capability-contracts.md updated
- Proposed-idea 014 status updated to reflect this decision

### Build sequence

1. Schema extension — `prior-art-report` artifact type
2. `synthesis/analyze.py` — prompt template, web search tool use, output parsing
3. `POST /synthesis/analyze` in router
4. `prismo prior-art "description"` CLI command
5. Tests for prompt building and output parsing
6. Update capability-contracts.md

### Deferred

- Automatic trigger: synthesis detects "new capability" in captures and *suggests* analysis
- Additional `analysis_type` values (overlap, conflict, alternatives) — emerge from usage
- Ambient mid-reasoning invocation (agent calls analyze during session automatically)
- Analysis history / searchable analysis artifacts beyond ReviewItems

## Related

- [[021-reviewitems-as-judgment-boundary|Decision 021]] — ReviewItem as universal artifact;
  `prior-art-report` extends the artifact_type set per governed process
- [[015-synthesis-provider-abstraction|Decision 015]] — SynthesisProvider abstraction;
  analysis uses a separate model tier, not the same provider instance
- [[020-doctrine-service-structural-coherence-engine|Decision 020]] — doctrine does structural
  truth; analysis does interpretive reasoning — the boundary holds
- [[017-three-architectural-laws|Decision 017]] — Law 2: interpretation is probabilistic;
  this decision is the direct application to synthesis-service scope
- [[../proposed-ideas/014-external-synthesis-prior-art|Proposed-idea 014]] — superseded by
  this decision; 014 can be closed
