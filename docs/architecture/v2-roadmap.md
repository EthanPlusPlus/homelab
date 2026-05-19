# Prismo V2 — Execution Roadmap and System Program

# Purpose of this Document

The Prismo V2 Masterplan defines:

* philosophy,
* architecture,
* layering,
* system direction,
* and organizational principles.

This document exists to:

* operationalize the masterplan,
* define downstream workstreams,
* establish execution order,
* define concrete engineering initiatives,
* prevent architectural drift,
* and transform V2 from a conceptual vision into an active systems program.

This document should be treated as:

> the active implementation roadmap for Prismo V2.

---

# Core Strategic Shift

Prismo V1 was fundamentally:

> a runtime-assisted organizational memory system.

Prismo V2 becomes:

> a persistent organizational cognition substrate with interchangeable AI runtimes.

This changes:

* retrieval assumptions,
* workflow assumptions,
* orchestration assumptions,
* interface assumptions,
* infrastructure assumptions,
* and collaboration assumptions.

The V2 roadmap is therefore organized around:

* operational cognition,
* continuity,
* persistent context,
* modularity,
* and abundance-oriented architecture.

---

# OVERALL EXECUTION STRATEGY

## Strategic Constraints

Prismo must:

* remain modular,
* remain replaceable,
* support future AI systems,
* support local inference,
* support large context windows,
* support persistent working memory,
* support multiple collaborators,
* and avoid model lock-in.

---

## Primary Architectural Principle

The system must increasingly shift from:

* behavioral workflow enforcement

into:

* structural operational state generation.

Meaning:

Prismo itself prepares:

* operational context,
* project state,
* active doctrine,
* unresolved tensions,
* historical continuity,
* and active workstreams.

The runtime receives hydrated organizational state instead of discovering it manually.

---

# ROADMAP STRUCTURE

The roadmap is divided into:

1. Foundational Refactor Program
2. Layer 2 Cognition Systems
3. Runtime Abstraction Systems
4. Infrastructure & Hardware Program
5. Human Interaction Layer
6. Governance & Observability
7. Advanced Systems Research

Each section contains:

* goals,
* engineering targets,
* deliverables,
* dependencies,
* scalability notes,
* and implementation direction.

---

# PROGRAM 1 — FOUNDATIONAL REFACTOR

# Goal

Establish stable architectural contracts before major implementation expansion.

This phase exists to:

* prevent architectural chaos,
* avoid premature coupling,
* establish long-term invariants,
* and create stable internal semantics.

---

# Initiative 1.1 — Canon Audit & Classification

## Purpose

Catalog all V1 assets.

Identify:

* durable primitives,
* stale doctrine,
* coupling points,
* workflow patches,
* accidental complexity,
* and reusable infrastructure.

---

## Deliverables

### New Canon Structures

```text
/canon-v2/
/projects-v2/
/architecture/
/runtime-contracts/
/operational-state/
/services/
```

---

### Audit Artifacts

```text
v1-survivors.md
v1-coupling-map.md
v1-deprecated-patterns.md
v1-service-map.md
```

---

## Key Outcomes

* identify invariant structures,
* identify Claude-specific logic,
* identify lifecycle gaps,
* identify retrieval weaknesses.

---

# Initiative 1.2 — Canon Object Model

# Purpose

Formalize canonical organizational object types.

The current system is mostly unstructured markdown.

V2 introduces:

* lightweight structured metadata,
* lifecycle semantics,
* relationship graphs,
* and operational indexing.

---

## Core Canonical Objects

### Decision

```yaml
id:
title:
status:
created_at:
updated_at:
author:
supersedes:
project:
tags:
```

---

### Proposal

### Project

### Session

### ContextBundle

### OperationalBrief

### RuntimeProfile

### Contributor

### Workstream

---

## Deliverables

* metadata schema standards
* YAML conventions
* lifecycle rules
* relationship rules
* indexing standards

---

# Initiative 1.3 — Lifecycle System Design

## Purpose

Prevent canon entropy.

V1 stores information.
V2 manages information state.

---

## Lifecycle States

### active

Operationally authoritative.

---

### proposed

Unresolved organizational concept.

---

### experimental

Actively being evaluated.

---

### superseded

Replaced by newer canon.

---

### archived

Historical but inactive.

---

## Deliverables

* lifecycle transition rules
* stale detection rules
* review cadence rules
* supersession chains
* historical preservation rules

---

# Initiative 1.4 — Capability Contract Layer

# Purpose

Abstract organizational capabilities from runtime implementations.

This is one of the most critical V2 architectural steps.

---

## Problem

V1 capability assumptions are embedded inside:

* MCP tools,
* CLAUDE.md,
* runtime rituals,
* and prompt ergonomics.

