---
id: "022"
title: Model routing policy for loop_runtime
status: proposed
record_type: canonical
date: 2026-06-09
notes: deliberately deferred from Decision 036 — loop v1 is single-model
---

# 022 — Model routing policy for loop_runtime

## Status

Proposed and deliberately deferred. Decision 036 ships the loop single-model
(Sonnet-class). This PI preserves the routing design thinking for when the
trigger conditions arrive.

## The Problem

Decision 025's three-axis model (Role / Execution Mode / Provider) assumes one
provider occupies a role at a time. Complexity routing — cheap model for
lightweight turns, strong model for heavy ones, *within the same session* —
breaks that assumption. Turn 3 on a small model and turn 7 on a large one is
not a provider swap; it is a **routing policy**, a fourth concept Decision 025
does not have:

```
Role → Execution Mode → Routing Policy → Provider (selected per turn)
```

Calling the router itself "the provider" hides the problem inside an
abstraction. If the loop ever routes by complexity, Decision 025 needs this
concept added explicitly.

This is distinct from PI-016 (routing_runtime), which classifies **facet
activations** — which facets fire on a message. This PI is about which **model
handles the turn**. Two different routing problems.

## Context from research (2026-06)

- RouteLLM (LMSYS): trained win-rate estimator routes strong/weak against a
  threshold; ~75–85% cost reduction at ~95% quality on benchmarks
- Off-the-shelf routers exist on Hugging Face: Arch-Router-1.5B (small enough
  to run locally), CARROT (cost-aware multi-model)
- Production pattern: heuristic pre-filter → lightweight classifier →
  confidence-based escalation
- Three-tier Claude routing benchmarks: ~50% session cost reduction vs uniform
  strong-model

## Trigger for building

- Per-contributor token telemetry (Decision 036 guardrails) shows loop cost is
  a real pain, AND/OR
- The local/frontier split matures: cheap local model handles most turns,
  API frontier model reserved for hard ones — at which point routing policy is
  also the local-migration mechanism, not just a cost optimisation

## Relationship to existing architecture

- [[../decisions/036-loop-runtime-role-contract-billing|Decision 036]] — defers this explicitly
- [[../decisions/025-runtime-intelligence-layer-topology|Decision 025]] — gains the fourth axis when this builds
- [[016-routing-intelligence-small-model-router|PI-016]] — sibling problem (facet routing), not the same problem
- [[017-capability-orchestrator|PI-017]] — the maximal version of this idea
