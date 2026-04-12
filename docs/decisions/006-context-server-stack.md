# Decision 006 — context-server stack choices

## Status
Adopted

## Context
Building the first module of the context retrieval layer — a doc indexer that lets Claude query the homelab knowledge base semantically rather than exploring files blindly.

## Decisions

### Separate repo over colocating with homelab docs
context-server is a service, not documentation. It will grow to serve code indexing and external projects — keeping it separate gives it room to grow without polluting the docs repo.

### Two indexers over one unified tool
Code and markdown have fundamentally different retrieval needs. Code requires symbol-aware semantic search. Markdown docs are short, structured, and section-addressable. One tool trying to do both would compromise on both. Two indexers feed one retrieval API.

### sentence-transformers (all-MiniLM-L6-v2)
Lightweight, CPU-friendly, runs comfortably within current 4GB RAM allocation. Sufficient for proving out the system. Model swap is a one-line change when better retrieval quality is needed — natural upgrade path is all-mpnet-base-v2.

### ChromaDB
Embedded mode — no separate server process, persists to disk via Docker named volume, straightforward cosine similarity search. Right size for the current corpus.

### FastAPI
Thin interface layer. Exposes /health, /search/docs, /get/doc, and /index. Designed to grow — code search and log retrieval endpoints added as subsequent modules.

### Docker over bare Python service
Consistent with existing homelab pattern. Isolated, manageable via Portainer, easy to rebuild. Source is volume-mounted so code changes don't require a rebuild during development.

### MCP server via FastMCP (mcp 1.27.0)
FastMCP provides the simplest path to exposing retrieval tools to Claude Code. Runs as a separate container on port 8001, calls the FastAPI service internally over the Docker network. Claude Code connects over Tailscale.

### context_mcp over mcp as module name
The mcp/ directory name conflicts with the installed mcp Python package — Python resolves our directory first, shadowing the library. Renamed to context_mcp to avoid the collision.

## Retrieval model note
Scores on the current model sit in the 0.33–0.39 range — functional but not optimal. Ranking occasionally surfaces architecture/runbook content above decision docs for decision-oriented queries. Acceptable for this stage. Revisit when retrieval quality becomes a bottleneck.

## Consequences
- context-server repo lives at ~/projects/context-server on the VM
- Doc indexer is the first module — code indexer follows
- MCP server exposes tools: search_docs, get_doc_section, list_related_decisions, search_code, get_symbol, find_references, get_file_summary
- Re-index triggered manually via POST /index after doc changes
- Model upgrade deferred until retrieval quality becomes a bottleneck
- CPU-only torch required — CUDA build fills the 30GB disk during Docker build
- **Updated (2026-04-12):** Doc indexer moved to convention-based multi-project discovery — see decision 010
