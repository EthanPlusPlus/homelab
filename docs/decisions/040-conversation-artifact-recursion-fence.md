---
record_type: canonical
id: "040"
title: Recursion fence for model-authored conversation artifacts
date: 2026-06-13
status: active
category: architecture
supersedes: []
superseded_by: []
---

# Decision 040 — Recursion fence for model-authored conversation artifacts

## Status

Adopted. The "now" changes below shipped this session (2026-06-13); the fuller
option C is explicitly deferred. (Numbered 040, not 039 — 039 was used by the
reverted canon-currency gate and is a burned number.)

## Context

Decision 018 fenced *synthesis* output from authoritative reuse: `record_type`
separation, permanent exclusion from `active_doctrine`, provenance, source-hash
staleness — because model-written text feeding future model context compounds
errors ("organizational mythology"). The loop (Decisions 036/037) introduced
**three new classes of model-authored content that re-enter the model's context**
and carry none of that discipline: **checkpoints** (injected into the next
session's system prompt via workstream hydration), **rolling summaries** (slot 3
of the context window), and **model-logged assumptions** (hydration + the phase
gate lever). Surfaced by Sukuna finding 7df89588.

Why D018 didn't already catch it: its *mechanism* is `record_type` filtering on
ChromaDB retrieval. These artifacts are operational-state rows injected
**directly** into the prompt — they never pass through indexed retrieval, so the
D018 filter cannot reach them. Verified in code: `latest_checkpoint` returns the
newest row regardless of status, and an unreviewed draft hydrated the next
session gated only by a one-line "treat as provisional" string.

Assessed (assess facet, captures 7893d1af + this record). Two findings shaped
the decision:

1. **A prose label is not a fence on this model class.** Decision 039's live
   failure showed the loop's model ignoring explicit prompt instructions and
   fabricating confident citations. The existing "treat as provisional" line was
   exactly such a label. The fence must be *structural* and *human-centric*, not
   an instruction the model can skim past.
2. **Severity is real but scale-dependent and reversible.** Unlike D018's
   permanent corpus contamination, a bad checkpoint's blast radius is one
   workstream's hydration chain — repairable. Compounding is also second-order
   (a checkpoint is generated from the session transcript, not the prior
   checkpoint directly). So this earns *low-regret hardening now*, not D018's
   prevent-at-all-costs urgency. The risk rises with multiple contributors and
   multi-day workstreams, and is worst in thin/abandoned sessions where hydrated
   model framing dominates the little real content — the common case for
   non-technical contributors (Decision 037).

## Decision

### Principle

Model-authored conversation artifacts (checkpoints, rolling summaries,
model-logged assumptions) are **non-authoritative until a human reviews them** —
the Decision 018 principle, applied to the conversation layer. The enforcement is
structural and human-centric, never a prose instruction to the model.

### Shipped now (low-regret, reversible)

- **Structural hydration fence.** Unreviewed (`draft`) checkpoints are still
  hydrated (continuity must not require review — see deferral rationale) but are
  **quarantined inside a delimited, labelled block** (`===== UNVERIFIED … =====`)
  that separates them from authoritative context and frames each item as a claim
  to confirm, not a fact. Reviewed checkpoints are presented as authoritative.
  Pure function `format_hydration_brief` in `loop_server/checkpoint.py`,
  unit-tested.
- **Real review affordance in the UI.** The confirmation-biased single "Looks
  right" button is replaced with **Confirm as accurate** + **Edit…** (editable
  fields saved via the existing `PATCH /loop/checkpoint/:id` `fields` body, human
  edit wins). Review is no longer a one-click rubber stamp.

### Deferred until firsthand multi-contributor signal (option C)

- Extending the assumption disposition lifecycle (`open/validated/accepted-as-risk`)
  — already the conversation-layer's working review gate **for assumptions** — to
  checkpoint decisions/next-steps, so every artifact gets uniform "claimed vs
  verified" treatment. This is the principled end state; build it from real
  friction, not speculation.
- A `generated_by` provenance column on checkpoints/summaries (the reviewed-state
  fence uses the existing `status`/`contributor_id`/timestamps; a model-id stamp
  is audit nicety, deferred with C to avoid a schema migration now).
- Staleness when a checkpoint references canon that later changed (D018's
  source-hash analog).

### Not changing

- Drafts still hydrate. Requiring review before continuity (the "strict" option)
  was rejected: it makes review a prerequisite for using a workstream, which
  collides with the judgment-capacity bottleneck (finding 064b7e20) and would
  drive contributors off workstreams entirely — a bigger loss than the
  compounding risk it prevents.

## Rationale

- Reuses the Decision 018 principle and the existing assumption-disposition
  pattern rather than inventing a mechanism (masterplan restraint).
- Fails safe without a human in the loop: unreviewed content stays usable but
  visibly non-authoritative, so the fence holds even when review can't keep up.
- Structural-not-prose is the direct lesson of Decision 039; encoding it stops a
  repeat.
- Scoping to "now + deferral" matches the evidence: the failure mode is
  first-principles-expected, not yet observed, and reversible.

## Consequences

- `loop_server/checkpoint.py` gains `format_hydration_brief` (pure, tested, 5
  tests); `_workstream_brief` delegates to it.
- `prismo-ui` chat page: checkpoint review is confirm-or-edit; `approveCheckpoint`
  takes optional edited fields.
- The recursion-prevention doctrine now covers both generators of model-authored
  context — synthesis (D018) and conversation (this) — closing the asymmetry
  finding 7df89588 named.
- Revisit for option C when multi-contributor scale produces real friction.

## Related

- [[018-synthesis-provenance-and-recursion-prevention|Decision 018]] — the synthesis-side fence this mirrors for the conversation layer
- [[037-loop-conversation-continuity|Decision 037]] — checkpoints/hydration this fences
- [[020-doctrine-service-structural-coherence-engine|Decision 020]] — the doctrine (authoritative) vs synthesis (interpretive) boundary
- [[021-reviewitems-as-judgment-boundary|Decision 021]] — human-judgment boundary this preserves at scale
- [[017-three-architectural-laws|Decision 017]] — Law 2: interpretation is non-authoritative
