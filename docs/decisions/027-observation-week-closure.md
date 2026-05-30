---
id: "027"
title: Observation week closed — synthesis quality gate calibration findings
status: active
record_type: canonical
date: 2026-05-30
---

# Decision 027 — Observation week closed

## Status
Adopted

## Date
2026-05-30

## Context

Decision 021 required an "observation week" after synthesis-service shipped (2026-05-17)
before doctrine-service Day-1 could begin. The intent: let the synthesis loop run against
real captures, observe emission rate, approval rate, rejection patterns, and use that
empirical signal to calibrate quality gates.

The loop ran. The gate was never formally closed with a canon record — flagged by
Sukuna 2026-05-30. The PostgreSQL migration (2026-05-29) zeroed the metrics DB, so
live `prismo metrics` no longer reflects the observation period. This decision closes
the gate from what was documented in recent-changes and session records.

## Findings from the observation period (2026-05-17 through ~2026-05-24)

### Emission behavior
- First run (2026-05-17): 2 ReviewItems emitted at confidence 0.82 and 0.75
- Both proposals were substantively correct extensions of the source captures
- Confidence threshold of 0.7 and dedup threshold of 0.85 produced reasonable output
- Backpressure gate (max pending ReviewItems) behaved correctly
- Loop closed end-to-end: captures → synthesis → ReviewItems → human review

### Rejection pattern
- `wrong-artifact-type` dominated rejection reasons (3 of 3 rejections in the period)
- The synthesis-service emitted correct *content* but chose incorrect *artifact_type*
- This is a classification problem in the prompt, not a quality gate problem

### Quality gate calibration
- Thresholds (confidence ≥ 0.7, dedup ≥ 0.85) are appropriate — no tuning needed
- The dominant failure mode (wrong-artifact-type) is not addressable by threshold adjustment
- It requires either: better artifact_type classification in the synthesis prompt, or
  artifact_type pre-classification as a separate quality gate step

## Decision

**Close the observation-week gate.** Doctrine-service Day-1 is unblocked.

Quality gates remain at current thresholds. The `wrong-artifact-type` finding is captured
as a known limitation but does not block doctrine-service work — it is a synthesis
improvement to be addressed separately.

**One remediation action:** the synthesis prompt template should include clearer
artifact_type guidance and examples. This is a `synthesis/prompt.py` change, not a
gate change.

## Consequences

- Doctrine-service Day-1 is unblocked (Decision 020 scope)
- Proposed-idea 013 (Sukuna as synthesis consumer) is unblocked from the
  observation-week dependency
- `wrong-artifact-type` as dominant rejection reason is a known synthesis debt item —
  should be surfaced as a future capture for improvement
- Metrics DB zeroed by PostgreSQL migration; no retention of raw observation data.
  Future observation periods will have durable data in PostgreSQL.

## Related

- [[021-reviewitems-as-judgment-boundary]] — the decision that created this gate
- [[020-doctrine-service-structural-coherence-engine]] — now unblocked
- [[013-sukuna-as-synthesis-consumer|Proposed-idea 013]] — dependency resolved
