---
id: "017"
title: Capability Orchestrator — holistic routing across models, tools, and runtimes
status: proposed
record_type: canonical
date: 2026-05-31
---

# 017 — Capability Orchestrator

## Status

Proposed. Early-stage idea. Not blocking any current work.

## The Idea

A routing intelligence that sits at the front of the pipeline with a holistic view of
Prismo's full capability surface. Given any prompt, it decides the optimal combination
of tools, models, and runtimes — not just which Facet to activate, but which *entire
execution path* to take.

Examples of decisions it would make:
- This task is simple enough for Gemini Flash / Haiku — route there instead of the main intelligence
- This prompt warrants a Sukuna canon pass — activate the sukuna Facet
- This needs interpretive analysis — invoke synthesis_runtime
- This is a migration task — activate the migrate Facet AND invoke prior-art research in parallel

The orchestrator has read access to:
- `GET /runtime/topology` — what intelligences are available and what they can do
- `GET /pipeline/activations` — what Facets and other activations are registered
- The incoming prompt + session context

## How it differs from proposed-idea 016

Proposed-idea 016 (routing_runtime) is scoped to Stage 2 of Facet activation — replacing
embedding similarity with a small model classifier. That is a point improvement to the
existing pipeline.

This proposal is a level above: a meta-router that orchestrates across the entire
capability surface, not just Facet selection.

016 may become the implementation of Stage 2 inside a broader orchestrator, rather than
a standalone proposal.

## Why not yet

- The current pipeline (Decision 026) + Facet system is functional and handling real work
- The capability surface is still being defined (runtimes, Facets, tools)
- Building a meta-router before the capabilities it routes to are stable risks over-engineering
- The right trigger: when routing decisions are being made manually that could be automated,
  or when a new runtime (local model, Gemini, etc.) is actually available to route to

## Related

- [[../decisions/026-layer-3-5-pipeline-service|Decision 026]] — the pipeline this sits in front of
- [[../decisions/025-runtime-intelligence-layer-topology|Decision 025]] — the topology it reads
- [[016-routing-intelligence-small-model-router|016]] — the narrower Facet-activation routing idea
- [[../decisions/030-billing-architecture-intelligence-tiers|Decision 030]] — the billing split
  that makes multi-model routing economically viable (side intelligences on API)
