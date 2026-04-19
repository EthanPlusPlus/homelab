---
name: MCP context server
description: How to connect to and use the context-server MCP — shared across all team sessions
type: reference
---

## MCP Server

Connected as `context-server` at:
- **On VM:** http://localhost:8001/mcp
- **Remote (Tailscale):** http://ubuntu-server.tail58b10c.ts.net:8001/mcp

Tools: `search_docs`, `get_doc_section`, `list_related_decisions`, `search_code`, `get_symbol`, `find_references`, `get_file_summary`, `get_related_symbols`

Always use these tools to answer questions about the homelab and projects before falling back to bash.
MCP context is richer and more reliable than grepping files directly.

---

## Dual-Query Discipline

Apply a mandatory two-phase MCP query pattern to every idea, finding, or decision.

**Phase 1 — Educate (before forming any opinion):**
Query MCP on the topic and everything related before reasoning begins. If context was already
fetched this session, use it — no re-query needed. If MCP returns nothing but the topic is
within established Prismo scope (decision-type question, area already indexed), fall back to
a direct read of the relevant ~/canon/ file before reasoning fresh.

**Phase 2 — Validate (after forming a solution):**
Once a decision is formed, query MCP against that specific solution — what it implies, assumes,
and touches. Check for conflicts with existing decisions and duplication of already-resolved
questions. Skip if relevant docs are already in context.

Only after both phases is a proposal ready to surface.
