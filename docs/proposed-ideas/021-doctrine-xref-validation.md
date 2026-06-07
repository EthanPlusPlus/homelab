---
id: "021"
title: doctrine-service — detect_broken_xrefs() rule
status: proposed
record_type: canonical
date: 2026-06-07
---

# 021 — Doctrine Cross-Reference Validation

## Status

Proposed. Surfaced via synthesis from a broken `[[...]]` link found in Decision 033.

## The Idea

Add `detect_broken_xrefs()` as a doctrine-service validation rule alongside the
existing structural checks:

- `detect_supersession_cycles()` — already built
- `detect_source_hash_drift()` — already built
- `detect_broken_xrefs()` — **this proposal**

A broken cross-reference is any `[[...]]` citation in canon where the referenced
slug does not match an existing file in `docs/decisions/`, `docs/proposed-ideas/`,
`docs/architecture/`, or `docs/runbooks/`. This is a deterministic check — no model
required. Law 1 territory.

## Why it matters

`[[...]]` links are how canon documents reference each other. Broken links:
- Fail silently in MCP lookups (the context-server retriever follows links to load
  related docs — a broken slug returns nothing, no error)
- Accumulate when files are renamed (the naming convention has changed multiple
  times as the project has matured)
- Are currently only caught by Sukuna passes, which are manual and Claude-specific

## Implementation shape

```python
def detect_broken_xrefs(canon_root: Path) -> list[dict]:
    """
    Walk all .md files under canon_root/docs/.
    Extract all [[slug]] and [[slug|label]] patterns.
    For each slug, check whether slug.md exists in any of the known subdirs.
    Return violations: {file, slug, line_number}.
    """
```

Expose via `GET /doctrine/validate` (already aggregates all rules) and
`GET /doctrine/xrefs` as a standalone endpoint.

## Why not a runbook

A runbook describes a manual process. This check is mechanical — given a list of
`[[...]]` references and a list of files that exist, the broken ones are
deterministically knowable. Building it as a doctrine-service rule means it runs
automatically on every `GET /doctrine/validate` call, not on a human-triggered
cadence.

## Relation to Sukuna distillation

Sukuna currently catches cross-reference drift as part of its consistency pass
(step 1 of the SEQUENCE). That works because Sukuna floods a Claude session with
the full canon. The goal is to absorb Sukuna's *structural* checks into
doctrine-service (deterministic, Law 1) and its *semantic* checks into
synthesis-service (interpretive, Law 2). This rule is the first structural
Sukuna check that can be fully mechanised.

## Trigger for building

When broken xrefs are found during a Sukuna pass or ReviewItem triage more than
once in a session — which is already happening. The doctrine-service infra exists;
adding a rule is low-effort.

## Related

- [[../decisions/017-three-architectural-laws|Decision 017]] — Law 1: structural
  truth is deterministic; this check belongs here
- [[../decisions/023-synthesis-interpretive-augmentation|Decision 023]] — doctrine
  vs synthesis boundary
- [[013-sukuna-as-synthesis-consumer|PI-013]] — Sukuna as synthesis consumer;
  this is part of the structural subset being distilled out
- [[../decisions/034-phase-6-observability-layer|Decision 034]] — doctrine-service
  owns structural coherence
