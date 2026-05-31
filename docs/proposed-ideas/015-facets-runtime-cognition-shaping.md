---
id: "015"
title: Facets — Runtime Cognition Shaping for Prismo
status: superseded
record_type: canonical
date: 2026-05-29
superseded_by: decisions/026-layer-3-5-pipeline-service.md
---

# 015 — Facets: Runtime Cognition Shaping

## Status

Superseded by [[../decisions/026-layer-3-5-pipeline-service|Decision 026]] (2026-05-30).

The concept (Layer 3.5 Runtime Cognition Shaping, the Activation Ladder, Facets as
dynamic system-aware modules) survives intact. Decision 026 provides the concrete
implementation architecture: the Pipeline Service (Activation Router + Context Assembler
+ Response Processor), the generic `Activation` interface, and the YAML-based Facet
definition format. Facets become `ActivationType.FACET` within the broader activation
abstraction.

The V1 SKILL.md prototype (`scripts/facets/architect/SKILL.md`) is superseded by the
`facet.yaml` format; the SKILL.md becomes a thin adapter stub.

---

## The Problem

The failures Prismo has experienced are rarely pure intelligence failures.
They are framing failures. Perspective failures. Operational-context failures.

The pgvector migration broke doctrine-service not because the model lacked software
knowledge — it failed because no active migration cognition existed at the moment of
action. The model reasoned from general principles rather than from inside Prismo's
specific operational reality.

Memory files and CLAUDE.md cannot fix this. They are passive and undifferentiated —
they apply uniformly to everything. What's needed is *selective, targeted context
activation at the moment a specific type of work begins.*

---

## The Concept

A **Facet** is a runtime cognition shaping module.

A Facet does not replace the runtime.
A Facet does not become an agent.
A Facet does not autonomously own decisions.

Instead, a Facet:

- activates a perspective
- loads targeted context from Prismo's live state
- attaches operational heuristics and guardrails
- shapes the reasoning environment before reasoning occurs
- exposes relevant capabilities for the task at hand

The runtime remains the same intelligence. The Facet changes how that intelligence
is contextualized.

**The critical distinction:**

Claude's built-in skills are static markdown instructions. They reframe the model
but they do not know live system state, current doctrine, active decisions, runtime
topology, review queue state, recent migrations, or operational history.

Prismo Facets are dynamic and system-aware. A Facet can query canon, hydrate recent
decisions, inspect workflow state, attach operational heuristics, activate retrieval
scopes, invoke synthesis patterns, pull prior-art findings, inspect runtime topology,
and expose specialized tools — before the model begins reasoning.

This is not prompt engineering. This is runtime cognition shaping.

---

## Architectural Position

Prismo's four layers:

- Layer 1 — Durable truth (canon, git, approved decisions)
- Layer 2 — Operational/workflow state (review queue, captures, sessions, topology)
- Layer 3 — Runtime intelligence abstraction (providers, execution modes, roles)
- Layer 4 — Interfaces/adapters (CLI, web, mobile, WhatsApp, ambient)

Facets reveal a missing layer:

**Layer 3.5 — Runtime Cognition Shaping**

This layer determines:

- what context activates
- what doctrine matters
- what perspectives load
- what capabilities attach
- what synthesis modes engage
- what reasoning posture applies
- what operational state becomes relevant

Interfaces remain thin. Runtimes remain swappable. Specialization becomes composable.

---

## The Activation Ladder

The critical design constraint: Facets must NOT become V1-style overhead.
Prismo already learned this lesson with Hermes — every prompt triggering retrieval,
retrieval triggering summarization, token usage exploding, usability degrading.
That was structurally correct but operationally wrong.

Facets are lightweight by default, selectively activated, layered, and cost-aware.

