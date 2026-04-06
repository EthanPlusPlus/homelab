# Decision 006 — context-server stack choices

## Status
Adopted

## Context
Building the first module of the context retrieval layer — a doc indexer that lets Claude query the homelab knowledge base semantically rather than exploring files blindly.

## Decisions

### Separate repo over colocating with homelab docs
context-server is a service, not documentation. It will grow to serve code indexing and external projects — keeping it separate gives it room to grow without polluting the docs repo.

### Two indexers over one unified tool
Code and markdown have fundamentally different retrieval needs. Code requires symbol-aware, semantic search. Markdown docs are short, structured, and section-addressable. One tool trying to do both would compromise on both. Two indexers feed one retrieval API.

### sentence-transformers (all-MiniLM-L6-v2)
Lightweight, CPU-friendly, runs comfortably within current 4GB RAM allocation. Sufficient for proving out the system. Model swap is a one-line change when better retrieval quality is needed — natural upgrade path is all-mpnet-base-v2.

### ChromaDB
Embedded mode — no separate server process, persists to disk via Docker named volume, straightforward cosine similarity search. Right size for the current corpus.

### FastAPI
Thin interface layer. Exposes /health, /search/docs, and /index. Designed to grow — code search and log retrieval endpoints added as subsequent modules.

### Docker over bare Python service
Consistent with existing homelab pattern. Isolated, manageable via Portainer, easy to rebuild. Source is volume-mounted so code changes don't require a rebuild during development.

## Retrieval model note
Scores on the current model sit in the 0.33–0.39 range — functional but not optimal. Revisit when MCP integration is established.

## Consequences
- context-server repo lives at ~/projects/context-server on the VM
- Doc indexer is the first module — code indexer follows
- Re-index triggered manually via POST /index after doc changes
- Model upgrade deferred until retrieval quality becomes a bottleneck
