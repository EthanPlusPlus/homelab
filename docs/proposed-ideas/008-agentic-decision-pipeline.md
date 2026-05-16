---
id: "008"
title: Structured Decision Pipeline
status: closed
notes: closed — premise disproven by Hermes (011) and superseded by inline Phase 2 (012)
---

# 008 — Structured Decision Pipeline

## Status

Closed. Premise disproven in practice.

## Original Idea

Replace self-policing Phase 2 with a pipeline of dedicated agents: Proposer, Validator,
Devil's Advocate, Scribe. [[011-hermes-cross-project-discipline|Hermes (Decision 011)]] was
the attempt at the Validator role.

## Why Closed

Hermes proved the premise wrong:

- Subagents start cold with no conversation context, re-deriving what the main agent already has
- Every proposal paid cold-start cost plus a full review pass, even for small suggestions
- Token usage increased rather than decreased — the opposite of the intended efficiency gain

Inline Phase 2 MCP queries ([[012-session-bootstrap-inline-discipline|Decision 012]]) serve
the validation need more cheaply. No further investment here.

## Related splits

The original 008 proposed three programs. Sections 2 and 3 are now tracked separately:

- **Persistent observing agents** — split into [[009-maid-canon-standardizer|009 (Sukuna)]] for
  canon scanning and the still-open [[010-interaction-observer|010 — Interaction Observer]].
- **Self-learning feedback loop** — split into [[011-self-learning-feedback-loop|011]] (deprioritised).