```
L0 — Base Runtime
     Normal conversational model. Fast. Cheap. No orchestration overhead.
     No Facets active.

L1 — Session Hydration (already exists)
     [V2 HYDRATED CONTEXT] — active doctrine, recent changes, workflow state,
     session continuity. Ambient and cheap. Runs on every session.
     This is a session-scoped, undifferentiated, always-on primitive Facet.

L2 — Facet Activation
     Targeted cognition shaping for the task at hand.
     Activated explicitly (/architect, /migration, /sukuna, /review)
     or contextually (system detects the nature of work beginning).
     Primarily deterministic: retrieval, filtering, state hydration,
     topology inspection, heuristics, tool exposure, guardrails.
     No additional AI calls required for most Facets.

L3 — Optional Intelligence Augmentation
     Only when it materially improves the outcome.
     Prior-art analysis, synthesis generation, semantic conflict detection,
     doctrine interpretation, architectural comparison.
     Deliberate invocation only — never hidden mandatory infrastructure.
     Side intelligences (Haiku, API calls, local models) live here.
```

The abundant-context-window mindset does NOT mean "inject everything all the time."
It means "the system has access to abundant context and can intelligently shape
cognition when necessary." Those are fundamentally different things.

---

## What a Facet Contains

A Facet is a structured cognition augmentation module, not a markdown blob.

```
Facet
  identity          — name, purpose, version
  activation        — conditions under which this Facet is relevant
  context_loaders   — what to retrieve from canon, workflow, topology before reasoning
  doctrine_refs     — which decisions and architectural laws govern this domain
  retrieval_scopes  — which MCP queries to run on activation
  heuristics        — operational guardrails and reasoning biases for this task type
  capability_attach — which Prismo tools/modes become relevant
  synthesis_hooks   — whether and when to invoke L3 intelligence augmentation
  topology_rules    — which runtime roles are visible/relevant
```

Deterministic components (retrieval, filtering, state hydration) remain deterministic.
Interpretive reasoning remains inside the main runtime.
This separation preserves modularity.

---

## Example Facets

### Architect Facet (`/architect`)

Activates:
- Active decisions and architectural laws (Decisions 017–025)
- Runtime topology — current roles, execution modes, authority boundaries
- Open proposed-ideas and unresolved tensions
- Prior-art findings relevant to the domain being discussed
- Contradiction sensitivity heuristic
- Modularity constraint checker

Purpose: Architectural reasoning from inside current system reality rather than
from generic software engineering principles. Prevents the framing drift that
produces architecturally inconsistent proposals.

---

### Migration Facet (`/migrate`)

Activates:
- Interface dependency tracing — grep all call sites before changing any signature
- Migration doctrine — what changed, what's affected, what tests cover it
- Rollback awareness — what data exists, what would be lost, what can't be undone
- Smoke test checklist — every registered route gets a response check post-migration
- Service Rule gate — verify no undocumented routes before marking complete

Purpose: Prevent the class of failures where structural changes are made without
full call-site awareness. The doctrine bug would not have happened with this Facet
active — interface changed, call site in doctrine/router.py missed, nothing caught it.

---

### Sukuna Facet (`/sukuna`)

Activates:
- Observation framing — consistency, structural findings, interpretive thinking
- Review queue awareness — what ReviewItems exist, what's pending
- Unresolved tensions and open captures
- Recent changes (last 5-10 entries)
- Synthesis outputs and their status
- Directed focus (what area to audit)

Purpose: Shifts into the Sukuna perspective — not "run these audit steps" but genuine
consistency checking and reflective observation grounded in current system state.

---

### Review Facet (`/review`)

Activates:
- Pending ReviewItems with full proposal context
- Source captures that generated each item
- Decision 021 human-judgment boundary principles
- Approval/rejection patterns from history
- Suggested destination validation

Purpose: Human-judgment mode — evaluate proposals against canon doctrine and
organizational direction rather than general software quality.

---

## Facets Are Not Agents

Prismo intentionally preserves:
- one main runtime in the driver seat
- visible cognition
- observable reasoning topology
- human-led architectural judgment

Facets must not spawn hidden autonomous systems.

```
Facet
→ loads context + attaches capabilities
→ main runtime reasons with that context
→ optional: intentional L3 augmentation when explicitly warranted
```

This keeps billing understandable, cognition observable, reasoning centralized,
topology coherent, and architectural control human-led.

---

## Facets as the Unifying Layer

Prismo currently has many powerful but somewhat disconnected pieces:

synthesis-service, workflow-state-service, session hydration, runtime topology,
prior-art analysis, review queues, doctrine, captures, continuity, retrieval,
provider abstraction, operational intelligence.

