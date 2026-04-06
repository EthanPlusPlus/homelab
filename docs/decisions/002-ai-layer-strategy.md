# Decision 002 — AI context layer as primary homelab goal

## Status
Adopted

## Context
Initial homelab goal was general self-hosting (Docker, Immich, Pi-hole). After early use of Claude Code, a clearer and higher-value direction emerged.

## Core Insight
Claude Code inefficiency is primarily caused by exploration overhead, not reasoning. Most tokens are spent searching files and scanning irrelevant context — not solving problems.

The principle: Claude should not be used as a search engine, only as a reasoning engine.

## Decision
Reorient the homelab around building an AI context and retrieval layer:

- Local tools retrieve relevant context before Claude is invoked
- Claude receives minimal, pre-filtered context
- Homelab is both the platform hosting these tools and the first project they serve

## Architectural Model

```
Conversations / sessions
        ↓
Extraction (decisions, reasoning, tradeoffs)
        ↓
Draft markdown (docs/drafts/)
        ↓
Manual review
        ↓
Canonical knowledge (docs/)
        ↓
Retrieval layer
        ↓
Claude
```

## Retrieval Hierarchy
1. Code — for implementation problems
2. Markdown knowledge — for decisions and context
3. Conversations — fallback only, not indexed directly

## Consequences
- Immich and Pi-hole deprioritised
- RAM upgrade deferred until Ollama becomes relevant
- Structured markdown adopted as canonical knowledge format (see decision 003)
