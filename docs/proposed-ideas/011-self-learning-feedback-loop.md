---
id: "011"
title: Self-Learning Feedback Loop
status: deprioritised
notes: split out from original 008 section 3; revisit if Sukuna output volume creates review bottleneck
---

# 011 — Self-Learning Feedback Loop

## Status

Deprioritised. Revisit if the Sukuna review cadence becomes a bottleneck.

## Origin

Originally part of [[008-agentic-decision-pipeline|008]] section 3.

## The Idea

Agents that write back to canon autonomously, gated by a quality-assessment reviewer. Roughly:
a Scribe captures session outcomes; a reviewer agent gates changes before they land.

## Why Deprioritised

The filesystem-for-durable-truth principle ([[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]]) and
[[009-maid-canon-standardizer|Sukuna]]'s review cycle serve this need at current scale.
Autonomous canon writes — even gated — invert the V2 principle that humans retain canon
authority (see [[../architecture/v2-masterplan|V2 Masterplan]] Principle 4).

Not a bad idea in the abstract, but the current model (draft → human review → canon) handles
the volume Prismo produces. Building the gated-autonomous path before there's a clear
bottleneck is premature.

## Revisit Trigger

If Sukuna's output volume grows enough that manual review of every draft becomes a real
bottleneck — and the bottleneck is review attention, not draft quality — reconsider.

## Update 2026-05-17 — subsumed by Decision 021

[[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]] explicitly defers
auto-approval tiers ("review tiers / auto-approval" in the not-day-one list) to
post-observation-week refinement. That is the same conclusion this proposed-idea
reached: defer until a real bottleneck materializes. The trigger above is now
operationally measurable via `prismo metrics` (approval rate, time-to-decision,
backpressure events). When/if the observation week reveals the bottleneck, this
proposal's framing folds into the synthesis-service refinement work; no new
proposed-idea needed.
