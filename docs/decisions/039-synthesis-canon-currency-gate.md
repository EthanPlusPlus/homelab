---
record_type: canonical
id: "039"
title: Synthesis canon-currency gate — stop re-proposing finished work
date: 2026-06-13
status: active
category: governance
supersedes: []
superseded_by: []
---

# Decision 039 — Synthesis canon-currency gate

## Status

Adopted. Built and tested 2026-06-13 (same session). Three parts shipped in
`synthesis/` with 15 new tests (46 synthesis tests green). Prompt bumped to
`synthesis.canon-proposal.v2`. The acceptance cycle (one live synthesis run over
a real backlog) is the remaining step before the Decision 012 retirement claim
below is discharged.

## Context

The 2026-06-12 synthesis triage emitted 9 ReviewItems; **7 proposed work that was
already done** (capture a8185e98). The source captures predated the 06-06 Sukuna
triage and the loop phase A–D builds that resolved them. The dedup quality gate
(Decision 021) compares a candidate against *pending ReviewItems* — it cannot see
that the proposal describes work already recorded done in canon.

Reading the synthesis code before deciding showed the diagnosis was deeper than
"dedup ignores canon." `related_canon_for()` already retrieves canon and feeds it
to the model, and the v1 prompt already said "do not propose a change already
represented in the related canon." It failed because:

1. **Topical retrieval, not the closure ledger.** It pulled the most
   semantically-similar canonical chunks — for a 06-05 capture about a gap, the
   *decision that named the gap*, never the recent-changes.md entry recording
   that the gap was *fixed* on 06-10.
2. **No temporal framing.** The model was never told the capture predates the
   retrieved canon — the single signal that separates a stale capture from a
   live one.
3. **Currency was a buried parenthetical**, competing with the model's pull to
   be useful. Nothing forced it to reconcile a high *proposal* confidence
   against a "this already shipped" fact.

## Decision

### Canon-currency is a Law 2 judgment with a Law 1 enforcement shell

Per Decision 020's boundary, "does existing canon resolve this proposal?" is
interpretation (a capture can sit topically next to a decision yet propose a
genuine extension) — Law 2, synthesis territory. The wrong design is a
deterministic similarity gate that auto-suppresses above a threshold: that puts
judgment in a Law 1 mechanism and will silently kill real signal. **False
suppression is worse than the noise it prevents.**

The right design reuses the motif Prismo already uses (Decision 038's gate,
Decision 012's bridge): **deterministic evidence-gathering → interpretive
judgment → structural enforcement of that judgment.** Three composable parts:

**Part 1 — feed the closure ledger and time** (`synthesis/router.py`,
`assemble_related_canon`). Two retrievals over `record_type=canonical` records
only: topical decisions/ideas, plus a dedicated pull from the recent-changes
change log. Each hit carries its `status` and `date`; the capture's own
`captured_at` is framed explicitly ("this capture is dated X; canon below may
post-date and already resolve it"). This converts a hard reasoning task into an
easy grounded recognition.

**Part 2 — an explicit, evidence-bearing judgment field** (`synthesis/prompt.py`,
template v2). The model must fill, before proposing:

```
"canon_currency": { "already_addressed": bool, "addressed_by": ["<paths/entries>"] }
```

**Part 3 — a `currency_gate`** (`synthesis/quality_gate.py`) ordered after
confidence, before the costlier dedup embedding. Rejects only when the model says
`already_addressed` **and** cites evidence in `addressed_by`. A bare claim with no
citation is not trusted to suppress (it passes, flagged in telemetry). A proposal
with no `canon_currency` block passes — omission never blocks (backward compatible
with pre-v2 outputs).

### What this deliberately does not add

- **No new threshold.** The gate is boolean on a structured field. Decision 027
  found the confidence/dedup thresholds need no tuning; this introduces nothing
  to calibrate and no guessable similarity cutoff.
- **No second retrieval at emit-time.** Capture-time evidence feeds the model;
  the model's structured answer is the gate. A proposal-vs-canon re-retrieval is
  a future option only if false-negatives appear.

## Rationale

- Self-certification is not the failure here — the model *had* the instruction
  and ignored it. Forcing a cited yes/no and enforcing it structurally is what
  makes the judgment binding regardless of the model's confidence calibration.
- Requiring evidence to suppress, and letting bare claims through, encodes the
  asymmetry: re-proposing done work costs a human a quick reject; suppressing a
  real proposal loses it silently. Optimise against the silent failure.
- **Recursion-safe (Decision 018):** reads only canonical records; synthesised
  output (`record_type=synthesized`) is never fed back in. Feeding ground-truth
  canon into synthesis is reading the substrate, which D018 wants.
- **Model strength (Decision 023):** synthesis_runtime is Haiku (Class 1).
  Currency is arguably Class 2, but Part 1's evidence-strengthening turns it into
  recognition Haiku can do. Escalation path if the acceptance test shows misses:
  route the currency judgment alone to analysis_runtime (Sonnet). Not paid until
  the data demands it.

## Consequences

- `synthesis.canon-proposal.v2` — every ReviewItem now records the v2 template id
  in its provenance chain (Decision 018); old v1 ReviewItems remain valid.
- New `currency` gate failure type in synthesis telemetry, ordered before dedup.
- **Discharges the missing half of Decision 012's trigger 2** (synthesis quality
  gate covers the conflict/duplication-with-canon class). Combined with the
  doctrine preflight (trigger 1, substantially met), retirement of the CLAUDE.md
  canon-discipline ritual is now gated only on **one live synthesis cycle**
  confirming the re-proposal rate drops without suppressing genuine new items
  (acceptance test from capture f6ed4431). Until that cycle runs, the ritual
  stays.
- The acceptance test is encoded deterministically in `tests/test_synthesis.py`
  (`CurrencyAcceptanceTest`): a seeded backlog of done-vs-new captures, asserting
  zero false-emit and zero false-suppress.

## Related

- [[021-reviewitems-as-judgment-boundary|Decision 021]] — the quality gate this extends
- [[027-observation-week-closure|Decision 027]] — calibrated the existing thresholds; this adds no new one
- [[023-synthesis-interpretive-augmentation|Decision 023]] — Class 1/Class 2 model tiers (the Haiku tension)
- [[018-synthesis-provenance-and-recursion-prevention|Decision 018]] — recursion fence the currency retrieval respects
- [[020-doctrine-service-structural-coherence-engine|Decision 020]] — the structural-vs-interpretive boundary that makes currency Law 2
- [[017-three-architectural-laws|Decision 017]] — Law 1/Law 2 split
- [[038-workstream-phase-gate|Decision 038]] — same deterministic-preflight → interpretive-review → enforcement motif
- [[012-session-bootstrap-inline-discipline|Decision 012]] — this discharges trigger 2 of its retirement path
