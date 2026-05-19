---
id: "014"
title: External Synthesis — Prior Art and Ecosystem Awareness
status: proposed
notes: emerged from observation-week session 2026-05-19; defer until internal synthesis loop is stable
---

## Idea

Extend synthesis-service with a second capability: **external synthesis**. Where internal synthesis
operates over captures + canon to propose ReviewItems, external synthesis operates over the open
web, GitHub, papers, and tooling ecosystems to produce prior-art reports and build-vs-buy
recommendations.

This is not a manual checklist or lifecycle gate. It is an opportunistic synthesis pattern that
fires when synthesis detects a "new capability being scoped" signal in captures or sessions.

## Background

Prismo's internal awareness is strong (canon, continuity, governance, synthesis, review). But it
has no systematic way to triangulate itself against the external landscape. The failure mode is
silently reinventing subcomponents that are already commoditized — or missing relevant standards,
tools, or failure modes documented elsewhere.

The goal is not "prevent reinventing the wheel." The goal is:

> Maintain architectural situational awareness.

Sometimes reinventing is correct. The system should help answer: what exists, what tradeoffs
already emerged, what is commoditized, what is genuinely novel here.

## The 3-mode synthesis model

This proposed-idea introduces the second of three synthesis modes:

| Mode         | Input                              | Output                                      |
| ------------ | ---------------------------------- | ------------------------------------------- |
| Internal     | captures + canon + sessions        | proposed canon changes, tensions, insights  |
| External     | web + GitHub + papers + tools      | prior-art reports, ecosystem maps, build-vs-buy |
| Comparative  | internal canon + external landscape | "this area is solved", "this is genuinely novel" |

Comparative synthesis (mode 3) is the long-term goal but depends on both modes 1 and 2 being
stable first.

## Trigger pattern

External synthesis should activate when synthesis detects:
- a capture describing a new capability being scoped
- a proposed-idea moving toward implementation
- a session signal about building something that might already exist

It should NOT activate on every capture or run on a schedule.

## Output shape

Emits a ReviewItem of type `prior-art-report`:

```json
{
  "type": "prior-art-report",
  "proposed_capability": "...",
  "existing_tools": [...],
  "tradeoff_summary": "...",
  "recommendation": "build | adopt | investigate",
  "confidence": 0.N,
  "sources": [...]
}
```

## First concrete example

During 2026-05-19 session: prior-art search for Prismo's ADR/code-drift detection surfaced
**Decision Guardian** (MIT, open source) — surfaces relevant ADRs when code touching those
decisions is modified. This would have been relevant before building any equivalent capability.

## Dependencies

- Internal synthesis loop stable (observation week complete)
- Web search tool available to synthesis runner
- ReviewItem schema supports `prior-art-report` type

## Sequencing

Do NOT build during observation week. Use observation week to confirm the trigger pattern
(manual prior-art moments in sessions) actually shows up in captures with enough frequency to
justify the capability. If it does, this becomes the first post-observation-week synthesis
extension.
