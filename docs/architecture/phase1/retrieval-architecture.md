# Retrieval Architecture V2

Defines how context-server v2 retrieves and packages organizational knowledge. The shift from V1 is: V1 answers "what documents match this query?" V2 answers "what does the runtime need to know to operate coherently right now?"

This is the specification that guides context-server v2 engineering.

---

## V1 vs V2 Retrieval Model

### V1
```
query string
  → embed
  → vector similarity search
  → top-k chunks
  → return to runtime
```

The runtime (Claude Code) then makes sense of the chunks itself. Session context is assembled conversationally. Relevance is purely semantic.

### V2
```
organizational state + query intent
  → 5-layer pipeline
  → hydrated context package
  → injected into runtime
```

The runtime receives pre-assembled, lifecycle-filtered, relationship-expanded context. It starts coherent rather than assembling coherence from raw chunks.

---

## The 5-Layer Pipeline

Each layer builds on the previous. A query passes through all applicable layers before returning.

---

### Layer 1 — Semantic Retrieval

Standard embedding-based similarity search. The foundation.

**Input:** query string, project scope
**Output:** raw chunk candidates with similarity scores

**Implementation:**
- Embedding model: current = `sentence-transformers/all-MiniLM-L6-v2`; V2 target = upgraded model (see proposed-idea 003)
- Vector store: ChromaDB (current); may be replaced as part of V2 if performance requires
- Scope: always filtered by project first, then cross-project if no results

---

### Layer 2 — Metadata Filtering

Applies structured filters to the candidate set from Layer 1. This is the layer that makes lifecycle state operationally meaningful.

**Filters:**
- `status`: exclude `archived`, `superseded`, `closed` by default
- `type`: filter to specific object types if requested (e.g., decisions only)
- `project`: already applied at Layer 1; enforced again here
- `recency`: optionally boost or filter by `updated_at`
- `contributor`: filter to docs relevant to a specific contributor

**Implementation:** metadata stored alongside embeddings in ChromaDB; filter applied as a pre-filter before similarity scoring.

---

### Layer 3 — Doctrine Prioritization

Reranks the filtered candidate set to surface the most operationally relevant content first.

**Prioritization rules:**
1. Active decisions rank above proposals
2. Recently updated docs rank above older ones (within the same type)
3. Docs explicitly tagged for the current project rank above cross-project docs
4. Docs in the active doctrine set for the current session rank above cold matches

**Implementation:** a lightweight reranker applied after Layer 2 filtering. Does not require a model — purely rule-based scoring on metadata fields.

---

### Layer 4 — Relationship Expansion

For each high-ranking result, expands to include related documents. Prevents the retrieval result from being a disconnected set of isolated chunks.

**Expansion rules:**
- If a decision is in the result set, include documents it `supersedes` (for context) and documents that `supersede` it (if they exist)
- If a proposal is in the result set, include the decision it maps to (if `v2_program` or a link exists)
- If a project document is in the result set, include that project's active decisions
- Expansion depth: 1 hop by default; configurable

**Implementation:** relationship graph derived from frontmatter fields (`supersedes`, `superseded_by`, `project`). Stored as a lightweight adjacency map in the doctrine-service.

---

### Layer 5 — Operational Packaging

Assembles the final output format based on what was requested. This is where raw retrieval becomes a structured organizational artifact.

**Output types:**

#### RetrievalResult (default)
Standard chunk array with metadata. Used for direct queries from the runtime.

#### ContextBundle
Full hydration payload for session start. Includes active doctrine, recent changes, active workstreams, unresolved tensions, contributor context. Assembled from structured canon state — not purely from vector search.

#### OperationalBrief
Synthesized prose summary of organizational state. Requires a model call for the synthesis step. Retrieval provides the source material; model generates the readable brief.

#### ProjectSnapshot
Point-in-time summary of a single project: decisions, proposals, recent changes, active work. Used for dashboards and onboarding.

---

## API Surface (context-server v2 target)

```
GET  /query          → RetrievalResult[]     (standard retrieval)
GET  /context        → ContextBundle         (session hydration)
GET  /brief          → OperationalBrief      (human-readable state)
GET  /project-state  → ProjectSnapshot       (project overview)
GET  /stale-items    → StaleItem[]           (doctrine maintenance)
GET  /decision-graph → DecisionGraph         (supersession chains)
GET  /recent-changes → ChangeEntry[]         (recent activity)
POST /index          → IndexResult           (trigger re-index)
```

All endpoints accept `project` as a query parameter for scoping.

---

## Context Abundance Principle

V2 retrieval is designed for large context windows, not small ones. This changes several assumptions:

**V1 assumption:** minimize retrieved content to avoid overwhelming the model
**V2 assumption:** retrieve more rather than less; let the model use what it needs

Concretely:
- Default `top_k` increases from 5 to 20+
- ContextBundles include full active doctrine, not excerpts
- OperationalBriefs include full recent history, not just last 3 items
- Relationship expansion is on by default, not opt-in

The retrieval system does not compress aggressively. The runtime has room.

---

## Implementation Dependencies

Phase 2 engineering on context-server v2 requires:

1. **Metadata schema** — from `canon-object-model.md` (Phase 1, this session)
2. **Lifecycle semantics** — from `lifecycle-semantics.md` (Phase 1, this session)
3. **Embedding model upgrade** — proposed-idea 003 (coordinate with context-server v2 work)
4. **Relationship graph** — requires `supersedes`/`superseded_by` fields to be populated in existing docs (progressive migration)
5. **doctrine-service** — provides the adjacency map for Layer 4 expansion (Phase 3)

Layer 4 (relationship expansion) and the doctrine-aware features of Layer 3 are Phase 3 work. context-server v2 can ship Layers 1–2–5 first, then add 3–4 as the doctrine-service comes online.
