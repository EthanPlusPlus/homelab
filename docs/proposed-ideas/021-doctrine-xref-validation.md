---
id: "021"
title: doctrine-service — detect_broken_xrefs() rule
status: experimental
record_type: canonical
date: 2026-06-07
---

# 021 — Doctrine Cross-Reference Validation

## Status

Experimental — built 2026-06-07. Rule is live in `doctrine/rules.py` and exposed
via `GET /doctrine/xrefs` and `GET /doctrine/validate`. Surfaced via synthesis from
a broken `[[...]]` link found in Decision 033.

## The Idea

Add `detect_broken_xrefs()` as a doctrine-service validation rule alongside the
existing structural checks:

- `detect_supersession_cycles()` — already built
- `detect_source_hash_drift()` — already built
- `detect_broken_xrefs()` — **built 2026-06-07**

A broken cross-reference is any `[[...]]` citation in canon where the referenced
slug does not resolve to an indexed doc. Note: the check runs against the ChromaDB
index, not the filesystem directly — a newly written file that has not been re-indexed
will appear as a broken target. Re-index before treating results as authoritative.
This is a structural check — no model required. Law 1 territory.

## Why it matters

`[[...]]` links are how canon documents reference each other. Broken links:
- Fail silently in MCP lookups (the context-server retriever follows links to load
  related docs — a broken slug returns nothing, no error)
- Accumulate when files are renamed (the naming convention has changed multiple
  times as the project has matured)
- Are currently only caught by Sukuna passes, which are manual and Claude-specific

## Implementation

Pure function in `doctrine/rules.py` — no I/O, testable without ChromaDB:

```python
def detect_broken_xrefs(
    all_docs: list[dict],          # [{"path": str, "metadata": dict}, ...]
    current_contents: dict[str, str],  # {path: full_text} from ChromaDB
) -> list[dict]:
    """
    Extract all [[slug]] and [[slug|label]] patterns from each doc's content.
    Resolve each slug relative to the citing file's directory:
      - Slug with "/" → relative path normalised from source dir, append .md if needed
      - Bare slug (no "/") → suffix-match against any indexed path (/{slug}.md)
    Deduplicate per-doc. Return violations: {"rule": "broken_xref", "path", "detail"}.
    """
```

Exposed via `GET /doctrine/validate` (aggregates all rules) and
`GET /doctrine/xrefs` as a standalone endpoint. 12 tests in `tests/test_doctrine.py`.

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
