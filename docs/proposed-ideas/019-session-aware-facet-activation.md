---
id: "019"
title: Session-Aware Facet Activation
status: proposed
notes: from capture cap_6d89cd01b8 — deploy facet won't fire retroactively mid-build
---

# 019 — Session-Aware Facet Activation

## Status

Proposed — surfaced from operational observation.

## The Problem

Facets activate on routing signals at prompt time. If you're mid-build when the deploy facet would be relevant, it won't retroactively activate — the session is already running and the pipeline has no awareness of session state.

Concrete example: you start a build session, make changes, and at the end want to deploy. The deploy facet should activate on "let's deploy this" — but if the routing signal is ambiguous or absent, you're relying on either an explicit `/deploy` invocation or luck on the embedding match.

More broadly: the pipeline has no concept of session phase. Early in a session (exploration, design) and late in a session (commit, deploy, wrap-up) should have different activation priors — but the router treats every prompt identically.

## What Session-Awareness Could Look Like

- **Explicit phase tagging** — `prismo session phase deploy` sets a hint the router can weight against; facets registered for that phase get a scoring boost
- **Elapsed-time priors** — router shifts thresholds as session ages (late-session → wrap-up and deploy get lower activation threshold)
- **Recency signal** — pipeline observes what facets fired earlier in the session; if `migrate` fired, `deploy` is a likely next step
- **Session-state broadcast** — workflow-state-service exposes current phase/focus; router reads it as a soft prior

## Relationship to Other Work

- PI-016: Small model router — a smarter Stage 2 router could incorporate session context naturally
- PI-017: Capability orchestrator — session phase is an orchestration concern
- PI-018: Facet coverage gap detection — gap detection is easier if the router knows what phase it's in
- Decision 026: Pipeline architecture — activation router is the right place for this signal

## Open Questions

- Is session-phase an explicit user signal (`prismo session phase X`) or inferred automatically?
- Does this belong in the router (scoring) or the assembler (context enrichment)?
- At what granularity does "phase" operate — per-session, per-workstream, or per-prompt?
