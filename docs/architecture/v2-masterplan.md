# Prismo V2 — Foundation, Architecture, and System Design Masterplan

## Founding Statement

Prismo is a cognitive continuity system for collaborative creation.

Its purpose is not to replace humans, nor to become an autonomous artificial organization.
Its purpose is to:

* preserve continuity,
* reduce cognitive fragmentation,
* accelerate collaboration,
* maintain organizational memory,
* enable rapid onboarding,
* support AI-assisted execution,
* and provide a stable substrate beneath a rapidly changing AI ecosystem.

Prismo exists to help intelligent people build ambitious things together without losing context, decisions, momentum, or organizational coherence.

The startup is the center.
Prismo is the enabling substrate.

---

# 1. Core Philosophy

## 1.1 The Mission

Prismo is not a chatbot.
Prismo is not a RAG pipeline.
Prismo is not a homelab.
Prismo is not an AI wrapper.

Prismo is:

> A durable collaborative substrate that coordinates humans, projects, memory, and AI runtimes.

The system should remain useful even if:

* context windows become effectively infinite,
* models improve dramatically,
* new orchestration frameworks emerge,
* local models dominate,
* or AI providers disappear.

Because the real problem Prismo solves is not model memory.
It is organizational continuity.

---

## 1.2 Foundational Principles

### Durable over trendy

Favor:

* markdown
* git
* filesystems
* HTTP APIs
* containers
* portable schemas
* composable services
* open protocols

Avoid hard dependence on:

* proprietary workflows
* model-specific assumptions
* deeply coupled orchestration frameworks
* transient AI ecosystems

---

### Loose coupling everywhere

No model is permanent.
No interface is permanent.
No orchestration framework is permanent.

Prismo owns:

* continuity
* canon
* retrieval
* workflows
* organizational memory
* project structure
* operational semantics

Models are replaceable runtimes.

---

### Humans retain authority

Prismo may automate:

* synthesis
* maintenance
* indexing
* drift detection
* summarization
* reconciliation
* onboarding generation
* operational context generation

Prismo should NOT autonomously:

* redefine strategic direction
* alter organizational doctrine independently
* make irreversible decisions
* rewrite canon without review

Automation exists to reduce maintenance pressure, not replace human judgment.

---

### Real collaboration over technical elegance

The system must remain usable by:

* non-technical founders,
* future collaborators,
* intelligent generalists,
* contributors with no infrastructure experience.

If a system design only works for infrastructure-heavy engineers, it is incomplete.

---

### Organizational continuity is the invariant

The most important thing Prismo preserves is:

* shared understanding,
* decisions,
* project identity,
* team memory,
* operational continuity.

Everything else is replaceable.

---

# 2. Current Context

## 2.1 Existing Assets

Prismo V1 already contains strong foundations.

### Durable substrate already exists

* canon/
* project isolation
* decisions/
* proposed-ideas/
* runbooks/
* architecture/
* git-based workflows
* markdown documentation
* context-server
* semantic indexing
* retrieval APIs
* Obsidian sync
* CLI automation

These are not failures.
These are the foundation.

---

## 2.2 Current Problems

### Workflow enforcement is advisory

Current behavior depends heavily on:

* CLAUDE.md
* prompt instructions
* session rituals
* behavioral compliance

This causes:

* workflow drift
* inconsistent discipline
* unreliable operational behavior
* model-specific coupling

Behavior must increasingly become structural.

---

### Stale doctrine

Decisions and proposals accumulate without lifecycle enforcement.

This causes:

* outdated assumptions
* contradictory canon
* proposal graveyards
* retrieval pollution
* organizational confusion

The system needs:

* lifecycle transitions
* stale detection
* supersession tracking
* review pressure

---

### Multi-user was bolted on

Prismo V1 emerged from a primarily single-user workflow.

Future architecture must assume:

* multiple collaborators
* different technical levels
* different access patterns
* varying permissions
* shared organizational memory

---

