# Decision 016 — Session hydration replaces the warm-up ritual

## Status
Adopted

## Date
2026-05-16

## Supersedes
[[012-session-bootstrap-inline-discipline|Decision 012]] — Session bootstrap (warm-up portion only). The inline Phase 2 canon discipline from 012 remains in force.

## Context

[[012-session-bootstrap-inline-discipline|Decision 012]] codified a conversational warm-up at
session start: ask one targeted question, query MCP based on the answer, repeat 2–4 times
until context is saturated. This solved the cold-start problem at the time.

Phase 2 of V2 shipped the workflow-state-service ([[014-workflow-state-service-architecture|014]])
and the `get_context` endpoint, which together produce a ContextBundle structurally — active
doctrine, recent changes, current focus, active workstreams, unresolved tensions — at session start.

The roadmap explicitly states: "Session Hydration System replaces warm-up conversations,
manual retrieval loops, bootstrap rituals. The runtime starts hydrated."

`v1-deprecated-patterns.md` lists the warm-up loop as Claude-specific and not to be replicated
into the V2 web UI. But `memory/workflow.md` still described the warm-up as the active
session-start procedure. The cognition infrastructure to replace it was built and unused.

## Decision

The session-start procedure is now:

1. Call `start_session(project, contributor)` to register the session.
2. Call `get_context(project)` to retrieve the ContextBundle.
3. If `core_operational_state.current_focus` is set, proceed directly to the task.
4. If empty, ask one targeted question to establish focus, then call `update_focus`.

No greeting trigger. Bootstrap fires on the first user message.

The 2–4 turn warm-up is removed as a routine procedure. The single focus-establishing question
is retained — but only when the ContextBundle does not already carry it.

## Rationale

**Why supersede now.** The replacement infrastructure is live. Continuing to describe the
warm-up as the canonical bootstrap means contributors do it manually while the service produces
the same information automatically. That is Layer 1 work performed against an unused Layer 2
capability — exactly the pattern the masterplan was designed to eliminate.

**Why keep the focus-establishing question conditionally.** The ContextBundle gives standing
state. User intent for *this* session is fresh each time. When `current_focus` is empty, the
single question still has value. The change is that the question is conditional and singular,
not a 2–4 turn loop.

**Why not delete 012 entirely.** Decision 012's Phase 2 (inline MCP canon discipline) is
unchanged and still load-bearing. Only the bootstrap section is superseded. Decisions remain
immutable adopted records; the supersession is scoped to the warm-up portion.

## Consequences

- `memory/workflow.md` updated: step 0 rewritten to hydrate via service calls.
- Decision 012 status updated: bootstrap portion superseded by 016; Phase 2 portion still active.
- Project CLAUDE.md files (`flight-planner`, `even`) updated: ghost "hi" trigger removed.
- `~/CLAUDE.md` global file describes the warm-up; should be updated by Ethan in a follow-up
  to match this decision (single conditional question, hydrate via MCP first).
- The web UI in Phase 5 inherits the hydrated-start pattern directly — no conversation ritual
  to port forward.
