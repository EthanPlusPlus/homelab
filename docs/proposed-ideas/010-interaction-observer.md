---
id: "010"
title: Interaction Observer
status: proposed
notes: split out from original 008 section 2; not blocked, not yet scoped
---

# 010 — Interaction Observer

## Status

Proposed. Not blocked, not yet scoped.

## Origin

Originally part of [[008-agentic-decision-pipeline|008]] section 2 (Persistent Observing Agents).
The other two agent types in that section — canon scanner and non-use agent — were implemented
as [[009-maid-canon-standardizer|Sukuna (009)]]. The Interaction Observer is the remaining open piece.

## The Idea

An agent that watches session logs or summaries, extracts decisions, observations, and
unresolved tensions that should be in canon but aren't, and proposes them for canonisation.

Catches the gap between what happens in a session and what makes it into the durable record.

## Why It Matters

- Most organizational signal is conversational. Decisions get made, observations get surfaced,
  but unless someone explicitly says "make this canon", it disappears at session end.
- The drafts-only constraint ([[003-knowledge-base-source-of-truth|Decision 003]]) prevents
  autonomous canon writes, but a proposer agent can still surface candidates for human review.
- This is the V2 [[v2-roadmap|Contribution Capture]] concern (Initiative 5.2 in the V2 roadmap)
  at the Layer 2 level — capture happening at the runtime boundary, not just the UI.

## Open Questions

- What does session log access look like in Claude Code? Hooks? Transcript files? Both?
- Does this run during the session (synchronous capture) or after (batch review)?
- Does it write a draft to `~/canon/<project>/docs/drafts/`, like Sukuna, or surface
  candidates inline in the next session's bootstrap?

## Dependencies

- A working Sukuna review cadence — so the human review channel is established before adding
  more drafts to it.
- Probably the V2 [[v2-roadmap|Synthesis Service]] (Initiative 2.4), since extracting
  decisions from a transcript is a synthesis task.