Facets become the composition layer that assembles those primitives into coherent
runtime behavior for specific task contexts. Not feature accumulation — capability
composition.

A Facet should not hardcode behavior. It should compose existing capabilities.
Retrieval remains separate. Synthesis remains separate. Workflow remains separate.
Doctrine remains separate. Facets shape how the runtime uses them together.

---

## Why This Is Future-Proof

As models improve:
- static prompts become obsolete
- rigid workflows become obsolete
- procedural rituals become obsolete

But Facets remain valuable because they are not intelligence patches.
They are operational context loaders, cognition shapers, system capability compositors,
runtime perspective activators.

Better models likely make Facets MORE powerful — a more capable runtime can utilize
richer organizational context more effectively.

The future-proofing strategy: keep intelligence centralized in the runtime, keep
capabilities modular, keep Facets lightweight and compositional, allow intelligence
augmentation only where it materially improves outcomes.

---

## Prior-Art Findings (2026-05-29)

Research surveyed: Context Engineering (Gartner 2025), Semantic Kernel, MemGPT/Letta,
DSPy, AIOS (COLM 2025), PersonaFlow (ACM DIS 2025), Anthropic production patterns.

**Closest prior art:**
- *Context Engineering* (2025 discipline) — describes content curation for LLM context
  windows. Addresses *what* goes in context, not *how reasoning is framed*. Vocabulary
  overlap but different axis.
- *Semantic Kernel plugins* — composable capability modules. Tell the LLM what it CAN
  do. Facets tell the runtime how to FRAME what it's doing. Tool selection vs. cognition
  shaping.
- *PersonaFlow* — dynamic expert persona simulation for research ideation. Closest to
  perspective activation. But personas are static domain experts; they do not query live
  organizational state or compose with operational doctrine.
- *MemGPT/Letta* — virtual context management, persistent memory. What the model
  remembers across sessions, not what perspective it inhabits for a task.
- *AIOS* — kernel-level scheduling for concurrent LLM agents. Infrastructure, not
  cognition. Built for multi-agent concurrency; Facets explicitly resist autonomy.

**The genuine gap none of them fill:** Organizational grounding as a first-class runtime
concern — dynamically composing live decisions, doctrine, topology, workflow state, and
operational history into a coherent reasoning frame, selectively activated, cost-aware,
and non-autonomous. The L0/L1/L2/L3 graduated activation ladder with explicit cost
awareness appears nowhere. The "main intelligence stays in the driver seat" constraint
as an explicit architectural principle appears nowhere — existing systems push toward
multi-agent autonomy. Facets deliberately resist it.

**Verdict:** Design space is genuinely open. Adopt the vocabulary from Context
Engineering where it fits ("context shaping") but the concept is Prismo-native.

---

## Open Design Questions

1. **Activation model precedence** — when explicit (/architect) and ambient (session
   hydration) Facets are both active, how do they compose? Union of contexts, or does
   the explicit Facet override the ambient layer?

2. **Facet storage** — Facets live in `~/canon/homelab/scripts/facets/` and symlink
   into `~/.claude/skills/`. Are they pure markdown or do they reference Prismo MCP
   calls that execute at activation? The dynamic capability (querying canon) requires
   the MCP to be reachable at activation time.

3. **Facet versioning** — Facets reference specific decisions and architectural state.
   As the system evolves, Facets need to stay current. Who owns that? Should Sukuna
   passes include a Facet staleness check?

4. **Composition** — can Facets be layered? E.g. `/architect` + `/review` active
   simultaneously. If so, what's the composition rule for conflicting heuristics?

---

## Relationship to Existing Architecture

- [[../decisions/016-session-hydration-replaces-warmup|Decision 016]] — session
  hydration is L1 in the Facet activation ladder. Facets are the L2 generalization.
- [[../decisions/025-runtime-intelligence-layer-topology|Decision 025]] — runtime
  topology is what the Architect Facet inspects. Facets compose what topology exposes.
- [[../decisions/017-three-architectural-laws|Decision 017]] — Law 3 (capability
  contracts are primary) governs how Facets expose capabilities without coupling.
- [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]] — the Review
  Facet is the cognition layer above the review-queue infrastructure.
