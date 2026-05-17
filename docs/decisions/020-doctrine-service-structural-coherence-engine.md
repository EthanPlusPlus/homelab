---
id: "020"
title: doctrine-service — structural coherence engine
status: active
record_type: canonical
date: 2026-05-16
---

# Decision 020 — doctrine-service: structural coherence engine

## Status
Adopted

## Date
2026-05-16

## Context

Phase 3 is unblocked ([[019-lifecycle-loop-closure-pattern|Decision 019 annotation 2026-05-16]]).
doctrine-service is the next concrete build, but its scope has so far only been sketched
indirectly through:

- [[013-v2-masterplan-adopted|Decision 013]] — Phase 3 trio (doctrine, synthesis, Sukuna v2) listed
- [[017-three-architectural-laws|Decision 017]] — Law 1 territory enumerated (lifecycle state,
  supersession graph, adjacency maps, stale-rule evaluation, retrieval topology, relationship
  traversal, metadata reconciliation)
- [[018-synthesis-provenance-and-recursion-prevention|Decision 018]] — provenance and
  record_type separation, with doctrine-service named as the owner of source-hash drift detection

This is the architectural scoping decision. Locking the boundary before implementation
pressure muddies it — no Phase 3 code exists yet, the laws are written, the lifecycle loop
is tested. Ideal timing.

## Decision

**doctrine-service is a structural coherence engine.** It owns deterministic organizational
coherence. It does not interpret, summarize, narrate, or score.

Framing this as a *coherence engine* rather than "canon intelligence" or "maintenance AI"
is deliberate — it prevents synthesis creep. The moment doctrine-service starts generating
language, it stops being trustworthy infrastructure.

### Core test — self-evident vs arguable

The single heuristic that governs every scoping question for doctrine-service:

> **Is this output's meaning self-evident from the data, or does it require argument?**

- A count is self-evident. Nobody argues what `stale_count: 14` means.
- A ratio is self-evident. `supersession_coverage_ratio: 0.91` is what it is.
- A weighted composite is NOT self-evident. `canon_health: 72` requires asking why
  broken links count 5× and stale items count 2× — those weights are governance opinions
  pretending to be infrastructure.

This is sharper than "deterministic vs probabilistic" because weighted-deterministic
formulas still smuggle interpretation through the weights. The real line is whether the
output's semantics require human judgment to assign.

**Doctrine produces measurements. Synthesis produces judgments.** That's the architecture.

### Day 1 capabilities (committed surface)

1. **Staleness evaluation** — inherits `/stale-items` and `/workflow/stale/ack` from Phase 2.5
   as primary contracts (no redesign). Owns proposed/experimental/superseded rules,
   acknowledgment state, threshold tuning.
2. **Supersession integrity (minimal)** — owns the existing `superseded_missing_pointer`
   rule as the floor. Surface committed-to: broken chains, cycles, orphaned superseded docs,
   multiple-active conflicts. Built incrementally as the canon shape demands it, not all at
   Day 1.
3. **Metadata reconciliation** — owns canon linting: missing lifecycle fields, invalid
   statuses, malformed frontmatter, duplicate IDs, invalid record_type values. Prevents canon
   entropy at the indexer boundary.
4. **Provenance integrity (Decision 018)** — owns enforcement of: synthesized records tagged
   correctly, synthesized records excluded from doctrine retrieval, provenance pointers
   present and resolvable, source-bundle references valid, source-hash drift detection. This
   is the mythology-prevention firewall.
5. **Structural relationship topology** — deterministic graph traversal only. "What
   decisions affect this project?" "Which proposals are unresolved?" "Which docs are
   downstream of this item?" Graph mechanics, not cognition. Becomes the substrate
   synthesis-service consumes later.

### Deferred capabilities (scope committed, build later)

- **`reviewed_at` separation** — see capture 30230ded. Not needed at current single-contributor
  + active-maintenance scale. Build when adjacent edits or bulk metadata sweeps start
  corrupting git-touch as a staleness proxy.
- **Wikilink validation** — requires a real markdown parser; non-trivial. Add when canon
  size makes broken links a measurable retrieval problem.
- **Full supersession graph traversal** — past the minimal `missing_pointer` rule. Add as
  supersession volume justifies it.

### Explicitly out of scope (synthesis-service territory)

doctrine-service does NOT do:

- summarization
- onboarding generation
- operational briefs (the existing `/brief` endpoint migrates to synthesis-service when built)
- canon narratives
- strategic recommendations
- **semantic** contradiction interpretation (two records that *mean* opposing things)
- **semantic** drift interpretation (narrating what changed in meaning)
- **scores, weighted composites, rankings by inferred importance**, or any output whose
  semantics aren't self-evident from the data
- inferences of "health", "quality", "risk", "urgency", "importance", "concern" — even
  computed deterministically
- prioritization that infers importance ("you should work on X next")

### Boundary clarifications

Several exclusions have a *structural* form that IS doctrine's job. The line is "does this
require human judgment to interpret?"

| Capability | Structural form (doctrine ✅) | Interpretive form (synthesis ❌) |
|---|---|---|
| Contradiction detection | `status=active AND status=superseded` on same item; broken supersession chains | Two decisions whose prose semantically conflicts |
| Drift detection | source-hash drift between a synthesized record and its sources (Decision 018) | Narrating what the drift means or whether it matters |
| Prioritization | Sort/filter by any explicit scalar (`sort_by=stale_days`, `filter=missing_pointer`) | "Most important", "most urgent", "you should look at this" |
| Aggregation | Counts, ratios, distributions, age statistics, deltas — primitives | Composite "health" or "quality" scores |
| Health reporting | Expose primitives consumers can compose into dashboards | "Canon is in good shape" / `canon_health: 72` |

**Rule of thumb**: if a contributor would argue with the output's *meaning* (not its
correctness), it's interpretation and belongs to synthesis. If they'd only argue with the
*math*, it's a doctrine bug.

Future contributors should feel friction when attempting to add interpretation to
doctrine-service.

### Core invariant (directionality)

> **doctrine-service outputs may influence synthesis, but synthesis outputs may never
> modify doctrine state directly.**

This is the long-term stability property. Without it, synthesized narratives eventually
start rewriting organizational truth recursively — the exact failure mode Decision 018 was
written to prevent (organizational mythology). Decision 018 enforces it at the retrieval
layer (synthesized records excluded from `active_doctrine`); this decision enforces it at
the *write path* (synthesis-service cannot call doctrine-service write endpoints).

Operationally: doctrine-service exposes read endpoints synthesis may consume freely.
Write endpoints (ack, supersession updates, metadata reconciliation actions) require an
actor context where `actor.kind != "synthesis"`. Synthesis surfaces recommendations
through a separate review queue; only a human (or a deterministic doctrine rule) applies them.

### Module-first, service-later

doctrine-service starts as a **module inside context-server**, not a separate process.

Reasons:
- same storage (ChromaDB + SQLite workflow-state)
- same metadata pipeline (indexer)
- same deployment lifecycle
- same operational cadence
- no scale, ownership, or runtime divergence yet

Premature process split costs: duplicated models, duplicated DB access, distributed
debugging, fake service boundaries that calcify wrong.

Split when (and only when) any of these become true: scaling differs, deployment cadence
differs, ownership differs, storage differs, runtime requirements differ.

The **architectural boundary** matters now and is enforced by this decision + the Service
Rule. The **process boundary** does not.

### Capability contract surface (Decision 017 discipline)

Contracts defined first, implementations follow. Initial surface:

```text
evaluateStaleness(project?) -> stale_items[]                   # already shipped (/stale-items)
acknowledgeStaleness(item_id, actor, resolution, note)         # already shipped (/workflow/stale/ack)
validateDoctrine(project) -> violations[]                       # new — runs all reconciliation rules
getSupersessionGraph(project) -> nodes[], edges[]              # new — read-only graph
resolveRelationships(item_id) -> upstream[], downstream[]      # new — deterministic traversal
validateProvenance(item_id?) -> violations[]                   # new — Decision 018 enforcement
```

HTTP endpoints implement contracts; MCP tools wrap HTTP; future runtimes consume HTTP
directly. New endpoints land under `/doctrine/*` namespace. capability-contracts.md HTTP
Endpoint Mapping table updated alongside each addition (Service Rule fails the app
start otherwise — this is the discipline working).

## Rationale

**Why "structural coherence engine" rather than "canon intelligence."** The first framing
is bounded and deterministic; the second invites scope drift toward LLM features. Names
shape what people build. Decision 017 already established the law — this decision picks the
implementation name that reinforces it.