This creates hard coupling.

---

## V2 Direction

Capabilities become:

* provider-independent,
* runtime-independent,
* semantically stable.

---

## Initial Capability Contracts

```typescript
retrieve()
query()
summarize()
synthesize()
plan()
codegen()
review()
analyze()
hydrateSession()
generateOperationalBrief()
```

---

## Deliverables

* capability definitions
* request schemas
* response schemas
* transport abstraction
* runtime compatibility rules

---

# PROGRAM 2 — LAYER 2 COGNITION SYSTEMS

# Goal

Transform Prismo from:

* static retrieval

into:

* operational organizational cognition.

This is the true heart of V2.

---

# Initiative 2.1 — context-server v2

# Priority: CRITICAL

This becomes:

> the canonical cognition orchestration service.

---

# Core Responsibilities

* semantic retrieval
* metadata-aware retrieval
* lifecycle-aware retrieval
* project-scoped retrieval
* operational state generation
* context bundle generation
* operational brief generation
* doctrine injection
* continuity hydration
* unresolved tension surfacing
* relationship traversal
* contributor context tracking

---

# Architectural Direction

The system must evolve beyond:

```text
query -> vector search -> chunks
```

Toward:

```text
organizational state
→ operational synthesis
→ layered retrieval
→ hydrated runtime context
```

---

# Retrieval Pipeline V2

## Layer 1 — Semantic Retrieval

Traditional embeddings.

---

## Layer 2 — Metadata Filtering

Filters by:

* project
* lifecycle state
* recency
* contributor
* workstream

---

## Layer 3 — Doctrine Prioritization

Prioritize:

* active decisions
* unresolved tensions
* operationally relevant canon

---

## Layer 4 — Relationship Expansion

Expand:

* related decisions
* linked proposals
* associated workstreams
* contributor discussions

---

## Layer 5 — Operational Packaging

Generate:

* context bundles
* operational briefs
* project snapshots
* runtime hydration payloads

---

# Key Deliverables

### Context Bundle Engine

Produces:

```json
{
  "project": "Even",
  "active_doctrine": [],
  "recent_changes": [],
  "active_workstreams": [],
  "unresolved_tensions": [],
  "related_history": [],
  "contributor_context": [],
  "retrieval_expansions": []
}
```

---

### Operational Brief Engine

Automatically generates:

* current organizational state
* active project direction
* major unresolved issues
* recent evolution
* recommended focus areas

---

### Session Hydration System

Replaces:

* warm-up conversations,
* manual retrieval loops,
* bootstrap rituals.

The runtime starts hydrated.

---

# Scalability Direction

The retrieval layer must be designed for:

* massive context windows,
* persistent sessions,
* local inference,
* multi-project organizational graphs,
* continuous operational state.

Do NOT optimize for small-context scarcity.

Architect for context abundance.

---

# Initiative 2.2 — Workflow-State Service

# Purpose

Move workflow enforcement into operational infrastructure.

---

# Replaces

* CLAUDE.md rituals
* pull-before-commit discipline
* manual synchronization
* session bootstrap loops
* runtime memory dependence

---

# Responsibilities

* active work tracking
* contributor session tracking
* project state
* operational timelines
* unresolved issue tracking
* concurrency awareness
* active focus detection
* working memory persistence

---

# Key Deliverables

### Session Registry

Tracks:

* active contributors
* active projects
* active workstreams
* runtime sessions

---

### Working State Engine

Maintains:

* active operational context
* evolving session continuity
* persistent organizational memory

---

### Conflict Awareness

Detect:

* overlapping work
* contradictory edits
* competing doctrine changes

---

# Initiative 2.3 — Doctrine Service

# Purpose

Transform doctrine from static markdown into operationally managed organizational memory.

---

# Responsibilities

* lifecycle enforcement
* stale doctrine detection
* supersession management
* contradiction detection
* proposal resolution tracking
* doctrine relationship graphs

---

# Key Deliverables

### Supersession Graph

Maps:

```text
Decision 009
→ superseded by 011
→ refined by 012
```

---

### Doctrine Drift Detection

Detect:

* stale assumptions
* conflicting principles
* unresolved architectural tensions

---

### Review Engine

Schedules:

* doctrine reviews
* stale proposal reviews
* unresolved work reviews

---

# Initiative 2.4 — Synthesis Service

# Purpose

Generate organizational cognition artifacts automatically.

---

# Responsibilities

* onboarding generation
* project summaries
* operational snapshots
* contributor briefings
* change summaries
* relationship synthesis
* continuity reports

---

# Important Principle

Synthesis supports humans.
It does not replace organizational authority.

---

