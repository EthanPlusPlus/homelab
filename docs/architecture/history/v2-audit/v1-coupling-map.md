# V1 Coupling Map — Claude-Specific and Non-Portable Patterns

These are the things in V1 that are tightly coupled to Claude Code or a specific runtime. Each needs to be abstracted or replaced in V2 before the runtime layer becomes truly swappable.

---

## Governance Layer

### CLAUDE.md as the operational governance mechanism
The entire workflow, canon discipline, session behavior, and operational rules are expressed as Claude Code instructions. No other runtime (local model, web UI, Shrey/Kyle's interface) can load or honor these. In V2, governance must move into Layer 2 service contracts. CLAUDE.md becomes a thin adapter for the Claude runtime only.

### Session bootstrap warm-up (ask → MCP → ask loop)
Designed as a Claude conversation pattern. The information it produces (what's the user building, what's relevant canon) should be a Layer 2 context bundle generated automatically. Not portable to any non-conversational interface.

---

## Hooks

### Stop hook
Fires on every Claude Code response as a last-chance discipline reminder. Claude Code-specific. Not portable. Treat as temporary scaffolding until workflow-state-service exists.

### UserPromptSubmit hook
Injects a canon discipline reminder on every user prompt. Claude Code-specific. Same disposition as Stop hook.

---

## Agent System

### Sukuna as a Claude agent definition (`sukuna.md`)
The agent format, invocation script, and `--agent` flag are Claude Code-specific. The underlying capability (canon maintenance pass) is correct and must survive. The implementation must become a Layer 2 scheduled service, not a Claude agent file.

### MCP tool surface ergonomics
The current MCP tools (`search_docs`, `get_doc_section`, `get_symbol`, etc.) were designed around Claude Code usage patterns. In V2, the capability contract is `retrieve(query, project)` — the MCP tool names and parameter shapes are an implementation detail of one transport. Abstract the capability; keep MCP as one supported transport.

---

## CLI

### prismo bash script
Not a runtime coupling per se, but CLI-only access excludes all non-technical users. In V2, the operations prismo encodes become Layer 2 API calls. The bash script is a prototype, not a feature to port forward.

---

## Implicit Assumptions

### "Start sessions with hi" instruction in workflow.md
A ghost instruction with no decision record, propagated into new project scaffolds. Assumes Claude Code is always the entry point. In V2 there is no single entry point — the web UI, WhatsApp bot, and IDE are all first-class. Remove from project templates.

### Pull-before-commit as a manual protocol
Manual concurrency coordination compensating for absent workflow state. In V2 the workflow-state-service tracks active sessions and detects conflicts structurally.
