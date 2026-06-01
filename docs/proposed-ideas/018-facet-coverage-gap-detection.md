---
id: "018"
title: Facet Coverage Gap Detection — surfacing missing facets from session patterns
status: proposed
record_type: canonical
date: 2026-06-01
---

# 018 — Facet Coverage Gap Detection

## Status

Proposed. Not blocking any current work. Build when facet misses become a repeated
friction point, or when the wrap-up SEQUENCE is built (natural integration point).

---

## The Problem

Facet coverage expands reactively today. A session runs, no facet fires, the work
happens anyway, and the gap is noticed only if someone recognises it mid-session or
in retrospect ("a facet could have been used here"). There is no structural mechanism
for detecting that a session's pattern didn't match any existing activation.

The result: facets are added after repeated manual observation rather than after the
first clear signal. Given that each Ethan-observed miss requires a conscious
"I should note this" moment, coverage improves slowly and unevenly.

This is distinct from two adjacent problems:
- [[016-routing-intelligence-small-model-router|PI-016]] — addresses routing *accuracy*
  for existing activations (intent vs surface form). The facet exists; the router just
  missed it.
- [[017-capability-orchestrator|PI-017]] — addresses routing *breadth* across models,
  tools, and runtimes holistically.

PI-018 addresses *coverage*: the session pattern matched nothing because nothing
appropriate exists yet.

---

## The Proposed Solution

A lightweight gap-detection pass that fires at session end when no facet was activated
during the session. Two implementation paths:

### Path A — Wrap-up heuristic (no infrastructure required)

Add a step to the `wrap-up` facet heuristics:

> If no facet was activated during this session, examine the session content.
> Did it involve: architectural decisions? evaluations? migrations? reviews?
> canon maintenance? onboarding? deployment? If yes, surface:
> `prismo capture "session pattern: <description> — no facet matched, possible gap"`

This works today with zero new infrastructure. The wrap-up facet checks the session
and emits a capture if the pattern suggests a missing facet. The capture enters
synthesis → ReviewItems → human review, same as any other signal.

Limitation: relies on the wrap-up facet firing, and on the model correctly classifying
the session pattern. Low precision — will produce false positives (sessions that touched
facet-adjacent content but didn't need a facet).

### Path B — Pipeline session analysis (requires new endpoint)

After `prismo session end`, a lightweight analysis runs against the session's
`operational_events` log:

1. Fetch session events — what prompts were submitted, what topics were covered
2. Check `GET /pipeline/activations` — what activations exist and what their patterns are
3. If no activation fired for the session AND the event log contains content matching
   known "facet-shaped" patterns (decision language, migration language, evaluation
   language), emit a capture with the session ID and pattern description

This is more precise because it has the full session log rather than just the closing
prompt. It can also detect *partial* gaps: sessions where an existing facet fired but
a second facet *should also* have fired and didn't.

Relationship to PI-016: Path B could reuse the `routing_runtime` (small model) from
PI-016 to classify whether the session log contains a facet-shaped pattern. The same
intelligence that improves activation routing could also detect coverage gaps.

---

## What "facet-shaped" means

Not every session without a facet is a gap. Gaps are sessions where:
- The content was clearly in a known domain (design, evaluation, migration, review,
  onboarding, deployment) AND
- The interaction would have been meaningfully improved by pre-loaded context + heuristics AND
- The absence was noticed or would be noticed on reflection

Non-gaps: quick factual questions, one-shot tasks, conversations that naturally evolved
into a facet domain mid-session, sessions explicitly outside any facet's scope.

---

## Expected output

Captures from this mechanism will mostly be low-signal or redundant — they point at
sessions that touched facet-adjacent content without confirming a new facet is actually
needed. Expected rejection rate in synthesis: high.

The valuable output is the small fraction that points at a *genuine* recurring pattern
with no facet: a session type Ethan returns to repeatedly with no structural support.
That's the signal worth building on.

---

## Build order dependency

Path A (wrap-up heuristic): can be implemented now, in the next wrap-up facet update.
Path B (pipeline session analysis): depends on:
- Session event log being queryable by content (currently `operational_events` exists,
  query surface is limited)
- SEQUENCE ActivationType built (see Sukuna pass 2026-05-31 observation) — if wrap-up
  becomes a SEQUENCE, the gap-detection step fits naturally as a final sequence step

Recommend: implement Path A in the next wrap-up update as a zero-cost immediate signal.
Revisit Path B when SEQUENCE is built or when the session event log has richer query
support.

---

## Links

- [[016-routing-intelligence-small-model-router|PI-016]] — routing accuracy improvement,
  potential reuse of routing_runtime for Path B classification
- [[017-capability-orchestrator|PI-017]] — broader orchestration; gap detection could
  eventually be a capability the orchestrator performs
- `scripts/facets/wrap-up/` — Path A integration point
- `workflow/` — session event log, Path B data source
