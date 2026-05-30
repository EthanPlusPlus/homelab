---
id: "028"
title: Response Processor — automatic capture from model output
status: active
record_type: canonical
date: 2026-05-30
---

# Decision 028 — Response Processor: automatic capture from model output

## Status
Adopted

## Date
2026-05-30

## Context

Decision 026 reserved the Response Processor slot in the pipeline with:
> "The processor must not auto-write canon or create ReviewItems without human confirmation."

That constraint was written conservatively before the usage model was discussed. In practice:
- Manually creating captures is friction that prevents signal from being captured at all
- Capture creation has been entirely absent in live sessions post-synthesis-service ship
- The review burden is at the ReviewItem level, not the capture level
- Captures are operational state (Decision 018) — they are not canon and have no authority

The right model: captures are infrastructure. The response processor detects signal in
model output and creates captures automatically. Humans engage at the ReviewItem level,
where synthesis has already filtered and distilled the raw captures.

## Decision

**The response processor automatically creates captures from model output — no human
initiation required.** This is the designated behavior, not a violation of Decision 021.

The pipeline on the outbound path:

```
model output
  → response processor detects signal-worthy content
  → POST /workflow/capture for each detected signal
  → synthesis-service later consumes captures
  → emits ReviewItems (quality-gated)
  → human reviews at ReviewItem level
```

Decision 021's human-judgment boundary is at ReviewItems, not captures. This is unchanged.

### Detection approach (initial implementation)

Pattern-based, deterministic — no model call. Conservative by design.

Patterns that indicate a signal-worthy sentence:
- Explicit observation markers: "worth noting", "I notice", "one thing to flag"
- Architectural insight markers: "the key insight", "this means", "the issue is"
- Directional signals: "we should", "this should be", "the right approach"
- Problem framing: "the problem is", "this breaks down when", "the constraint is"

Filters applied:
- Minimum sentence length: 40 characters (eliminates incidental phrase matches)
- Maximum captures per response: 3 (prevents flooding from verbose responses)
- Dedup: don't create if highly similar capture already exists in pending-review state
- Source tag: `response_processor` on all auto-created captures for traceability

### Boundary with synthesis-service

The response processor operates on *individual model responses* — it detects observations
the model surfaced in this turn. Synthesis-service operates on *accumulated captures* —
it distills patterns and proposals from a batch. They are not in conflict.

The response processor is upstream of synthesis-service:
```
model output → response processor → captures → synthesis-service → ReviewItems
```

The response processor does not do synthesis. It does detection.

### Future path

When `routing_runtime` (proposed-idea 016) ships, capture detection can be upgraded from
pattern-matching to model classification — a Haiku-class call that scores each sentence
for capture-worthiness. The interface is the same; only the detection mechanism changes.

## Consequences

- `pipeline/processor.py` implements pattern-based detection + `POST /workflow/capture`
- Decision 026's "processor must not auto-create" restriction is superseded by this decision
- Capture volume will increase as sessions run — expected and correct
- Synthesis-service backpressure gate manages the ReviewItem queue; capture volume does not
  directly affect review burden
- `source=response_processor` on auto-captures so they are distinguishable from manual ones

## Related

- [[021-reviewitems-as-judgment-boundary]] — human-judgment boundary at ReviewItems, unchanged
- [[018-synthesis-provenance-and-recursion-prevention]] — captures are operational state, not canon
- [[026-layer-3-5-pipeline-service]] — response processor slot; this decision supersedes the
  "no auto-create" conservative restriction in 026
- [[016-routing-intelligence-small-model-router|Proposed-idea 016]] — future upgrade path for detection
