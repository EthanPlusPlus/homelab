# Context Bundle — homelab

**project:** homelab  |  **contributor:** ethan  |  **generated:** 2026-05-13

## 1. Core Operational State
- **active_workstreams:** (none)
- **current_focus:** ""
- **unresolved_tensions:** 0 item(s)

## 2. Active Doctrine
### decisions/007-canon-code-knowledge-separation.md
**status:** active

Docs were committed inside code repos (e.g. `~/projects/context-server/docs/`).
When working in a repo, Claude could — and did — read docs directly from the filesystem,
bypassing the MCP context-server. This violated the founding principle:

> Claude should not be used as a search engine, only as a reasoning engine.

### decisions/012-session-bootstrap-inline-discipline.md
**status:** active

Decision 011 introduced Hermes — a mandatory subagent dispatch as Phase 2 of the canon
discipline. In practice:

- Subagents spawn cold with no conversation context, re-deriving what the main agent already has
- Every proposal paid cold-start cost plus a full review pass, even for small suggestions
- Token usage increased rather than decreased — the opposite of the intended efficiency gain
- Sessi

### decisions/010-shared-memory.md
**status:** active

- `~/canon/homelab/docs/memory/` is **not indexed** by context-server — the content is already
  accessible via other indexed docs; duplicating it would add noise to MCP retrieval
- `prismo new-machine` creates symlinks for shared files, then optionally syncs personal files via scp
- `prismo new-project` requires no changes — memory is machine-level, not project-level
- STRUCTURE.md updated to doc

### decisions/005-github-over-gitea.md
**status:** active

Needed a remote home for the homelab documentation repo. Gitea (self-hosted) was the natural long-term choice, but the homelab currently runs on a single machine with no redundancy.

## 3. Recent Context

### Recent Changes (latest entries)
- **context-server v2 shipped + EmbeddingProvider abstraction** — frontmatter indexing, lifecycle-aware retrieval, /context /project-state /stale-items endpoints, 3 new MCP tools; model now config-driven via EMBEDDING_MODEL env var; 821 docs indexed
- **Phase 0+1 complete — V2 canon foundation laid** — 7 stale decisions deleted, 3 proposed-ideas closed; v2-audit/ (4 docs), phase1/ contracts written (object model, capability contracts, lifecycle semantics, retrieval architecture, design notes); v2 masterplan + roadmap saved
- **Prismo V2 masterplan written** — founding architecture doc at docs/architecture/v2-masterplan.md; 4-layer model (substrate/services/runtime/interfaces); models as swappable runtimes; cognitive continuity framing; team context (Shrey/Kyle); WhatsApp as nearest-term Layer 4
- **Flight Planner git repo set up** — repo at github.com/EthanPlusPlus/flight-planner (private); sparse checkout in ~/projects/flight-planner; docs worktree at ~/canon/flight-planner; hooks installed; indexed in context-server
- **Even project bootstrapped** — iOS receipt-splitting app; repo at github.com/EthanPlusPlus/even; ~/projects/even (sparse, no docs/), ~/canon/even worktree on docs branch, indexed in context-server

### Active Proposals
- **[proposed]** proposed-ideas/006-mobile-gateway.md
- **[experimental]** proposed-ideas/009-maid-canon-standardizer.md
- **[proposed]** proposed-ideas/003-embedding-model-upgrade.md
- **[proposed]** proposed-ideas/008-agentic-decision-pipeline.md
- **[proposed]** proposed-ideas/002-gitea-migration.md

## 4. Historical Context — Architecture
### architecture/v2-audit/v1-survivors.md § Project isolation model
Each project carries its own `decisions/`, `runbooks/`, `architecture/`, `context/`. Clean boundaries between homelab-level and project-level concerns. Survives into V2 unchanged.

### architecture/v2-roadmap.md § Architectural Direction
The system must evolve beyond:


Toward:


---

### architecture/v2-roadmap.md § Goal
Establish stable architectural contracts before major implementation expansion.

This phase exists to:

* prevent architectural chaos,
* avoid premature coupling,
* establish long-term invariants,
* and create stable internal semantics.

---

### architecture/v2-masterplan.md § 10. Long-Term Possibilities
Exploratory only. These should emerge from real operational need, not architectural ambition.

* advanced synthesis agents
* collaborative planning systems
* voice interfaces
* proactive organizational maintenance
* timeline reconstruction
* knowledge graphs
* project intelligence maps
* semantic re

### architecture/v2-masterplan.md § synthesis-service
Generates:

* project summaries
* onboarding packets
* architectural overviews
* change summaries
* operational state reports
* relationship maps

---

## 5. Expandable Context
0 item(s) — fetched on demand, not pre-loaded
