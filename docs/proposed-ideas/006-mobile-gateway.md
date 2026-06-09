---
id: "006"
title: Agentic Loop — primary interaction harness
status: superseded
notes: promoted 2026-06-09 into Decisions 036 (role/contract/billing), 037 (conversation continuity), 038 (phase gate). Build plan at fergie/loop-build-plan.md.
---

# 006 — Agentic Loop (Primary Harness)

## Status

**Superseded — promoted into canon 2026-06-09.** The design sessions of
2026-06-07 → 2026-06-09 answered every leading question below. See:

- [[../decisions/036-loop-runtime-role-contract-billing|Decision 036]] — role, capability contract, billing, identity, deployment
- [[../decisions/037-loop-conversation-continuity|Decision 037]] — messages, checkpoints, session cycling, hydration
- [[../decisions/038-workstream-phase-gate|Decision 038]] — shift-left QA gate
- `fergie/loop-build-plan.md` — implementation phases A0–E

Original framing preserved below for provenance.

## The Idea

An agentic loop chat that does exactly what Claude Code sessions do today — and
more. Multi-turn conversation, facet activations, canon discipline, synthesis
runs, ReviewItem triage, implementation — the full Prismo workflow. Accessible
from any device without Claude Code.

The key constraint: this is not a Claude Code remote. Claude Code is restrictive
(approval prompts, session-scoped context windows, CLI-first). The agentic loop
should provide a conversation-first interface where Prismo owns the loop.

## Why This Is the Primary Harness

Claude Code is the current primary harness by default, not by design. It was the
available tool when Prismo was built. The agentic loop is what Prismo is building
toward: a surface it controls, on a model it chooses, billed the way it decides.

This is the biggest Layer 4 build in the roadmap. Decision 035 defines the
normalised interface (three API calls). The agentic loop is the heaviest adapter
against that interface — multi-turn, session-aware, activation-routing per
message, response-processor per response.

## What the Agentic Loop Requires

Unlike the Claude Code adapter (~20 lines in `capture-response`), the agentic
loop adapter is a full system:

- **Multi-turn conversation** — message history, not one-shot queries
- **Session lifecycle** — `POST /workflow/session/start` on open, `POST /workflow/session/:id/end` on close
- **Activation routing per message** — `pipeline/router.route()` on every user turn, same as Claude Code's UserPromptSubmit hook
- **Response processor per response** — `processor.process()` on every assistant turn; captures flow automatically
- **Evolving context** — facets fire and inject context as the conversation shifts topics

## What POST /chat Is Not

`POST /chat` (built 2026-06-07) is a single-turn Q&A endpoint. It loads system
state, calls analysis_runtime, returns one answer. It is not the agentic loop.
It is not a starting point for the agentic loop. The agentic loop requires a
conversation engine, not a query endpoint. `POST /chat` may survive as a
lightweight state-query tool for surfaces that need it; it is not the foundation
for this.

## Prerequisite: Billing Decision

Decision 030 locks billing: coding_runtime = subscription CLI (Claude Code), side
intelligences = LiteLLM pay-per-token. The agentic loop is the primary
intelligence — it IS the coding_runtime replacement. Running it on pay-per-token
API at the volume and depth of a full working session is a real cost. This needs
a position before design begins:

- Continue subscription CLI via `claude -p` as the loop engine (limits control)
- Anthropic API pay-per-token (full control, variable cost)
- Route by task complexity: Haiku for lightweight turns, Sonnet for heavy ones (PI-016/PI-017)

Decision 030 must be annotated with this reframe before implementation starts.

## Leading Questions

- Which model runs the agentic loop, and on which billing model?
- Does the loop host its own model calls (API) or delegate to an existing runtime?
- What is the conversation state store — in-memory per connection, or persisted in workflow-state-service?
- How does multi-turn context management work — full history, windowed, or summarised?
- Mobile deployment: WhatsApp gateway, web chat, native app — which first?
- Auth: Tailscale-gated (same as web UI) or token-based for mobile?

## Relationship to Other Work

- [[../decisions/035-harness-adapter-pattern|Decision 035]] — normalised interface this adapter implements; agentic loop is the heaviest adapter
- [[../decisions/030-billing-architecture-intelligence-tiers|Decision 030]] — billing architecture; needs annotation for primary intelligence question
- [[../decisions/025-runtime-intelligence-layer-topology|Decision 025]] — a new runtime role may be needed: `loop_runtime`
- [[../decisions/026-layer-3-5-pipeline-service|Decision 026]] — activation routing and response processor are the pipeline hooks the loop uses
- [[../decisions/031-web-ui-operational-visibility-forcing-function|Decision 031]] — web UI is ops visibility; agentic loop is the work surface; distinct
- [[017-capability-orchestrator|PI-017]] — capability orchestrator is the agentic loop's routing design problem
- [[016-routing-intelligence-small-model-router|PI-016]] — model routing by complexity; directly applicable here
