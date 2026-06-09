---
id: "016"
title: Routing Intelligence — small model as activation router
status: proposed
record_type: canonical
date: 2026-05-30
---

# 016 — Routing Intelligence: small model as activation router

## Status

Proposed. Captures a design direction surfaced during Decision 026 implementation.
Not blocking any current work — the keyword+embedding router is functional.
Build when the routing miss-rate becomes a real pain point or when smart
model substitution (see open design questions) is being designed anyway.

> **Note 2026-06-09:** Scope boundary clarified during the loop design sessions:
> this PI routes **facet activations** (which facets fire on a message). Routing
> **which model handles a turn** (complexity routing within `loop_runtime`) is a
> different problem — see [[022-loop-model-routing-policy|PI-022]]. The two were
> loosely conflated in early PI-006 drafts; they are siblings, not the same idea.

---

## The Problem

The current activation router (Decision 026) uses two stages:

1. Keyword filter — string matching against `keywords` in each Facet definition
2. Embedding similarity — cosine distance against `examples` in each Facet definition

This works but has a known limitation: it matches surface form, not intent. Examples
that are imperative ("Let's redesign the API layer") score low against questions that
are descriptive ("describe to me the current architecture") even when both are clearly
architectural. Adding more examples helps at the margins but doesn't solve the
fundamental constraint — embeddings compare phrasing, not meaning.

Observed miss in the first live session: "describe to me the current architecture of
prismo" contained the keyword "architecture" (passed Stage 1) but scored below threshold
against imperative examples (failed Stage 2). A human would immediately classify this
as the architect Facet.

---

## The Proposed Solution

Replace Stage 2 (embedding comparison) with a `routing_runtime` — a small, cheap
model that classifies whether a message warrants Facet activation.

```
Stage 1 — Keyword pre-filter (unchanged, zero cost)
           "does this message contain any activation keywords?"
           → returns candidate set or empty (skip)

Stage 2 — routing_runtime classification (replaces embedding)
           "given this message and these candidate Facets, which activate?"
           → returns ActivationMatch[] with confidence scores
```

The model receives: the user message + a compact descriptor of each candidate Facet
(id, purpose, examples). It returns a structured JSON: which Facets activate and
why. No streaming, no tool use — a single bounded inference call.

---

## Why This Fits the Architecture

**It's a named runtime role.** Decision 025 requires new intelligence to have a named
role before implementation. This is `routing_runtime`:

```
routing_runtime
  role:        Classify inbound messages against registered Activations
  mode:        api (Haiku-class) or subscription_cli
  authority:   read-only — no canon writes, no ReviewItem creation
  capability:  structured_classification, low_latency
```

**Routing is interpretive, not structural.** The keyword+embedding approach was a
pragmatic approximation of what is fundamentally a judgment call: does this message
warrant Facet activation? That's Law 2 territory (interpretation is probabilistic),
not Law 1. Making the router explicitly probabilistic is architecturally more honest.

**The pre-filter keeps it cheap.** The keyword Stage 1 eliminates the model call
entirely for the common case (no keywords → no candidates → no model call). The
model only fires when there are candidates worth classifying.

**Haiku is fast and cheap.** A single short classification call is ~100-200ms and
fractions of a cent. In `subscription_cli` mode the marginal cost is zero.

---

## Connection to Smart Model Substitution

This proposed-idea is the first concrete instance of a broader pattern: using a
small model to make a routing or classification decision that was previously either
hardcoded or embedding-based. The pattern generalizes:

- Activation routing → `routing_runtime` (this proposal)
- Synthesis quality gating → already uses a model, but the gate logic is hardcoded rules
- Response processor capture detection → future `routing_runtime` reuse

If Prismo later designs a general "smart model substitution" capability — choosing
the right intelligence for a task based on cost/quality tradeoffs — the routing
runtime is a natural first case study.

---

## Open Design Questions

1. **Prompt design** — what does the routing prompt look like? The model needs the
   user message, a compact Facet descriptor, and needs to return structured JSON.
   Draft: `{facet_id: string, activates: bool, confidence: float, reason: string}[]`

2. **Failure mode** — if the routing_runtime call fails or times out, fall back to
   embedding similarity (current Stage 2). Graceful degradation preserves the hook
   never-blocking invariant.

3. **Latency budget** — Haiku API call adds ~300-600ms to every prompt that passes
   Stage 1. Acceptable for session work, potentially noticeable for rapid back-and-forth.
   Mitigation: aggressive keyword pre-filter, async call if Claude Code hook supports it.

4. **Registration** — does `routing_runtime` register in the topology like other roles?
   Yes — Decision 025 requires it. `GET /runtime/topology` should show it.

---

## Relationship to Existing Architecture

- [[../decisions/026-layer-3-5-pipeline-service|Decision 026]] — this replaces Stage 2
  of the router defined there. The Activation interface, assembler, and HTTP contract
  are unchanged.
- [[../decisions/025-runtime-intelligence-layer-topology|Decision 025]] — defines the
  named runtime role pattern this follows.
- [[../decisions/017-three-architectural-laws|Decision 017]] — Law 2 clarifies that
  routing (interpretive) belongs in probabilistic infrastructure, not deterministic.