### Non-technical access is weak

Current interaction assumes:

* terminals
* SSH
* git
* CLI workflows

This is unsuitable for:

* founders
* collaborators
* future contributors
* mobile interaction

---

### Model coupling exists

Current workflows are deeply Claude-centric.

Future architecture must:

* abstract model runtimes
* support local models
* support multiple providers
* support future runtimes
* preserve continuity independent of model vendor

---

# 3. System Vision

## 3.1 Long-Term Vision

Prismo becomes:

> A modular AI-native collaborative operating substrate.

It provides:

* organizational memory
* project continuity
* retrieval
* context synthesis
* operational state
* onboarding
* workflow coordination
* AI runtime orchestration
* collaborative interfaces

While remaining:

* modular
* replaceable
* composable
* model-agnostic
* infrastructure-portable

---

## 3.2 What Prismo Is NOT

Prismo is NOT:

* a monolithic AI platform
* a proprietary ecosystem
* an all-knowing autonomous organization
* a fully self-evolving agent civilization
* a replacement for product execution
* an excuse to avoid shipping

The startup remains the center.

---

# 4. Architectural Model

## Layered Architecture

## Layer 1 — Durable Substrate

The permanent organizational layer.

### Responsibilities

* canon storage
* project isolation
* markdown persistence
* git history
* decisions
* organizational memory
* project structure
* identity
* retrieval schemas

### Characteristics

* slow-changing
* durable
* portable
* human-readable
* tool-agnostic

### Technologies

* markdown
* git
* filesystem hierarchy
* YAML metadata
* HTTP contracts
* containers

### Design Rules

* No model-specific assumptions
* No vendor lock-in
* No hidden proprietary state
* Everything inspectable by humans

---

## Layer 2 — Operational Services

The intelligence coordination layer.

This is the hardest and most important layer.

### Responsibilities

* indexing
* retrieval
* context synthesis
* stale doctrine detection
* lifecycle management
* onboarding generation
* workflow state
* operational briefs
* canonical conflict detection
* session state
* organizational synthesis
* orchestration contracts
* metadata enrichment

### Key Insight

Layer 2 creates intelligence without coupling intelligence to a specific model.

This layer transforms Prismo from static documentation into active organizational cognition.

---

### Core Services

#### context-server v2

The canonical retrieval and synthesis service.

Responsibilities:

* semantic retrieval
* hybrid search
* project-scoped queries
* metadata-aware retrieval
* context bundles
* operational brief generation
* stale-content surfacing
* active decision prioritization

Potential APIs:

* /query
* /context
* /brief
* /project-state
* /recent-changes
* /decision-graph
* /stale-items
* /onboarding

---

#### doctrine-service

Tracks:

* active decisions
* superseded decisions
* archived decisions
* unresolved proposals

Supports:

* supersession chains
* stale detection
* lifecycle enforcement
* contradiction surfacing

---

#### synthesis-service

Generates:

* project summaries
* onboarding packets
* architectural overviews
* change summaries
* operational state reports
* relationship maps

---

#### workflow-state-service

Maintains:

* active work
* current focus
* unresolved issues
* session continuity
* project health
* operational timelines

This replaces reliance on behavioral prompt rituals.

---

#### Sukuna

> **Annotation 2026-05-19:** The "Sukuna v2" framing (separate Layer 2 service) was dropped.
> Sukuna remains a Claude agent (scripts/sukuna) that writes drafts/ for human review. Its
> eventual refactor is tracked in [[../proposed-ideas/013-sukuna-as-synthesis-consumer|Proposed-idea 013]]:
> Sukuna becomes a synthesis-service consumer, emitting ReviewItems instead of markdown reports.
> The responsibilities listed below remain valid as the intended scope; the implementation path changed.

Canon maintenance agent. Responsibilities:

* drift detection
* stale proposal surfacing
* contradiction detection
* synthesis suggestions
* orphaned docs
* broken links
* metadata reconciliation
* lifecycle enforcement reminders

