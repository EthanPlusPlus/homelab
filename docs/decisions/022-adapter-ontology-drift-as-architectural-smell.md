---
id: "022"
title: Adapter ontology drift as architectural smell
status: active
record_type: canonical
category: architecture
date: 2026-05-17
---

# Decision 022 — Adapter ontology drift as architectural smell

## Status
Adopted

## Date
2026-05-17

## Context

Three independent instances in V2 work (May 2026) reveal a recurring failure mode:

1. **Claude-specific memory files** (V1 adapter assumption → ontology): `CLAUDE.md`,
   `MEMORY.md` started as implementation convenience, calcified into architectural
   coupling. Re-examined via capture `1801ff71`.
2. **Production-state-dependent gates** (testing assumption → architecture): the
   two-week soak in [[019-lifecycle-loop-closure-pattern|Decision 019]] began as
   testing discipline, became a hard architectural contract. Re-examined via
   capture `ff0335a0`.
3. **Drafts on disk** (workstation editing assumption → workflow): local filesystem
   coupling for draft state management became an architectural concept, violating
   the memory-vs-interpretation separation
   ([[020-doctrine-service-structural-coherence-engine|Decision 020]]). Re-examined
   via [[../proposed-ideas/012-drafts-as-adapter-ritual|proposed-idea 012]],
   resolved by [[021-reviewitems-as-judgment-boundary|Decision 021]].

In each case, a locally-convenient adapter choice — justified at the time by
implementation constraints — accumulated into the system's ontology before being
explicitly examined. The pattern is not a single bad decision but *accretion
without review*.

## Decision

Name this failure mode explicitly as **adapter ontology drift** and establish it
as a class of architectural smell. The diagnostic signature:

- An assumption made in an adapter layer (e.g., "we'll use the filesystem for
  draft state") for tactical convenience.
- Over time, code, workflows, and contracts come to depend on it.
- The assumption hardens into the system's conceptual model before anyone notices
  it is an adapter detail, not an architectural choice.
- It violates [[017-three-architectural-laws|Decision 017]] Law 3 (capability
  contracts primary; adapters disposable).

### Remedy Pattern

When adapter ontology drift is detected:

1. **Isolate the adapter assumption** — identify which layer it belongs to.
2. **Restore the contract** — relocate the behavior to its proper Layer 3 home
   (synthesis service, judgment boundary, etc.).
3. **Leave the adapter clean** — the adapter should contain no ontological
   commitments, only implementation detail.

This is the remedy applied in all three instances above: return contracts to
being pure, move adapter-specific behavior into the service layer.

## Rationale

Adapter ontology drift is a predictable consequence of incremental development
under constraint. It is not malice or carelessness — it is how systems accrete
complexity. However, it can be *detected early* and *corrected systematically*
by applying Law 3 ([[017-three-architectural-laws|Decision 017]]) as a review
principle.

Naming it explicitly allows future contributors to recognize the pattern earlier,
before the drift hardens into a major refactor. The three instances confirm this
is a recurring failure mode, not a one-off mistake.

## Consequences

- **A named smell becomes a review tool.** Future contributors and Sukuna passes
  can flag candidate instances as "adapter ontology drift, instance #N" and apply
  the three-step remedy.
- **`rejection_reason` candidate for the synthesis review queue.** "Adapter
  ontology drift" is a concrete reason a ReviewItem could be rejected —
  candidate addition to the [[021-reviewitems-as-judgment-boundary|Decision 021]]
  rejection_reason enum once enough instances accumulate to justify enumeration
  over free-text.
- **Doctrine-service smell-check candidate.** When doctrine-service ships its
  Day-1 capabilities ([[020-doctrine-service-structural-coherence-engine|Decision
  020]]), structural detection of certain adapter-drift signatures (e.g., dict-
  shaped first-class fields that lock the schema to a single artifact format)
  could be a future rule.
- **Self-reference caveat.** Sukuna's 2026-05-17 audit observed that the
  ReviewItem schema itself contains two new instances of the smell named here
  (`proposal.frontmatter` as dict-shaped, `proposal.suggested_destination` as a
  filesystem path). Treating this decision as a review tool requires that the
  reviewing of the tool itself remain ongoing.

## Annotation 2026-05-17 — first-emission caveat

This document was the first canon artifact emitted through the
[[021-reviewitems-as-judgment-boundary|Decision 021]] synthesis → ReviewItem →
human-approval loop. Sukuna's 2026-05-17 audit noted that the initial emission
violated [[020-doctrine-service-structural-coherence-engine|Decision 020]]'s
metadata-reconciliation expectations: missing frontmatter, missing `## Status` /
`## Date` / `## Context` / `## Consequences` sections, title used a colon
instead of an em-dash. Fixed manually 2026-05-17. The malformed first emission
is itself evidence that the smell named here applies to the new build: the
synthesis prompt silently encoded the LLM's default markdown shape as the
canon-decision contract.

## Related Decisions

- [[017-three-architectural-laws|Decision 017]] — Law 3 (capability contracts
  primary; adapters disposable). This decision is the named-pattern remedy.
- [[020-doctrine-service-structural-coherence-engine|Decision 020]] — doctrine
  produces measurements, synthesis produces judgments. Drafts violated this;
  Decision 021 corrected it.
- [[021-reviewitems-as-judgment-boundary|Decision 021]] — ReviewItems as judgment
  boundary. Eliminated drafts by relocating state to its proper ontological home.

## Related Captures

- `1801ff71` — V2-pure relocation reframe (Claude-memory instance)
- `ff0335a0` — Production-state gates re-examined (soak instance)
- `e7f51070` — Memory-vs-interpretation framing
- `e1232d48` — Adapter ontology drift meta-pattern (the capture that became this
  decision)
