---
id: "010"
title: Interaction Observer
status: proposed
notes: core purpose superseded by Decision 021 Class 1 synthesis (captures → ReviewItems); remaining open question is session-log-access mechanism (hooks vs transcript files)
---

# 010 — Interaction Observer

## Status

Proposed. Core purpose — watching sessions and surfacing canon candidates — is substantively answered by Decision 021 Class 1 synthesis (captures + sessions → ReviewItems via synthesis-service). Remaining open question: what does session-log access look like in Claude Code? Hooks? Transcript files? Both?

> **Annotation 2026-05-21:** The "does it write to drafts/ or surface inline?" question is answered by Decision 021: ReviewItems, not drafts. The observer pattern, if built, would `POST /workflow/capture` per finding and let synthesis-service handle the rest.

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
- The drafts-only constraint (see docs/memory/workflow.md and homelab STRUCTURE.md) prevents
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
