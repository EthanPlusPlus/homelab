# 008 — Agentic Decision Pipeline and Self-Learning System

## The Problem

The current dual-query discipline relies on a single agent self-policing at two phases of reasoning. Compliance is unreliable — the agent has momentum toward proposing and skips the validation step. A concrete example: in the Obsidian integration session, the private GitHub repo issue was not caught before proposing because Phase 2 was skipped.

Additionally, the local embedding model (all-MiniLM-L6-v2) has a quality ceiling that limits what retrieval can surface, which compounds the compliance problem — even when queries are made, results may be incomplete.

---

## The Vision

### 1. Structured Decision Pipeline with Subagents

Replace self-policing instructions with a pipeline of dedicated agents, each with a single responsibility:

- **Proposer** — reasons from context and forms a solution
- **Validator** — cold to the solution, queries canon specifically against what the proposal implies, assumes, and touches. Checks for conflicts and duplication.
- **Devil's Advocate** — actively tries to break the proposal
- **Scribe** — captures the outcome as a decision record if the proposal clears the pipeline

This maps loosely to the **7 Advisors principle** — multiple independent perspectives applied before a decision is committed. Not every action needs the full pipeline; scope it to architectural and strategic decisions (the kind that generate decision records).

The structural advantage: the Validator agent has no stake in the proposal passing. Self-policing is replaced by separation of concerns.

### 2. Persistent Observing Agents

Agents that run continuously (via cron or loop) and:

- **Canon scanner** — reads canon periodically, identifies staleness, contradictions, or gaps, and proposes updates
- **Interaction observer** — watches session logs or summaries, extracts decisions and insights that should be in canon but aren't, and proposes them for canonisation
- **Non-use agent** — continues working between sessions: synthesising, cross-referencing, flagging open questions

### 3. Self-Learning Feedback Loop

Agents that write back to canon autonomously, combined with a quality-assessment mechanism. The hard part is the feedback loop — without it, autonomous writes produce canon drift. Needs a human-in-the-loop gate or a separate reviewer agent before changes land in canon.

---

## Dependencies / Prerequisites

- **Better retrieval layer first.** The agent pipeline is only as good as what it can retrieve. A stronger embedding model or hybrid retrieval (BM25 + semantic) should be prioritised before the pipeline gets too far ahead of the retrieval quality.
- **Agent orchestration tooling** — Claude Code subagents are available now; structured pipelines need a way to pass context between agents and gate on results.
- **Canon write-back governance** — a clear policy for what autonomous agents are allowed to write vs. what requires human sign-off.

---

## Status

No implementation. The `hermes` subagent (Decision 011) was a brief attempt at the
Validator role but was reversed by Decision 012 — cold-start cost and token overhead
outweighed the benefit at current scale. Inline Phase 2 MCP queries serve the validation
need for now. The broader pipeline (Proposer, Devil's Advocate, Scribe), Persistent
Observing Agents, and Self-Learning Feedback Loop remain at thinking stage.
