---
name: MCP context server
description: How to connect to and use the context-server MCP — shared across all team sessions
type: reference
---
## MCP Server

Connected as `context-server` at:
- **On VM:** http://localhost:8001/mcp
- **Remote (Tailscale):** http://ubuntu-server.tail58b10c.ts.net:8001/mcp

Tools:
- **Docs:** `search_docs`, `get_doc_section`, `list_related_decisions`
- **Operational state (V2):** `get_context`, `get_project_state`, `get_stale_items`, `generate_brief`
- **Workflow state (V2):** `start_session`, `end_session`, `update_focus`, `create_workstream`, `update_workstream`, `get_workflow_state`
- **Lifecycle loop (V2.5):** `acknowledge_stale`, `list_stale_acks`
- **Signal capture (V2.5):** `capture_signal`, `list_captures`
- **Review queue (Decision 021):** HTTP-only at present (`/review/queue`, `/review/queue/{id}/approve|reject|edit`); MCP wrappers not yet shipped — Sukuna flagged 2026-05-17 as a Layer 4 universality gap
- **Synthesis (Decision 021):** HTTP-only at present (`/synthesis/run`); MCP wrapper not yet shipped
- **Workflow metrics:** HTTP-only at present (`/workflow/metrics`); MCP wrapper not yet shipped
- **Code:** `search_code`, `get_symbol`, `find_references`, `get_file_summary`, `get_related_symbols`

`search_docs` defaults to `record_type=canonical` (Decision 018). Pass `record_type=synthesized` or `record_type=any` to include model-generated content.

### Session start hydration

The UserPromptSubmit hook calls `prismo session ensure`. On *new session* creation it:
- closes any orphan active sessions for same project+contributor
- seeds `current_focus` from the user prompt
- emits a `[V2 HYDRATED CONTEXT]` block with active_doctrine top 5, active_proposals,
  unresolved_tensions, recent_changes top 3, and unacknowledged stale items if any
- emits a `[V2 LIFECYCLE]` block if `stale_count > 0`

On existing sessions it is silent. The hook is silent on context-server downtime — it never blocks prompts.

### Capture discipline

Claude is responsible for `capture_signal` — the user driving the conversation can't realistically transcribe it. When you notice durable signal in a session (architectural insight, inconsistency, decision waiting to happen, tension surfaced), call `capture_signal(text=..., project=..., session_id=...)`. Captures live in workflow-state-service as `pending-review` operational state, not canon. Per [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]], captures are now consumed by synthesis-service which emits ReviewItems to a human-approval queue (`prismo review`). The legacy `prismo capture promote` path is deprecated and will be removed once synthesis-service is the sole capture consumer.

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
