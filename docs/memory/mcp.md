---
name: MCP context server
description: How to connect to and use the context-server MCP — shared across all team sessions
type: reference
originSessionId: c00c74fa-0251-4ade-aab2-2060bf3b0968
---
## MCP Server

Connected as `context-server` at:
- **On VM:** http://localhost:8001/mcp
- **Remote (Tailscale):** http://ubuntu-server.tail58b10c.ts.net:8001/mcp

Tools: `search_docs`, `get_doc_section`, `list_related_decisions`, `search_code`, `get_symbol`, `find_references`, `get_file_summary`, `get_related_symbols`

Use `doc_type=<project-name>` to scope queries to a specific project (e.g., `homelab`, `context-server`, `exam-prep`). The context-server indexes every `~/canon/<X>/` as `doc_type=X`.

Always use these tools to answer questions about projects before falling back to bash. MCP context is richer and more reliable than grepping files directly.

---

## Dual-Query Discipline

Two-phase MCP pattern. Triggered, not always-on. Applies to any project with a canon at `~/canon/<project>/`.

**Triggers:** about to surface a proposal/plan/recommendation/decision, write or modify canon, or change architecture or service config. Skip for clarifying questions, code reads, tool discovery, and factual lookups.

**Phase 1 — Saturate:**
Query MCP with `doc_type=<project-name>` to scope by project. Search the topic and adjacent areas. Reuse session context if already fetched. If MCP returns empty but canon should plausibly exist, fall back to a direct `~/canon/<project-name>/` read.

**Phase 2 — Validate (inline):**
Query MCP against the specific proposal: what it implies, assumes, and touches. Check for conflicts and duplication. The MCP tool calls in the transcript are the evidence — a self-reported check does not count. Skip if relevant docs are already in context from Phase 1.
