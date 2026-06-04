# Prismo — Layer Model

Single authoritative definition of Prismo's architecture. Everything else links here.

---

## The Four Layers

```
Layer 4 — Interfaces
Layer 3 — Runtime Intelligence
Layer 3.5 — Pipeline (Activation Router + Context Assembler + Response Processor)
Layer 2 — Services
Layer 1 — Substrate
```

### Layer 1 — Substrate

The physical and container infrastructure Prismo runs on.

- Proxmox host + Ubuntu Server VM
- Docker (all services containerised)
- PostgreSQL + pgvector (primary data store)
- Git (canon persistence)

Portability constraint (Decision 032): nothing above Layer 1 may assume specific hardware,
hostnames, or networking topology. Layer 1 is the only layer allowed to be machine-specific.

### Layer 2 — Services

Deterministic, HTTP-first capabilities. No interpretation, no probability. Structural truth only.

| Service | Responsibility |
|---------|---------------|
| context-server | Doc indexing, semantic retrieval, embedding |
| workflow-state-service | Sessions, captures, ReviewItems, stale tracking |
| doctrine-service | Structural coherence: metadata, supersession, provenance, drift |
| synthesis-service | Quality-gated signal processing → ReviewItems |

**Law 1** (Decision 017): Structural truth is deterministic. Layer 2 services produce facts, not judgments.

**Service Rule** (Decision 017): Every HTTP route must be documented in `architecture/contracts/capability-contracts.md`. Undocumented routes fail-to-start.

### Layer 3.5 — Pipeline Service

Sits between runtime and services. Routes prompts, assembles context, processes responses.

Components:
- **Activation Router** — matches incoming prompt against registered Activations (two-stage: keyword pre-filter → embedding similarity)
- **Context Assembler** — loads context bundles for matched Activations
- **Response Processor** — extracts signal candidates from model output → auto-creates captures (Decision 028)

**Activation types** (Decision 026):
- `FACET` — cognition-shaping context load (built: architect, assess, migrate, review, sukuna, wrap-up)
- `SEQUENCE` — defined execution sequence (reserved, unbuilt — see PI-018, wrap-up and sukuna are candidates)
- `MEMORY_PACK`, `CONSTRAINT`, `TOOLSET` — reserved

### Layer 3 — Runtime Intelligence

The cognitive tier. Models are **replaceable runtimes**, not permanent identities.

Named runtime roles (Decision 025):

| Role | Current provider | Authority |
|------|-----------------|-----------|
| `coding_runtime` | Claude Code (subscription) | Full — canon authoring, synthesis invocation, analysis |
| `synthesis_runtime` | Anthropic via LiteLLM | Synthesis only — no canon authoring |
| `analysis_runtime` | Anthropic via LiteLLM (web_search) | Analysis only |
| `embedding_runtime` | sentence-transformers (local) | Embedding only |
| `collaboration_runtime` | Reserved (Shrey/Kyle future) | read_canon, capture_signal, reviewitem_approval |
| `routing_runtime` | Reserved (PI-016) | Activation routing only |

**Law 2** (Decision 017): Interpretation is probabilistic. Layer 3 produces judgments, not facts. Human review is required before any Layer 3 output becomes canon (Decision 021).

### Layer 4 — Interfaces

Thin renderers and action handlers over the Layer 2 contract. Every surface renders the same ReviewItem, capture, and session primitives.

Current surfaces:
- **CLI** (`prismo`) — primary operational surface
- **Web UI** (`prismo-ui`) — ops dashboard, port 3000 (Phase 5 slice 1)

Planned surfaces:
- Conversational web UI (Phase 5 slice 2) — the product interface
- Mobile / WhatsApp (Decision 031, deferred)

---

## Human Judgment Boundary

**ReviewItems** (Decision 021) are the universal boundary. No Layer 3 output becomes
canon without a human approve/reject decision. Every surface is a renderer against this
contract — the judgment layer does not move, only the rendering surface does.

Flow: signal → capture → synthesis quality gate → ReviewItem → human → canon

---

## Key Contracts

- `architecture/contracts/capability-contracts.md` — HTTP interface definitions for all Layer 2 capabilities (enforced by Service Rule at startup)
- `architecture/contracts/canon-object-model.md` — object definitions (Decision, Proposal, Session, ReviewItem, etc.)
- `architecture/contracts/lifecycle-semantics.md` — status transitions and staleness rules
- `architecture/contracts/retrieval-architecture.md` — 5-layer retrieval pipeline

---

## Related Decisions

- Decision 017 — Three Architectural Laws + Service Rule
- Decision 021 — ReviewItems as human-judgment boundary
- Decision 024 — CapabilityRegistry (runtime → capability routing)
- Decision 025 — Runtime Intelligence Layer topology
- Decision 026 — Layer 3.5 Pipeline Service
- Decision 030 — Billing architecture (subscription coding_runtime, LiteLLM side intelligences)
- Decision 032 — Portability as first-class constraint
