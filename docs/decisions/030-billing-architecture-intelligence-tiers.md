---
id: "030"
title: Billing architecture — subscription for main intelligence, API for side intelligences
status: active
record_type: canonical
category: infrastructure
date: 2026-05-31
---

# Decision 030 — Billing architecture: subscription for main intelligence, API for side intelligences

## Status
Adopted

## Date
2026-05-31

## Context

Decision 025 defined execution modes (subscription_cli, api, local, agentic) and named
runtime roles, but deferred the question of which mode maps to which role. The billing
architecture decision fills that gap.

The key tension: Prismo has two tiers of intelligence with very different usage patterns.

- **Main intelligence** (coding_runtime) — handles the primary session work. Continuous,
  high-volume, deep-context. API billing at this tier is economically unsustainable at
  any serious usage level.
- **Side intelligences** (synthesis_runtime, analysis_runtime) — invoked on-demand for
  bounded tasks (synthesis runs, prior-art research, analysis passes). Intermittent,
  scoped, lower volume. API billing is feasible here.

LiteLLM was evaluated as a provider abstraction layer. Its role is clarified by this
decision: it belongs inside the side intelligence providers, not at the main intelligence
layer.

## Decision

### Main intelligence uses subscription billing

`coding_runtime` runs via Claude Code (subscription_cli execution mode). This is the
current reality and the intended long-term direction. Subscription billing is sustainable,
predictable, and aligned with the usage pattern of a continuous session intelligence.

LiteLLM is **not** wired into the coding_runtime path.

### Side intelligences use API billing via LiteLLM

`synthesis_runtime` and `analysis_runtime` use API-mode execution with LiteLLM as the
provider abstraction inside their provider implementations
(`AnthropicSynthesisProvider`, `AnthropicAnalysisProvider`). LiteLLM replaces the raw
`anthropic` SDK client, making the model string-swappable without code changes.

This is the Phase 4 remaining LiteLLM wiring item — scoped to these two providers only.

### The door stays open

The main intelligence slot is architecturally swappable (Decision 025 — the role is not
the provider). If subscription billing stops being viable, or if a different runtime
becomes the right fit, the slot can be filled without structural changes. This decision
records the current choice, not a permanent constraint.

## Rationale

- Subscription billing is the only sustainable model for a continuous session intelligence
  at current and projected usage levels
- LiteLLM adds real value for side intelligences: model-swappable via string, provider
  abstraction without coupling
- Side intelligences are low-volume enough that API costs are predictable and acceptable
- Keeping the main intelligence slot open to future substitution is architecturally honest
  and costs nothing

## Consequences

- **LiteLLM wiring scoped**: Phase 4 remaining work is to wire LiteLLM inside
  `AnthropicSynthesisProvider` and `AnthropicAnalysisProvider` only. Nothing else changes.
- **SYNTHESIS_MODEL / ANALYSIS_MODEL env vars** become the model-swap mechanism — no code
  change required to switch between claude-haiku-4-5, claude-sonnet-4-6, or any
  LiteLLM-supported model string.
- **coding_runtime unchanged**: no LiteLLM coupling, no API key dependency for session work.

## Related

- [[025-runtime-intelligence-layer-topology|Decision 025]] — defines the execution_mode
  taxonomy this decision populates
- [[015-synthesis-provider-abstraction|Decision 015]] — the provider interface LiteLLM
  will sit behind
- [[024-capability-registry-phase-4-runtime-abstraction|Decision 024]] — capability
  registry that routes synthesis/analysis to their providers
