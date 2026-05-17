---
id: "012"
title: Drafts as adapter ritual — promote returns payload, not file
status: superseded
superseded_by: decisions/021-reviewitems-as-judgment-boundary.md
record_type: canonical
notes: superseded by Decision 021 on 2026-05-17 — drafts disappear entirely under the new model
---

# 012 — Drafts as adapter ritual

## Status

**Superseded 2026-05-17 by [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]].**

Reason: this proposal tried to fix the drafts flow by changing the promote
endpoint contract (return payload not file). Decision 021 eliminates the
drafts step entirely — captures become internal signals consumed by
synthesis-service, and the human-facing work unit becomes a ReviewItem in a
service-backed queue. The promote-step refactor is moot because the promote
step itself disappears.

The diagnosis in this proposal (filesystem-coupled, bifurcated state,
conflates lifecycle and artifact) remains valid and is referenced by
Decision 021. The proposed remedy was too small.

Kept as historical record of the V2 smell that triggered the larger
architectural realization.

## Origin

Surfaced 2026-05-16 during capture triage. Ethan questioned the drafts/ workflow:
"how does this align with prismo as a whole, how has this currently been reinforced,
and how does this step work on other platforms that don't have obsidian?" Three-way
analysis (Claude → ChatGPT → Ethan) converged on the same diagnosis and direction.

## The smell

The current capture → canon flow:

```
prismo capture                  → POST /workflow/capture       (state: pending-review)
prismo capture promote <id>     → POST /workflow/capture/{id}/promote
                                → CLI writes file to ~/canon/<project>/docs/drafts/
human edits in obsidian/vim     → filesystem
human renames + moves to canon/ → filesystem
human re-indexes + commits      → filesystem + git
```

Three structural problems:

1. **Filesystem-coupled.** Assumes workstation + editor + git checkout. Cannot serve
   Layer 4 surfaces the masterplan commits to: WhatsApp (nearest-term), web UI (Phase 5),
   mobile. A WhatsApp contributor cannot open `~/canon/project/docs/drafts/foo.md`.
2. **Bifurcated state.** Capture lifecycle lives in workflow-state-service DB; draft
   content lives on disk. Service believes `status=promoted, promoted_to_path=X.md`,
   but the file may have been renamed, edited, moved, or deleted manually. Service has
   no way to know.
3. **Conflates two concepts.** "Mark this capture ready for canon" (lifecycle) and
   "produce a starting-point document" (artifact scaffolding) are different things,
   glued together by current implementation.

## How it got here

Not by deliberate decision — by accretion:

- The indexer `record_type=draft` tag isolated drafts from active retrieval (tactical).
- Today's `promote` endpoint refactor moved artifact generation into the service
  (improved discipline, kept disk coupling).
- No decision document names "drafts" as an architectural concept.

This is the same pattern that produced V1 Claude-coupling: locally-convenient adapter
assumptions slowly becoming ontology. See [[../decisions/020-doctrine-service-structural-coherence-engine|Decision 020]] for the
broader memory-vs-interpretation separation this smell violates.

## Why "DraftService" (Option A) is the trap

The instinct on noticing this smell is "make drafts a real service concept." That path
leads to: draft persistence semantics, draft sync semantics, draft conflict resolution,
draft ownership, draft publishing rules. Suddenly Prismo has accidentally rebuilt
Google Docs.

Prismo owns: cognitive continuity, provenance, canon integrity, retrieval, synthesis
boundaries. It does not own collaborative rich-text editing infrastructure. Adding
DraftService would be classic accidental platform complexity.

## The proposed direction — Option C: promote returns payload

The capability becomes:

```
POST /workflow/capture/{id}/promote
  →
  {
    "suggested_type": "decision" | "proposed-idea" | "runbook" | ...,
    "suggested_title": "...",
    "suggested_destination": "decisions/021-...md",
    "initial_content": "...",
    "source_capture_ids": [...],
    "related_decisions": [...],
    "extracted_rationale": "..."
  }
```

Adapters decide what to do with the payload:

- **CLI adapter** writes a temp markdown file (preserving today's affordance for
  workstation contributors)
- **Web UI** opens a structured editor pre-filled with `initial_content`
- **WhatsApp** sends a condensed editable message
- **Mobile** opens a compose view

