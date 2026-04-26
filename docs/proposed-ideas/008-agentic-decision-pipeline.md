---
id: "008"
title: Agentic Decision Pipeline and Self-Learning System
status: Partially closed — see notes per section
---

# 008 — Agentic Decision Pipeline and Self-Learning System

## 1. Structured Decision Pipeline — Closed

The original idea: replace self-policing Phase 2 with a pipeline of dedicated agents
(Proposer, Validator, Devil's Advocate, Scribe). Hermes (Decision 011) was the attempt at
the Validator role.

**Closed.** Hermes proved the premise wrong — subagents start cold, re-derive context the
main agent already has, and add token cost without adding insight. Inline Phase 2 MCP queries
(Decision 012) serve the validation need more cheaply. No further investment here.

---

## 2. Persistent Observing Agents — Partially implemented

Three agent types were envisioned:

- **Canon scanner** — reads canon periodically, identifies staleness and gaps → **implemented as Sukuna (009)**
- **Non-use agent** — continues working between sessions, synthesising and cross-referencing → **implemented as Sukuna section 3**
- **Interaction observer** — watches session logs or summaries, extracts decisions/insights that should be in canon but aren't, proposes them for canonisation → **open**

The Interaction observer is genuinely useful but requires a mechanism for session log access.
Not blocked, just not yet scoped.

---

## 3. Self-Learning Feedback Loop — Deprioritised

Agents that write back to canon autonomously with a quality-assessment gate. Roughly: a
Scribe that captures session outcomes + a reviewer agent before changes land.

Not a bad idea, but not a priority. The drafts-only constraint (Decision 003) and Sukuna's
review cycle serve this need at current scale. Revisit if Sukuna's output volume grows enough
to make manual review a bottleneck.

---

## Open

- Interaction observer: what does session log access look like in Claude Code? Worth scoping
  when the Sukuna review cadence is established.