# Initiative 2.5 — Sukuna

> **Annotation 2026-05-19:** The "Sukuna v2 as separate Layer 2 service" framing was dropped.
> Sukuna's refactor path is now: synthesis-service consumer (emits ReviewItems instead of
> markdown drafts). See [[../proposed-ideas/013-sukuna-as-synthesis-consumer|Proposed-idea 013]].
> The responsibilities and constraints below remain valid; the implementation path changed.

# Purpose

Transform Sukuna from:

* Claude agent writing markdown drafts to `drafts/`

into:

* a synthesis-service consumer that emits ReviewItems per finding.

---

# Responsibilities

* stale canon detection
* unresolved proposal surfacing
* orphaned documentation
* metadata reconciliation
* drift detection
* relationship reconciliation
* lifecycle enforcement reminders
* continuity audits

---

# Important Constraint

Sukuna must NOT autonomously:

* rewrite doctrine,
* finalize decisions,
* alter canon authority.

Human review remains mandatory.

---

# PROGRAM 3 — RUNTIME ABSTRACTION SYSTEM

# Goal

Decouple organizational cognition from model vendors.

---

# Initiative 3.1 — Runtime Provider Interface

# Purpose

Treat models as interchangeable runtimes.

---

# Supported Providers

### Hosted

* Claude
* GPT
* Gemini
* future APIs

---

### Local

* Ollama
* vLLM
* llama.cpp
* future inference stacks

---

# Core Deliverables

### Runtime Adapter Interface

```typescript
interface RuntimeProvider {
  query()
  stream()
  embed()
  toolCall()
  summarize()
}
```

---

### Runtime Registry

Tracks:

* provider capabilities
* context limits
* latency
* costs
* specialization

---

### Routing Engine

Dynamically selects:

* coding runtime
* synthesis runtime
* collaborator runtime
* local/cloud routing

---

# Initiative 3.2 — Local Inference Platform

# Purpose

Create organizational AI independence.

---

# Goals

* low marginal cost
* team-wide AI access
* experimentation freedom
* local organizational memory
* runtime portability

---

# Deliverables

### Inference Stack

Potential technologies:

* Ollama
* vLLM
* llama.cpp
* CUDA inference
* GPU scheduling

---

### Local Embedding Service

Dedicated embedding infrastructure.

---

### Runtime Cache Layer

Supports:

* persistent sessions
* retrieval acceleration
* operational state hydration

---

# Initiative 3.3 — Persistent Session Architecture

# Purpose

Architect for:

* huge context windows,
* persistent working memory,
* continuous operational cognition.

---

# Important Shift

V1 optimized for:

* retrieval scarcity.

V2 optimizes for:

* coherent operational state inside abundant context.

---

# Deliverables

### Session Continuity Layer

Maintains:

* long-running organizational context
* active project memory
* temporal continuity
* evolving working state

---

### Layered Context System

Separates:

* active context
* historical context
* expandable context
* doctrine context
* project memory

---

# PROGRAM 4 — INFRASTRUCTURE & HARDWARE PROGRAM

# Goal

Provide durable operational infrastructure for long-term organizational cognition.

---

# Initiative 4.1 — Infrastructure Architecture

# Core Requirements

* modularity
* reliability
* observability
* local inference support
* service scalability
* reproducibility

---

# Target Stack

### Virtualization

* Proxmox

---

### Containerization

* Docker
* Docker Compose

Potential future:

* Kubernetes

---

### Storage

* NAS
* snapshotting
* automated backups
* object storage

---

### Networking

* VPN
* reverse proxy
* internal service mesh
* TLS everywhere

---

# Initiative 4.2 — Observability Stack

# Deliverables

### Metrics

* Prometheus
* Grafana

---

### Logging

* Loki
* OpenSearch

---

### Tracing

* OpenTelemetry

---

# Important Principle

Prismo itself must be observable.

Operational cognition systems without observability become impossible to maintain.

---

# Initiative 4.3 — Deployment Platform

# Deliverables

### CI/CD

* GitHub Actions
* Gitea Actions (future)

---

### Infrastructure as Code

* Ansible
* Terraform (future)

---

### Secret Management

* Vault
* environment injection

---

# PROGRAM 5 — HUMAN INTERACTION LAYER

# Goal

Provide coherent human access into organizational cognition.

---

# Important Clarification

Layer 4 is NOT merely a frontend.

It is:

> organizational mediation.

It ensures:

* continuity,
* persistence,
* project awareness,
* and canon integration.

---

# Initiative 5.1 — Prismo Web Interface

# Priority: HIGH

This becomes:

> the primary collaborative surface.

---

# Core Requirements

### Authentication

### Project-aware conversations