The service knows nothing about "drafts." It knows `captures` (operational state) and
`canon` (durable truth). The middle layer is adapter convenience, not architecture.

Filesystem becomes *one possible editing surface*, not *the architecture*.

## What to preserve

The genuinely valuable part of the current flow is **generated scaffolding** — the
service knowing enough about a capture to propose: this should be a `decision` not a
`proposed-idea`, here's a suggested filename, here's an initial structure, here are the
provenance pointers back to source captures and related canon.

That intelligence stays. It just stops being filesystem-shaped.

## What this changes

- **`POST /workflow/capture/{id}/promote`** returns a structured payload instead of
  writing a file. Response schema as above.
- **`prismo capture promote`** becomes a thin CLI adapter that takes the payload and
  writes a local scratch file (preserving today's UX for workstation contributors).
- **`drafts/` folder semantics shift** from "operational state on disk" to "workstation
  scratch space." The indexer's `record_type=draft` tag stays as a retrieval filter.
- **Sukuna's report-writing** (currently writes to `drafts/`) needs the same reframe:
  Sukuna runs return a payload; the runner decides where the report goes. Today's
  workstation behavior preserved by default.
- **Capture lifecycle gets a new state** (proposed: `ready-for-canon`) so the service
  can track "this has been promoted to a payload but not yet authored into canon."
  Without this, the service loses observability once promote returns.
- **Web UI (Phase 5) and WhatsApp adapter (Layer 4 nearest-term) inherit the contract
  for free** — they don't have to invent their own draft handling, they consume the
  same payload.

## Dependencies / sequencing

- Should land before web UI work begins, otherwise web UI will reinvent draft handling.
- Should land before WhatsApp adapter, same reason.
- Does NOT block doctrine-service Day-1 (Decision 020) — independent concern.
- Touches the existing promote endpoint, so requires updating capability-contracts.md
  (Service Rule check will enforce this).

## Open design questions

1. **`ready-for-canon` lifecycle state** — does the service track which payloads were
   issued, or is "promote" a stateless content-generation call? Tracking gives
   observability; statelessness keeps the service simpler. Lean: track, because losing
   capture-to-canon lineage defeats half the value of having captures in the first place.
2. **What happens to existing drafts/ files?** Existing Sukuna reports + already-promoted
   captures live there. Migration: leave them as a workstation cache, do not retroactively
   move into the new model. New promotions produce payloads; CLI adapter writes them to
   the same `drafts/` folder for continuity. Folder becomes legacy-shaped but harmless.
3. **Authentication on promote** when invoked from non-workstation surfaces — out of
   scope for this proposal; ties to broader auth story for web UI / WhatsApp.

## Related

- [[../decisions/017-three-architectural-laws|Decision 017]] — Law 3: capability
  contracts primary; adapters disposable. This proposal applies Law 3 to the drafts
  flow.
- [[../decisions/018-synthesis-provenance-and-recursion-prevention|Decision 018]] —
  drafts current `record_type` separation came from this decision's pattern.
- [[../decisions/020-doctrine-service-structural-coherence-engine|Decision 020]] —
  memory-vs-interpretation separation. Drafts currently sit in the unowned middle ground
  this separation tries to eliminate.
- Capture `e7f51070` — memory-vs-interpretation framing (this proposal is one
  application of it).
- Capture `1801ff71` — V2-pure relocation reframe (this proposal is another instance of
  the same pattern: adapter rituals becoming ontology).

## Meta-pattern worth naming

ChatGPT 2026-05-16: "Not through one bad decision. Through locally-convenient adapter
assumptions slowly becoming ontology."

Three instances of this pattern observed in V2 work to date:
1. Claude-specific memory files (CLAUDE.md, MEMORY.md) — V1 adapter assumption that
   became ontology. Re-examined via V2-pure lens (capture `1801ff71`).
2. Production-state-dependent gates (Decision 019's two-week soak) — testing assumption
   that became architecture. Re-examined (capture `ff0335a0`).
3. Drafts on disk — workstation editing assumption that became workflow. Being
   re-examined now.

This pattern recurring three times in one session suggests it deserves canonical naming —
candidate term: "**adapter ontology drift**." Worth promoting to a named principle or
decision once a fourth instance confirms it's a real recurring failure mode.