Important: Sukuna assists maintenance. It does not own organizational authority.

---

## Layer 3 — Runtime Intelligence Layer

The swappable model runtime system.

### Core Principle

Models are runtime providers. Not organizational centers.

### Responsibilities

* model routing
* provider abstraction
* capability dispatch
* inference orchestration
* cost optimization
* latency optimization
* local/cloud selection

---

### Runtime Categories

#### Coding Runtime

Used primarily by Ethan.

Examples:

* Claude
* GPT
* local coding models
* future agentic IDE systems

---

#### General Collaboration Runtime

Used by teammates.

Examples:

* local LLMs
* small/medium hosted models
* project-aware assistants

Requirements:

* low cost
* high availability
* conversational usability
* context integration

---

#### Specialized Runtimes

Potential future systems:

* retrieval-specialized
* planning-specialized
* summarization-specialized
* synthesis-specialized
* research-specialized

---

### Capability Contracts

The runtime layer should expose capabilities rather than model assumptions.

Examples:

* retrieve()
* summarize()
* synthesize()
* codegen()
* plan()
* critique()
* explain()
* analyze()

Providers implement capabilities. This enables runtime swapping.

---

## Layer 4 — Human Interaction Layer

The organizational interaction surface.

### Important Clarification

Layer 4 is NOT abstraction for its own sake.

It exists to:

* mediate interaction with the substrate
* preserve continuity
* maintain project awareness
* enforce organizational coherence
* capture signal into canon

Without this layer, interactions become fragmented and ephemeral.

Layer 4 hides volatility (which model, which version) while exposing continuity (organizational memory, project state, decisions).

---

### Primary Interface: Web UI

> **Annotation 2026-05-19:** Decision 021 inverted this priority. CLI ships first — web UI does
> NOT ship first. CLI is the fastest ontology validation loop for the ReviewItem contract.
> Web UI investment happens after CLI proves the ReviewItem shape via observation week.
> See [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]] § "Why CLI surface first."

The main collaborative interface.

Target users: Shrey, Kyle, future collaborators, Ethan.

#### Core Requirements

**Conversational interaction** — users ask questions, brainstorm, retrieve context, understand project state, and contribute ideas without needing technical workflows.

**Project awareness** — the UI must clearly distinguish startup-wide context from project-specific context. Users should always know where they are and what decisions apply.

**Contribution capture** — natural language contributions become structured canon entries, indexed automatically, attached to projects, with authorship preserved.

**Dashboards** — active projects, unresolved proposals, recent changes, active decisions, organizational summaries, project health, context snapshots.

---

### Secondary Interfaces (future)

* WhatsApp (nearest-term — team already uses it)
* Discord / Telegram / Slack
* Mobile app
* IDE integrations
* Voice

The interface layer should remain modular.

---

# 5. Canon Design

## 5.1 Canon Philosophy

Canon is:

* durable organizational memory
* structured project cognition
* long-term continuity

Canon is NOT:

* random note storage
* infinite undifferentiated retrieval
* passive documentation

---

## 5.2 Lifecycle States

Minimal lifecycle model:

### active

Currently valid and operational.

### superseded

Replaced by newer canon. Requires pointer to replacement. Preserved for historical context.

### archived

No longer operationally relevant. Not necessarily wrong.

---

## 5.3 Lifecycle Enforcement

The key problem is not taxonomy. The key problem is transition pressure.

Potential enforcement systems:

* Sukuna reviews
* periodic audits
* migration reviews
* stale proposal scans
* unresolved-item queues

---

## 5.4 Metadata Standards

Every major canon object should eventually support:

* author
* project
* created_at
* updated_at
* status
* related decisions
* superseded_by
* tags
* confidence
* review cadence

---

# 6. Multi-User Design

## 6.1 Core Users

### Ethan

Role: primary engineer, infrastructure architect, systems operator, technical execution.

### Shrey

Role: finance perspective, business pressure, strategic questioning, startup direction.

