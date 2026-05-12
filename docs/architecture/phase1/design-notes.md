# Phase 1 Design Notes

Observations and cautions captured during Phase 1 definition work. Not immediate action items — context for future decisions.

---

## Temporal Operational State (Phase 7 horizon)

Current canon objects are static records. Eventually Prismo may need evolving timelines and temporal continuity: "what was the state of this project on date X?", "how has this decision evolved?", "reconstruct the architectural reasoning over the last 6 months."

The existing design already points in this direction: immutable decision records + supersession chains is halfway to event sourcing. The `updated_at` and `created_at` fields in the object model are the seed. A full temporal state system would add:

- State snapshots at significant moments
- Operational event streams (decision adopted, proposal created, workstream started)
- Timeline reconstruction capability
- Contributor history

**When to build:** when a project runs long enough that "how did we get here" becomes a real operational question. Not before.

---

## Doctrine-Service Scope

The doctrine-service is likely to grow into the central system of V2 — the organizational coherence engine.

Once it has: relationships + supersession chains + staleness detection + contradiction detection + lifecycle enforcement + retrieval prioritization, it is doing something qualitatively different from a CRUD service. It is maintaining the coherence of the organization's decision-making history and surfacing when that coherence breaks down.

Implications for engineering:
- Design the doctrine-service with an extensible query interface, not a fixed set of endpoints
- The relationship graph is the most important internal data structure — invest in it
- Staleness and contradiction detection will accumulate rules over time; make the rule system pluggable
- Sukuna v2 is the primary consumer; design the API contract with Sukuna's needs in mind

---

## Ontology Explosion Risk

The object model is currently at the right level. Protect it.

The pressure to add new object types will be continuous: "what about Milestone?", "what about Meeting Notes?", "what about Hypothesis?", "what about Sprint?"

**Rule:** a new object type requires a demonstrated retrieval failure with existing types. Not theoretical elegance. If a Decision, Proposal, or Workstream can represent the concept adequately, it should.

Current object types (6 markdown-resident, 4 runtime shapes) are sufficient for V2 Phase 2 work. Any additions require explicit justification.

---

## Context Layering Principle

In large-context systems, the problem is attention allocation, not token capacity. The ContextBundle priority stratification (`core_operational_state` → `active_doctrine` → `recent_context` → `historical_context` → `expandable_context`) reflects this.

As context windows grow, the temptation will be to dump everything into the bundle. Resist it. The stratification should remain; what changes is how much goes into each layer. `expandable_context` is the safety valve — it exists to be fetched on demand, not pre-loaded.
