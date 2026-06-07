---
id: "020"
title: Workstreams — logical grouping layer above sessions
status: proposed
record_type: canonical
date: 2026-06-07
---

# 020 — Workstreams

## Status

Proposed. The `active_workstreams` field is already reserved in the session
hydration output (returns 0). The data model slot exists; the concept is not yet built.

## The Problem

A Prismo session is 1:1 with a Claude Code chat. When a context window fills,
a new chat starts and a new session is created. A logical unit of work
(e.g., "build Phase 6 observability") spans many sessions over many days.

There is currently no object that represents this. You cannot answer:
- "What did I do on Phase 6 across all sessions?"
- "How many captures came out of the Phase 6 workstream?"
- "How long did the auth layer decision take end-to-end?"

Session continuity is handled at the knowledge layer (hydration block), not
at the data model level. That works for forward continuity but not for
retrospective grouping.

## The Idea

A **workstream** is a named container that groups related sessions.

```
workstream  → "Phase 6 observability" (spans days, multiple chats)
  session   → individual Claude Code chat (1–2 hours, one context window)
    capture → signals extracted from that session
```

A workstream has:
- A name / short description
- Status: active / closed
- Sessions (1..N)
- Aggregate capture count
- Date range (first session → last session)

Sessions can optionally reference a workstream. A session without a workstream
reference is standalone — valid, doesn't require a workstream to exist.

## API surface (rough)

```
POST /workflow/workstream/start   { name, contributor_id }
POST /workflow/workstream/end     { workstream_id }
GET  /workflow/workstreams        → list
GET  /workflow/workstream/:id     → detail + sessions + capture count
PATCH /workflow/session/:id       { workstream_id }  # assign session to workstream
```

## Trigger for building

When you find yourself wanting to query "what happened during X" across
multiple sessions, and the answer isn't easily available from session history.

Also when Prismo's Room History tab needs meaningful grouping — a flat list
of 50 sessions is not readable. Workstreams give History a natural hierarchy.

## Constraints

- Sessions must remain valid without a workstream (no required FK)
- Workstream assignment can be retroactive — sessions should be assignable
  after the fact
- Law 1 applies: workstream start/end/assignment is deterministic (Layer 2,
  not Layer 3)

## Related

- [[../decisions/014-workflow-state-service-architecture|Decision 014]] — the
  service this belongs to
- [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]] — captures
  roll up through sessions; workstreams would add one more aggregate level
- [[019-session-aware-facet-activation|PI-019]] — session context feeds facet
  activation; workstream context could extend this
