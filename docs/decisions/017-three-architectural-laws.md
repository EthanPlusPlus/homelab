# Decision 017 — Three Permanent Architectural Laws + Layer 2 Service Rule

## Status
Adopted

## Date
2026-05-16

## Context

Architectural drift in Layer 2 was identified across the Sukuna 2026-05-15 pass and the
ChatGPT review that followed. Three patterns kept recurring:

1. The boundary between structural canon state and interpretive synthesis was implicit, and
   was being blurred in proposed Phase 3 designs (a single canon-maintenance-service that
   owned both graph queries and LLM synthesis).
2. The boundary between embedding and synthesis providers was clear, but the broader question
   of how runtime providers compose was unprincipled.
3. The Claude-coupling problem the V2 masterplan was designed to escape was *worsening*
   despite V2 work, because every new Layer 2 capability shipped as an MCP tool first and an
   HTTP contract second (or third, or never documented).

These are not implementation issues. They are governance gaps. Without explicit laws, Layer 2
will continue to converge on Claude-Code-shaped surfaces because that is the only consumer
currently exerting pressure.

## Decision

Adopt three permanent architectural laws governing all future Layer 2 work, and a concrete
Layer 2 Service Rule that gives the laws operational teeth.

---

### Law 1 — Structural truth is deterministic

Canon state, lifecycle, relationships, supersession, metadata integrity:

- deterministic,
- inspectable,
- reproducible.

No hidden model reasoning is permitted in the structural layer. If a capability requires
semantic judgment (contradiction detection, drift analysis, semantic equivalence), it does
not belong in the structural layer.

**Owns:** lifecycle state, supersession graph, adjacency maps, stale-rule evaluation,
retrieval topology, relationship traversal, metadata reconciliation.

---

### Law 2 — Interpretation is probabilistic

Summaries, contradictions, organizational tensions, narrative synthesis:

- model-generated,
- revisable,
- provenance-bound,
- non-authoritative.

Interpretive outputs are never canon. They may be retrieved, displayed, and acted upon, but
they cannot enter `active_doctrine` and cannot override structural truth.

**Owns:** contradiction analysis, drift analysis, onboarding synthesis, continuity reports,
unresolved tension synthesis, organizational narrative generation.

---

### Law 3 — Capability contracts are primary

All runtimes — Claude, GPT, local inference, web UI, CLI, automation jobs — consume the same
Layer 2 capability contracts. Adapters are disposable; contracts are not.

The contract surface is the architecture. The adapter surface is convenience.

---

### Layer 2 Service Rule (concrete form of Law 3)

Every Layer 2 capability MUST have, in this order:

1. **Canonical HTTP/API contract** — the authoritative interface.
2. **Typed request/response schema** — documented, versioned.
3. **Capability-contract documentation** in `architecture/phase1/capability-contracts.md`.
4. Runtime adapters MAY exist (MCP tools, CLI commands, web endpoints, etc.).
5. Adapters MUST be thin wrappers only — no logic that does not exist in the HTTP contract.

This means MCP is a transport, not the architecture. Same for the CLI. Same for any future
web frontend.

**Enforcement:** A capability that ships only an MCP tool, with no documented HTTP contract,
is a violation. Existing violations (workflow-state-service has 6 MCP tools and partial HTTP
documentation) are technical debt to be paid down, not precedent to follow.

## Rationale

**Why these three laws, not more.** Laws need to be few enough to remain memorable and
enforceable. These three cover the architectural failure modes actually observed: blurring
structural and interpretive (Law 1+2), and runtime coupling (Law 3). More laws would dilute
attention; fewer would underspecify the structural/interpretive split.

**Why the Service Rule is part of this decision, not separate.** Law 3 without the Service
Rule is aspirational. The Service Rule is the operational mechanism that makes Law 3 enforce
itself. Splitting them across decisions would let Law 3 become a quote-able principle that
nothing in the codebase actually obeys.

**Why now.** The surface area is still small. Workflow-state-service shipped MCP-first; the
cost to backfill HTTP contracts is days. If Phase 3 ships under the same pattern, the cost
becomes weeks per service, and by the time a second runtime arrives the system is shaped for
Claude regardless of intent. The masterplan principle "Loose coupling everywhere" is being
honored on paper and violated in code; this decision closes that gap.

## Consequences

- **Phase 3 work is gated by these laws.** doctrine-service and synthesis-service must ship
  HTTP-first per the Service Rule, with capability-contract documentation as a deliverable.
- **Existing capability-contracts.md is canonical.** It must be kept current with what's
  actually shipped. The drift between what it describes (`retrieve / summarize / synthesize /
  hydrateSession / generateOperationalBrief`) and what's exposed (`search_docs / get_context /
  start_session / ...` MCP tools) is technical debt under Law 3.
- **workflow-state-service technical debt:** HTTP endpoints under `/workflow/*` exist but are
  not documented in capability-contracts.md. Owed: full capability contract documentation,
  schema for Session / Workstream / SessionContext, capability names aligned with the
  contract surface (not the MCP tool names).
- **Phase 3 trio collapses to two:** doctrine-service (Law 1 territory only — structural
  truth) and synthesis-service (Law 2 territory only — interpretive cognition). Sukuna v2
  as a separate service is dropped; "Sukuna" survives as a maintenance-mode brand for
  scheduled invocation of the other two services.
- **Runtime router (Phase 4) is *not* moved earlier by this decision.** Law 3 + Service Rule
  prevent the coupling failure mode without requiring a router. The router is built when
  there is a second runtime to route to.
- **Sukuna passes will now check Layer 2 Service Rule compliance** as a structural finding,
  not an observation.

## Open architectural questions this decision does NOT settle

- The exact boundary between doctrine-service and synthesis-service for borderline cases
  (e.g., supersession suggestions — structural detection of a missing pointer is doctrine;
  recommending *which* doctrine supersedes is synthesis). To be resolved per-capability when
  the services are built.
- Whether `EmbeddingProvider` and `SynthesisProvider` unify into a single `RuntimeProvider`
  abstraction. Still deferred to Phase 4 per [[015-synthesis-provider-abstraction|Decision 015]].
