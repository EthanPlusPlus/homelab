# Decision 012 — Session bootstrap and inline canon discipline

## Status
Adopted

## Supersedes
Decision 011 — Hermes: triggered cross-project canon discipline

## Context

Decision 011 introduced Hermes — a mandatory subagent dispatch as Phase 2 of the canon
discipline. In practice:

- Subagents spawn cold with no conversation context, re-deriving what the main agent already has
- Every proposal paid cold-start cost plus a full review pass, even for small suggestions
- Token usage increased rather than decreased — the opposite of the intended efficiency gain
- Sessions still felt like cold starts: no accumulated context, forced re-discovery of decided things

Two needs surfaced:
1. Restore Phase 2 to inline MCP queries — cheaper, still auditable via tool calls
2. Add a session bootstrap that front-loads context gathering before work begins

## Decision

### Phase 2 — Restore to inline MCP (drop Hermes)

Phase 2 is restored to inline MCP queries against the specific proposal: what it implies,
assumes, and touches. Check for conflicts and duplication. The MCP tool calls in the
transcript are the evidence. Skip if relevant docs are already in context from Phase 1.

The "tool call is the evidence" principle is retained. The difference: tool calls are now
direct MCP queries, not a subagent dispatch.

### Session bootstrap

On the first user message of every session:

**1. Read recent-changes.md**
Direct read of `~/canon/homelab/docs/context/recent-changes.md`. Semantic MCP queries for
this file are unreliable; direct read is guaranteed and cheaper.

**2. Warm-up before the task**
Before engaging with any task or idea:
- Ask one targeted question about what the user wants to build or achieve
- Based on their answer, query MCP for relevant canon on that topic
- Use results to ask the next most useful question
- Repeat until context is saturated (typically 2–4 exchanges)
- Then proceed

The warm-up is conversational, not an intake form. One question at a time. Lead with what
you already know. The MCP calls between exchanges are the mechanism — each answer directs
the next query. If the first message is already rich with context and intent is clear, skip
the warm-up.

### Hook updates (per-machine)

Update `~/.claude/settings.json`:
- `UserPromptSubmit` hook: update message to reflect Phase 2 as inline MCP (remove Hermes reference)
- `Stop` hook: update to check for inline Phase 2 MCP query (remove Hermes dispatch check)
- `~/.claude/agents/hermes.md`: can be archived or deleted

## Rationale

**Why drop Hermes:** Subagents start cold. They re-derive context the main agent already
has, adding token cost without adding insight. The adversarial framing was sound in theory
but expensive in practice. The main agent, having read the proposal and queried canon inline,
is better positioned to spot conflicts than a cold subagent.

**Why session bootstrap:** The root problem was not Phase 2 enforcement — it was cold starts.
Ethan would open with a big idea, the session would have no context, and the first half would
be wasted on re-discovery. The bootstrap front-loads that work into a brief conversational
exchange, making the actual building more efficient.

**Why direct read for recent-changes:** Semantic MCP queries for recent-changes.md surface
it inconsistently. Direct read is deterministic and requires no query design.

**Why questions drive MCP queries:** The user's intent determines what's relevant to query.
Querying MCP before understanding intent produces noise. The ask → answer → query → ask loop
targets retrieval to what actually matters for the session.

## Consequences

- `~/CLAUDE.md` updated: Hermes removed, session bootstrap added, Phase 2 restored to inline
- `memory/mcp.md` updated: Dual-Query Discipline section updated
- `context/constraints.md` updated: discipline section references Decision 012
- Decision 011 status set to Superseded by Decision 012
- Per-machine: `~/.claude/settings.json` hooks updated to remove Hermes reminders
- `~/.claude/agents/hermes.md` no longer invoked; can be archived