### Context querying

### Operational brief viewing

### Contribution capture

### Organizational dashboards

### Session continuity

### Multi-runtime support

---

# Suggested Stack

### Frontend

* Next.js
* TypeScript
* Tailwind
* shadcn/ui

---

### Backend

* FastAPI
* Node gateway
* websocket layer

---

# Important Design Constraint

Do NOT design around dashboards first.

Design around:

* conversational collaboration,
* operational visibility,
* continuity,
* low-friction interaction.

---

# Initiative 5.2 — Contribution Capture System

# Purpose

Convert conversational organizational signal into structured canon candidates.

---

# Responsibilities

* detect decisions
* detect proposals
* detect unresolved tensions
* detect action items
* detect doctrine evolution

---

# Key Insight

Organizations naturally generate durable signal conversationally.

Prismo must preserve this.

---

# Initiative 5.3 — Mobile & Ambient Interfaces

# Potential Integrations

* WhatsApp (nearest-term — team already communicates here)
* Telegram
* Discord
* Slack
* mobile applications

---

# Important Principle

The best interfaces are ambient and low-friction.

Prismo should integrate naturally into organizational behavior.

---

# PROGRAM 6 — GOVERNANCE & OBSERVABILITY

# Goal

Prevent Prismo itself from decaying.

---

# Initiative 6.1 — Canon Health System

# Metrics

* stale proposal count
* unresolved doctrine count
* orphaned canon
* supersession coverage
* metadata completeness
* retrieval effectiveness

---

# Initiative 6.2 — Retrieval Evaluation Framework

# Purpose

Measure:

* retrieval quality
* operational relevance
* synthesis effectiveness
* doctrine prioritization quality

---

# Initiative 6.3 — Runtime Governance

# Purpose

Track:

* provider usage
* model effectiveness
* routing quality
* runtime failures
* cost optimization

---

# PROGRAM 7 — ADVANCED RESEARCH SYSTEMS

# Important Note

These are future-facing systems.

Do NOT prematurely operationalize them.

---

# Potential Future Systems

### Knowledge graphs

### Organizational memory timelines

### Autonomous indexing pipelines

### Semantic relationship visualization

### Proactive operational synthesis

### Multi-agent coordination

### Voice cognition systems

### Persistent AI collaborators

### Long-term organizational simulation

---

# IMPORTANT EXECUTION PRINCIPLES

# Principle 1 — Context Abundance Architecture

Prismo V2 must architect for:

* huge context windows,
* persistent sessions,
* continuous operational memory,
* and layered context.

Do NOT optimize around:

* tiny prompts,
* brittle chunking,
* or aggressive compression.

---

# Principle 2 — Structural Workflow Enforcement

Behavior should increasingly emerge from:

* operational state,
* generated context,
* retrieval pipelines,
* workflow-state systems,
* and continuity engines.

NOT:

* prompt obedience,
* manual rituals,
* or runtime discipline.

---

# Principle 3 — Loose Coupling Everywhere

No model is permanent.
No interface is permanent.
No orchestration framework is permanent.

The substrate owns continuity.

---

# Principle 4 — Human Authority Remains Central

Automation assists:

* maintenance,
* synthesis,
* retrieval,
* and continuity.

Humans retain:

* judgment,
* strategic direction,
* and canon authority.

---

# Principle 5 — Build for Organizational Cognition

Prismo is not solving:

> "How do we fit context into models?"

Prismo is solving:

> "How do organizations maintain coherent operational continuity in an abundant AI world?"

That is the durable mission.

---

# FINAL EXECUTION ORDER

# Phase 0

* Canon audit
* Coupling analysis
* Lifecycle analysis
* Architecture mapping

---

# Phase 1

* Canon object model
* Capability contracts
* Lifecycle semantics
* Retrieval architecture design

---

# Phase 2

* context-server v2
* metadata system
* operational brief engine
* session hydration
* workflow-state service

---

# Phase 3

* doctrine-service
* synthesis-service
* Sukuna refactor (→ synthesis-service consumer, per proposed-idea 013)
* continuity systems

---

# Phase 4

* runtime abstraction layer
* local inference platform
* provider routing
* persistent session systems

---

# Phase 5

* web UI
* contribution capture
* organizational dashboards
* mobile interfaces

---

# Phase 6

* observability
* governance systems
* retrieval evaluation
* operational metrics

---

# Phase 7

* advanced cognition systems
* research systems
* long-term organizational intelligence

---

# Final Strategic Insight

Prismo V2 is not a chatbot platform.

It is not a wrapper around AI models.

It is:

> a persistent collaborative cognition substrate designed to preserve organizational continuity while AI systems evolve around it.

That is the architectural north star.
