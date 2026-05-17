# Decision 022: Adapter Ontology Drift as Architectural Smell

## Problem

Three independent instances in V2 work (May 2026) reveal a recurring failure mode:

1. **Claude-specific memory files** (V1 adapter assumption → ontology): CLAUDE.md, MEMORY.md started as implementation convenience, calcified into architectural coupling. Re-examined via capture `1801ff71`.
2. **Production-state-dependent gates** (testing assumption → architecture): Two-week soak in Decision 019 began as testing discipline, became a hard architectural contract. Re-examined via capture `ff0335a0`.
3. **Drafts on disk** (workstation editing assumption → workflow): Local filesystem coupling for draft state management became an architectural concept, violating the memory-vs-interpretation separation (Decision 020). Re-examined via proposed-idea 012, resolved by Decision 021.

In each case, a locally-convenient adapter choice—justified at the time by implementation constraints—accumulated into the system's ontology before being explicitly examined. The pattern is not a single bad decision but *accretion without review*.

## Solution

Name this failure mode explicitly as **adapter ontology drift** and establish it as a class of architectural smell. The diagnostic signature:

- An assumption made in an adapter layer (e.g., "we'll use the filesystem for draft state") for tactical convenience.
- Over time, code, workflows, and contracts come to depend on it.
- The assumption hardens into the system's conceptual model before anyone notices it's an adapter detail, not an architectural choice.
- It violates Decision 017 (Law 3: capability contracts primary; adapters disposable).

### Remedy Pattern

When adapter ontology drift is detected:

1. **Isolate the adapter assumption** — identify which layer it belongs to.
2. **Restore the contract** — relocate the behavior to its proper Layer 3 home (synthesis service, judgment boundary, etc.).
3. **Leave the adapter clean** — the adapter should contain no ontological commitments, only implementation detail.

This is the remedy applied in all three instances above: return contracts to being pure, move adapter-specific behavior into the service layer.

## Rationale

Adapter ontology drift is a predictable consequence of incremental development under constraint. It is not malice or carelessness—it is how systems accrete complexity. However, it can be *detected early* and *corrected systematically* by applying Law 3 (Decision 017) as a review principle.

Naming it explicitly allows future contributors to recognize the pattern earlier, before the drift hardens into a major refactor. The three instances confirm this is a recurring failure mode, not a one-off mistake.

## Related Decisions

- **Decision 017** — Law 3: capability contracts primary; adapters disposable. This decision is the remedy for adapter ontology drift.
- **Decision 020** — memory-vs-interpretation separation. Drafts violated this; Decision 021 corrected it.
- **Decision 021** — ReviewItems as judgment boundary. Eliminated drafts by relocating state to its proper ontological home.

## Related Captures

- `1801ff71` — V2-pure relocation reframe (Claude-memory instance)
- `ff0335a0` — Production-state gates re-examined (soak instance)
- `e7f51070` — Memory-vs-interpretation framing