### Kyle

Role: systems thinking, critical questioning, conceptual refinement, interdisciplinary insight.

Circle is growing. Design must accommodate new contributors without Ethan being the onboarding bottleneck.

---

## 6.2 Design Constraints

Most collaborators will not:

* use CLI tools
* manage infrastructure
* write canon manually
* understand orchestration systems

The system must remain usable regardless.

---

## 6.3 Contribution Asymmetry

Ethan primarily structures and engineers the substrate.

Other collaborators primarily generate signal: questions, ideas, direction, constraints, strategic insight.

Prismo must capture this signal naturally, without requiring collaborators to adopt new tools or workflows.

---

# 7. Hardware Architecture

## 7.1 Philosophy

The iMac was the incubator. The future server is operational infrastructure.

Infrastructure should support: local inference, modularity, reliability, future expansion, portability.

---

## 7.2 Goals

**Local model capability** — collaborator AI access, always-on inference, low marginal cost, experimentation freedom, privacy, organizational ownership.

**Reliability** — proper server-grade stability, containerized workloads, reproducible deployments, automated backups, monitored services.

**Modularity** — model swapping, provider swapping, workload separation, scalable services.

---

## 7.3 Potential Infrastructure Components

* Proxmox
* Docker
* Kubernetes (optional future)
* GPU inference nodes
* NAS storage
* backup systems
* observability stack
* VPN access
* authentication services

---

# 8. Operational Philosophy

## 8.1 Avoid Infrastructure Narcissism

Prismo exists to accelerate startups, products, collaboration, and execution.

It must never become an infinite self-referential infrastructure project or a substitute for shipping.

---

## 8.2 Build from Real Friction

Prefer solving: actual collaboration pain, actual onboarding pain, actual continuity problems, actual workflow drift.

Avoid building: speculative mega-systems, hypothetical agent societies, unnecessary abstraction, architecture for imagined future problems.

---

## 8.3 Adaptive Evolution

Prismo must evolve continuously. But evolution should preserve continuity, portability, and canon integrity while avoiding over-coupling.

---

# 9. V2 Priorities

## Priority 1 — Architectural Refactor

Define: service boundaries, runtime abstraction contracts, canon lifecycle standards, metadata standards, retrieval contracts.

This is the conceptual foundation.

---

## Priority 2 — context-server v2

Expand from retrieval service to organizational cognition service.

Key features: context bundles, operational briefs, project snapshots, lifecycle awareness, metadata-aware retrieval, stale doctrine surfacing.

---

## Priority 3 — Runtime Abstraction Layer

Remove hard dependence on any provider. Support local inference, Claude, GPT, and future providers through capability contracts and swappable backends.

---

## Priority 4 — Minimal Web Interface

Initial goals: authentication, conversational access, project-aware querying, dashboard basics, contribution capture, organizational visibility.

Avoid overbuilding.

---

## Priority 5 — Canon Lifecycle Enforcement

Implement: stale proposal detection, supersession links, lifecycle transitions, review pressure.

---

# 10. Long-Term Possibilities

Exploratory only. These should emerge from real operational need, not architectural ambition.

* advanced synthesis agents
* collaborative planning systems
* voice interfaces
* proactive organizational maintenance
* timeline reconstruction
* knowledge graphs
* project intelligence maps
* semantic relationship visualization
* autonomous indexing pipelines
* local-first distributed collaboration

---

# 11. Final Architectural Insight

Prismo should not attempt to become the smartest AI system.

Prismo should become the most stable collaborative substrate possible in a rapidly changing AI world.

Models will change. Frameworks will change. Interfaces will change. Infrastructure will change.

The substrate should preserve: continuity, memory, organizational coherence, collaboration, project identity, shared understanding.

That is the durable value.

---

# 12. Final Guiding Principle

Every major decision in Prismo V2 should answer:

> Does this reduce cognitive fragmentation and improve collaborative continuity for the team?

If not, reconsider why it exists.
