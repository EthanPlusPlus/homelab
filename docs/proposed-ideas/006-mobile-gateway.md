---
id: "006"
title: Mobile Gateway to Prismo
status: proposed
notes: reframed 2026-06-05 — goal is a chat-based agentic loop Ethan controls, not a Claude Code wrapper
---

# 006 — Mobile Gateway to Prismo

## Status

Proposed — architecture direction updated. Goal is an owned agentic loop with chat interaction, not a thin wrapper around Claude Code.

## The Idea

A mobile-accessible interface to Prismo where you can have a conversation, trigger pipeline activations (facets), review and approve ReviewItems, add captures, and query knowledge — all from a phone, without needing Claude Code.

The key constraint: this is not a Claude Code remote. Claude Code is restrictive (approval prompts, no persistent agentic loop, session-scoped). The mobile gateway should provide an agentic loop that Ethan controls — conversation-first, with facets available as first-class tools at any point.

## Why This Is Distinct from Claude Code

Claude Code is a coding harness tied to a developer machine session. The mobile gateway is:
- **Persistent** — the loop doesn't end when a session closes
- **Conversational** — chat as the primary interface, not CLI commands
- **Controllable** — facet invocation, ReviewItem actions, and captures are always available without prompt approval friction
- **Ambient** — captures an idea on the go before it's lost; not for heavy implementation

## Architecture Direction

Layer 4 surface per Decision 021: thin renderer against existing API contracts. The intelligence lives in context-server (pipeline, synthesis, retrieval). The mobile interface is:
- A conversation loop backed by an LLM (model-agnostic per Decision 025 runtime roles)
- Facets available as tools in that loop (pipeline already exposes `/pipeline/activate`)
- ReviewItem queue surfaced inline (`/review/queue`)
- Capture submission (`/workflow/capture`)

No new backend work required beyond what's already built.

## Leading Questions

- What hosts the conversation loop? Options: a lightweight Layer 4 service in context-server, a standalone mobile app, or a WhatsApp/SMS gateway.
- Which model runs the conversational layer? (Haiku-class for latency, or routed based on task complexity per PI-016)
- How does auth work without Tailscale? (Feeds into Decision 032 auth layer — API key or OAuth)
- Is this the same surface as the WhatsApp gateway from the V2 masterplan, or a separate build?

## Relationship to Other Work

- Decision 021: ReviewItem as the integration primitive — mobile is a renderer
- Decision 025: Runtime topology — conversational runtime is a new runtime role
- Decision 031: Web UI is ops visibility; mobile is the ambient interaction surface
- Decision 032: Portability + auth layer is a prerequisite
- PI-016: Small model router could handle conversational routing
- PI-017: Capability orchestrator is the agentic loop design problem
