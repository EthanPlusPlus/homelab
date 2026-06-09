---
record_type: canonical
id: "038"
title: Workstream phase gate — shift-left QA before execution
date: 2026-06-09
status: active
category: governance
supersedes: []
superseded_by: []
---

# Decision 038 — Workstream phase gate: shift-left QA before execution

## Status

Adopted. Ships as build phase D of the loop build (`fergie/loop-build-plan.md`).

## Context

The recurring failure mode in planning→execution transitions (named by Ethan,
2026-06-09): roadbumps mid-build caused by (1) proceeding on unvalidated
assumptions, (2) insufficient research, (3) incomplete requirements. The ask:
a shift-left QA mechanism that structurally raises confidence before "go build."

Honest framing recorded with the decision: **"are requirements good enough" is
formally unanswerable** — unknown-unknowns exist. A gate can (a) force every
known-unknown to be explicit and dispositioned, and (b) adversarially probe to
convert unknown-unknowns into known-unknowns. It reduces the failure modes; it
never eliminates them. Execution therefore keeps small-slice validation as the
complementary mechanism.

Prismo already learned the load-bearing lesson — *a self-reported check does not
count* (canon discipline, Decision 012 context). The model that wrote a plan
cannot be its own quality gate. Prismo also already has the structural motif:
Decision 012's bridge names deterministic preflight + interpretive quality gate
as the two-layer replacement for behavioral rituals. This decision applies that
same motif to workstream phase transitions. It is now a named recurring pattern:
**deterministic preflight → interpretive review → human judgment.**

## Decision

### Workstream gains a phase

`Workstream.phase ∈ {ideating, planning, executing}` — extends Decision 014's
object. The phase exists because the gate needs a transition to attach to, and
because activation priors differ by phase (PI-019). Phase transitions can only
add activations, never remove them (Decision 037).

A `lightweight` flag exempts a workstream from the full gate. The default is
gated; declaring a workstream lightweight is itself an explicit, recorded
judgment.

### The gate fires on planning → executing

Layer 2, harness-agnostic: `POST /workflow/workstream/:id/transition` evaluates
the gate regardless of which surface (loop, Claude Code, future harnesses)
requests the transition. A gate that only fires on one harness is theatre.

**Layer 1 — deterministic preflight (Law 1, no model):**

- Plan doc attached and the canon reference resolves
- Zero `open` assumptions **across all sessions of the workstream** — every
  assumption capture is `validated` or `accepted-as-risk` (explicitly, by a
  human). Kyle's unresolved assumption blocks Ethan's build — that is the
  feature.
- Zero open questions, same scheme
- External dependencies in the plan carry research citations

Checklist items reference artifacts that resolve — never self-asserted booleans.
If an item can be satisfied by typing "yes", it is a bad item.

**Layer 2 — adversarial review (Law 2, fresh eyes):**

A bounded `analysis_runtime` invocation that receives **only the artifacts**
(plan doc, assumption ledger, requirements) — never the planning conversation.
Same-context review inherits the same blind spots; fresh eyes is enforced
structurally, not by promise. Instruction: attack the plan — what is vague,
what fails if X breaks, what was never researched, what contradicts canon.
Output: structured findings (claim, severity, evidence).

**Zero findings on a non-trivial plan is itself a blocking anomaly** — complex
plans always have attack surface; an empty report means the reviewer failed.

**Layer 3 — human disposition (Decision 021):**

Findings land as ReviewItems. The gate produces evidence; it never auto-approves.
"Go build" means a human dispositioned every finding.

### What is deliberately not built

Gate-audit cadence (periodically injecting known-flawed plans to test the
reviewer) is deferred until the gate first misses something real — build from
real friction, not speculation. The masterplan's restraint principle applies to
process as much as ontology.

## Rationale

- Self-certification is the failure mode this gate exists to prevent; the
  three-layer split makes each layer check what it can actually check
- Cross-session assumption blocking makes multi-user planning honest
- Reusing the Decision 012 motif means no new architectural concept — the gate
  is workflow enforcement, squarely in workflow-state-service's charter
  ("replace behavioral rituals with structural enforcement")
- Cost is bounded: one deterministic pass (instant) + one bounded inference
  (~seconds) + human disposition time. Friction low enough not to invite bypass.

## Consequences

- `phase` and `lightweight` fields on Workstream; transition endpoint with gate
  evaluation in workflow-state-service
- Assumption/question disposition lifecycle (Decision 037) is a hard dependency
- `analysis_runtime` gains the plan-review task type (bounded, artifacts-only)
- Findings flow through the existing ReviewItem contract — no new judgment
  surface
- The loop's own construction runs ungated until phase D ships — progressive
  dogfooding, accepted

## Related

- [[037-loop-conversation-continuity|Decision 037]] — assumption ledger and phase semantics
- [[036-loop-runtime-role-contract-billing|Decision 036]] — the harness that triggers most transitions
- [[021-reviewitems-as-judgment-boundary|Decision 021]] — findings respect the judgment boundary
- [[014-workflow-state-service-architecture|Decision 014]] — the service extended
- [[017-three-architectural-laws|Decision 017]] — Law 1/Law 2 split of the gate layers
- [[../proposed-ideas/019-session-aware-facet-activation|PI-019]] — phase-based activation priors