**Why all five Day-1 capabilities, not a smaller subset.** Three of the five (staleness,
supersession-minimal, provenance-integrity) are already partially built or implied by
existing canon. Adding metadata reconciliation and relationship topology rounds out the
"deterministic substrate" that synthesis-service will later consume — splitting the build
across multiple decisions risks each one accidentally encoding interpretation as the loud
edge cases appear.

**Why module-first is non-negotiable.** Every prior premature split in V1 produced
distributed debugging without distributed scale. The Service Rule structurally enforces
the contract boundary; the process boundary adds no architectural value at our scale and
removes a lot of operational simplicity.

**Why the directionality invariant gets a dedicated section.** It is the single most
important property of this architecture. Without it, the system collapses into the
organizational-mythology failure mode within months. With it, synthesis can be as
exploratory and language-heavy as it wants without corrupting truth.

**The deeper architectural property this decision locks in.** Most organizational tools
silently merge two different things: *organizational memory* (what exists, what was
decided, what supersedes what) and *organizational interpretation* (what it means, what
matters, what to do next). The merger is why Notion AI gets messy, why Slack summaries
become accidental truth, why meeting summaries become "official." Prismo, after this
decision, structurally distinguishes them:

- **doctrine-service** owns organizational memory — deterministic, inspectable, never
  editorialized
- **synthesis-service** is a controlled interpretation boundary — explicitly probabilistic,
  explicitly non-canonical, explicitly read-only against doctrine

That separation is the architecture's strongest emergent property. This decision exists
to keep it pure.

## Consequences

- **New endpoint namespace** `/doctrine/*` lands as doctrine-service capabilities ship.
  Each addition updates `architecture/phase1/capability-contracts.md` HTTP Endpoint Mapping
  before deploy (Service Rule fails app start otherwise).
- **No `synthesis` actor may invoke doctrine-service write endpoints.** This is enforced
  at the contract level (actor parameter) — synthesis-service authors who try to bypass
  this hit an explicit rejection, not a silent allow.
- **synthesis-service (when built) reads doctrine outputs as canonical structural truth.**
  Its only path to influence doctrine state is via human-mediated review queues, not
  direct mutation.
- **Module location**: top-level `doctrine/` package (peer to `api/`, `context_mcp/`,
  `workflow/`), mirroring the workflow-state-service precedent. `api/main.py` includes
  the doctrine router via `app.include_router(doctrine_router)`. Split into separate
  process is a future decision, not a current concern.
- **Tests are required**, not aspirational — the precedent set by
  `tests/test_stale_rules.py` extends: every doctrine rule ships with fixtures covering
  the rule fires correctly, the rule does NOT false-fire, and the rule's output composes
  with ack/dedup.
- **Sukuna's role narrows further** — anything Sukuna currently surfaces narratively that
  doctrine-service can determine deterministically moves into doctrine-service. Sukuna
  retains the genuinely interpretive sections (observations, free-wheel thinking) and
  becomes synthesis-service's first consumer pattern.
- **Phase 3 second service (synthesis-service)** inherits Decision 018 provenance discipline
  + the directionality invariant from this decision from day one. Its own scoping decision
  comes after doctrine-service has at least the Day 1 capabilities live.

## Related captures
- 1801ff71 — V2-pure relocation reframe
- 997091ae — open question: orchestrator-vs-runtime layering
- ff0335a0 — production-state-dependent gates are a code smell
- 30230ded — reviewed_at deferred until scale justifies

---

## Annotation 2026-05-17 — Build resequenced by Decision 021

[[021-reviewitems-as-judgment-boundary|Decision 021]] reframes Prismo's
center of gravity as human judgment boundaries and identifies synthesis-service
+ a review-queue as the next build. doctrine-service Day-1 capabilities are
**resequenced**, not rescoped — every responsibility this decision assigned
to doctrine-service remains valid.

The new sequencing:

1. ReviewItem contract + endpoints (workflow-state-service)
2. Minimal synthesis-service with quality gate
3. `prismo review` CLI surface
4. Observation week
5. doctrine-service Day-1 capabilities (this decision)

Why: until synthesis-service exists, doctrine-service's value (structural
integrity validation, lifecycle enforcement, supersession graph) has no
upstream loop that benefits from it operationally. Pre-approval is synthesis
+ human judgment; post-approval is doctrine. Both are real; only the order
changes.

This decision's scope, capabilities, out-of-scope list, directionality
invariant, and tests-required precedent all remain authoritative.
