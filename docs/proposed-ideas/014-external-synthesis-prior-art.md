---
id: "014"
title: External Signal Provider — Prior Art and Ecosystem Awareness
status: proposed
notes: emerged from observation-week session 2026-05-19; defer until internal synthesis loop is stable
---

## Idea

Add an **external signal provider** to Prismo's synthesis pipeline. Where internal synthesis
consumes captures + canon to propose ReviewItems, an external signal provider fetches structured
research from the open web, GitHub, papers, and tooling ecosystems — and emits that research as
a signal into synthesis-service, which then produces a ReviewItem.

This is architecturally an input adapter (same role as captures), not a synthesis capability.
Naming it "external synthesis" would scope it into synthesis-service's logic; it belongs
as its own provider that *feeds* synthesis-service.

This is not a manual checklist or lifecycle gate. It is an opportunistic pattern that fires when
synthesis detects a "new capability being scoped" signal in captures or sessions.

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

This proposed-idea introduces the second of three synthesis modes. The 3-mode model is also
annotated on [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]] (authoritative):

| Mode           | Input                               | Output                                          |
| -------------- | ----------------------------------- | ----------------------------------------------- |
| 1. Internal    | captures + canon + sessions         | proposed canon changes, tensions, insights      |
| 2. External    | web + GitHub + papers + tools       | prior-art reports, ecosystem maps, build-vs-buy |
| 3. Comparative | internal canon + external landscape | "this area is solved", "this is genuinely novel" |

This proposed-idea is Mode 2. Mode 3 depends on both Modes 1 and 2 being stable first.

## Trigger pattern

The external signal provider should activate when synthesis detects:
- a capture describing a new capability being scoped
- a proposed-idea moving toward implementation
- a session signal about building something that might already exist

It should NOT activate on every capture or run on a schedule.

**Observation week responsibility:** when you search the web manually before building something,
capture it. That's the signal this provider is meant to automate. If those moments don't appear
in captures, the trigger pattern is weaker than assumed.

## Output shape

Emits a ReviewItem. The `prior-art-report` artifact type is NOT yet in the Decision 021 schema —
adding it requires a schema extension following the governance process defined in the
[[../decisions/021-reviewitems-as-judgment-boundary|Decision 021 annotation (2026-05-19)]].

Proposed content structure when the schema is extended:

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
- Web search capability available to synthesis runner
- `prior-art-report` artifact type added to ReviewItem schema via governed extension process

## Sequencing

Do NOT build during observation week. Use observation week to confirm the trigger pattern
(manual prior-art moments in sessions) actually shows up in captures with enough frequency to
justify the capability. If the pattern is confirmed, this becomes the first post-observation-week
synthesis extension.
