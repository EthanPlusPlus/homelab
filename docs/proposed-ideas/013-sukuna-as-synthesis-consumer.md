---
id: "013"
title: Sukuna as a synthesis-service consumer (emit ReviewItems, not drafts)
status: superseded
superseded_by: decisions/026-layer-3-5-pipeline-service.md
record_type: canonical
notes: Superseded 2026-05-31 — the pipeline (Decision 026) + Response Processor (Decision 028) solve this structurally. Sukuna Facet handles context loading; Response Processor auto-creates captures from model output. Completion criterion is Decision 028's Phase 5 hook wiring.
---

# 013 — Sukuna as a synthesis-service consumer

## Status

Superseded 2026-05-31 by [[../decisions/026-layer-3-5-pipeline-service|Decision 026]] + [[../decisions/028-response-processor-auto-capture|Decision 028]].

The pipeline solves this structurally without a Sukuna-specific build:
- **Sukuna Facet** (`scripts/facets/sukuna/facet.yaml`) handles context loading and heuristics — the "thin orchestrator" input side this proposal described
- **Response Processor** (Decision 028) auto-creates captures from model output matching signal patterns — the output side
- Sukuna Facet heuristics already instruct the model to surface findings as captures rather than writing to drafts/

The remaining gap (Phase 5 hook wiring for the Response Processor) is tracked in Decision 028, not here. Once the Claude Code `PostToolUse` hook is wired, a Sukuna pass will automatically seed captures without any script changes.

## Origin

Sukuna 2026-05-17 audit, Section 3: "The Sukuna script (this script) is the
loudest live violation of the filesystem-for-durable-truth principle. Decision
021: 'the filesystem does NOT contain operational limbo states / pre-approval
drafts / half-authored workflow intermediates.' This document is exactly that.
Sukuna's next iteration should `POST /synthesis/run` (or directly `POST
/review/queue` one ReviewItem per finding) and emit nothing to disk."

The 2026-05-17 Sukuna run was the last report written to `drafts/` under the
current architecture.

## The Idea

Refactor `scripts/sukuna` so that:

1. **Section 1 (Consistency / Wording fixes)** — each diff becomes one ReviewItem
   with `artifact_type=annotation` or `runbook-update`, targeting the affected
   file with `affected_existing_docs` populated.
2. **Section 2 (Observations)** — each observation becomes one ReviewItem with
   `artifact_type=annotation` against the relevant decision/architecture doc,
   OR `artifact_type=proposed-idea` if it warrants a new doc.
3. **Section 3 (Thinking / Directed)** — each bullet becomes one ReviewItem
   with `artifact_type=proposed-idea` or `artifact_type=annotation`, with
   `confidence` honestly reflecting the model's certainty.

The Sukuna script becomes a thin orchestrator: invoke synthesis-service with
a structured pass over canon, collect emitted ReviewItems into a single
"Sukuna run #N" identifier, exit. The output the human sees is `prismo review`
showing the new items, not a markdown report.

## Why this isn't built yet

Three reasons it should wait:

1. **Decision 020 doctrine-service Day-1 hasn't shipped.** Sukuna's most
   valuable section (Section 1 wording fixes) overlaps significantly with
   doctrine-service's metadata-reconciliation capability. Building Sukuna's
   new shape before doctrine-service exists risks duplicating the rule set.
   Better: ship doctrine-service Day-1, see what it catches automatically,
   then refactor Sukuna to fill the remaining narrative gap.
2. **Observation week is still active.** The synthesis-service quality gate
   (preflight, dedup, confidence) is being calibrated. Adding a high-volume
   producer (Sukuna runs emit 10-30 findings each) before the gates are tuned
   would dump unfiltered noise into the review queue.
3. **No need for urgency.** The current `scripts/sukuna` works — it writes
   reports to `drafts/`, the human reads them, applies wording fixes manually
   (as just happened with the 2026-05-17 report). The "filesystem violates
   Decision 021" critique is structural, but the practical cost is minimal at
   single-contributor scale.

## Dependencies / sequencing

- [[../decisions/020-doctrine-service-structural-coherence-engine|Decision 020]]
  Day-1 capabilities live (so doctrine handles Section 1 mechanically, Sukuna
  handles Sections 2+3)
- Synthesis-service quality gates calibrated via observation-week data
- Decision on `rejection_reason` enumeration (free-text vs enum) settled, since
  Sukuna findings will populate it heavily

## Open design questions

1. **Granularity.** One ReviewItem per Sukuna finding, or one ReviewItem per
   Sukuna run with multiple suggested changes? Per-finding is more honest to
   the ReviewItem ontology; per-run is more readable. Lean: per-finding.
2. **Provenance.** ReviewItem.sources should reference the Sukuna run id and
   the specific section/bullet that produced it. Schema already supports this
   via `sources.synthesis_run_id`; just need a `sukuna_run_id` convention.
3. **Backpressure.** A Sukuna run could emit 20+ findings, blowing past the
   synthesis backpressure_max. Either (a) Sukuna respects backpressure and
   emits in batches across multiple invocations, or (b) Sukuna gets its own
   higher backpressure ceiling. Lean: (a) — Sukuna is just another synthesis
   pattern; same gates apply.

## Related

- [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]] —
  ReviewItems as the universal Layer 4 integration primitive; Sukuna becoming a
  consumer is the direct application
- [[../decisions/022-adapter-ontology-drift-as-architectural-smell|Decision 022]]
  — Sukuna writing to drafts/ is itself an instance of the smell named here
- [[009-maid-canon-standardizer|009 — Sukuna canon agent]] — the original
  scoping of Sukuna; this proposal is the V2 evolution
