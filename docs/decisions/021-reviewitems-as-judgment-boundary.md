---
id: "021"
title: ReviewItems as the human-judgment boundary — synthesis emits, humans approve, canon updates
status: active
record_type: canonical
category: governance
date: 2026-05-17
---

# Decision 021 — ReviewItems as the human-judgment boundary

## Status
Adopted

## Date
2026-05-17

## Context

This is the consolidation decision. It establishes Prismo's architectural
center of gravity and supersedes several in-flight workstreams that were
solving local problems without naming the global one.

The realization arrived through triangulation (Ethan ↔ Claude ↔ ChatGPT)
over 2026-05-16 and 2026-05-17:

- The capture → triage → promote → draft → author flow demands too much
  manual administration. Even one contributor at fast iteration cadence
  drowns in it.
- Drafts on disk conflate operational state with canon authoring, creating
  an unowned middle ground (see superseded [[../proposed-ideas/012-drafts-as-adapter-ritual|proposed-idea 012]]).
- Phase 0–2.5 built considerable *latent* modularity (Three Laws, Service
  Rule, SynthesisProvider, record_type separation, workflow-state-service)
  but the operational loop is still mostly manual because synthesis-service
  was scoped and deferred while structural plumbing kept getting refined.
- Layer 4 surfaces (web UI, WhatsApp, mobile, ambient) cannot be cleanly
  integrated against the current model because there is no external
  integration contract — only an implicit "workstation + filesystem + git"
  assumption.

The center of gravity Prismo has been circling without naming is
**human judgment boundaries**. Everything else should optimize around
reducing the energy required to cross those boundaries safely.

## Decision

### Core principle

> **Operational signals are internal. Human-facing work units are ReviewItems.**

The system's purpose is to minimize the cognitive and administrative energy
required for a human to make canon-shaping decisions. Captures, diffs, drift,
Sukuna findings, contradictions, and structural violations are internal
signals. They are not user-facing work products. The single user-facing work
product is the **ReviewItem**: a proposed canon change with full context,
provenance, and rationale, ready for `approve | reject | edit`.

### The end-to-end loop

```
Conversation / activity / scheduled checks
        ↓
Operational signals collected
(captures, diffs, drift, Sukuna findings, structural contradictions)
        ↓
synthesis-service evaluates significance + applies quality gate
        ↓
ReviewItem emitted to review-queue
        ↓
Human reviews via any Layer 4 surface
(CLI, web UI, WhatsApp, mobile, ambient)
        ↓
Approve / reject / edit
        ↓
Approved → canon written + committed + indexed
Rejected → ReviewItem closes, source signals dismissed, rejection_reason recorded
Edited  → human-modified content becomes the approved version
        ↓
doctrine-service validates structural integrity post-approval
([[020-doctrine-service-structural-coherence-engine|Decision 020]] applies)
```

This is the first fully coherent end-to-end loop in the project. Every
arrow is an HTTP contract. No filesystem coupling above Layer 1.

### ReviewItem contract

The ReviewItem is the universal integration primitive. Stable schema:

```json
{
  "id": "rv_<uuid>",
  "created_at": "<iso8601>",
  "project": "homelab",
  "status": "pending | approved | rejected | edited-approved | superseded",
  "sources": {
    "capture_ids": ["..."],
    "conversation_refs": [{"session_id": "...", "excerpt": "..."}],
    "doctrine_signals": [{"rule": "...", "item_id": "..."}],
    "synthesis_run_id": "..."
  },
  "proposal": {
    "artifact_type": "decision | proposed-idea | runbook-update | annotation | recent-changes-entry",
    "suggested_destination": "decisions/022-...md",
    "frontmatter": {...},
    "content": "<full markdown body>",
    "affected_existing_docs": ["..."]
  },
  "rationale": "Why synthesis believes this should become canon",
  "confidence": 0.0,
  "model_used": "claude-opus-4-7",
  "prompt_template_id": "synthesis.canon-proposal.v1",
  "decided_at": "<iso8601 | null>",
  "decided_by": "ethan | null",
  "rejection_reason": "redundant | too-weak | already-represented | incorrect-interpretation | wrong-artifact-type | too-speculative | not-durable | other",
  "rejection_note": "<freeform | null>",
  "edit_diff": "<unified diff | null>"
}
```

`rejection_reason` is an enumerated field from day one. Without categorized
rejections, synthesis-service tuning is guesswork. With them, the system has
an empirical feedback loop on its own emission quality.

### Endpoints (review-queue capability surface)

These land in `workflow-state-service` (the queue is operational state):

```
GET    /review/queue?status=pending&project=homelab   → list
GET    /review/queue/{id}                              → fetch single
POST   /review/queue                                   → create (synthesis-service is the producer)
POST   /review/queue/{id}/approve                      → approve, triggers canon write
POST   /review/queue/{id}/reject                       → reject with rejection_reason + note
POST   /review/queue/{id}/edit                         → submit edited content; transitions to edited-approved or stays pending
PATCH  /review/queue/{id}                              → update non-decision fields (assignee, claim)
```

capability-contracts.md HTTP Endpoint Mapping table updates alongside
implementation (Service Rule will fail the app start otherwise).

### Synthesis-service scope (minimal, day-one)

One synthesis pattern only:

```
recent unresolved captures + recent canon context
   → high-confidence proposed canon change
   → ReviewItem
```

Built-in **quality gate** from day one (non-negotiable — without it, the
queue becomes the new noise problem):

- **Confidence threshold** — only emit items above N (initial value TBD by observation)
- **Deduplication** — semantic similarity check against pending queue items
- **Backpressure** — if pending queue exceeds M items, stop emitting until reviewed
- **Single conceptual change rule** — one proposal per ReviewItem; don't batch unrelated changes

Explicitly **NOT** scoped for day one:
- contradiction reasoning
- canon narration / onboarding generation
- recursive synthesis chains
- autonomous restructuring
- "AI chief of staff" features
- review tiers / auto-approval (post-observation refinement)

### Layer 4 surfaces become thin ReviewItem renderers

Every surface is a renderer + action handler for ReviewItems. No surface
invents its own ontology:

- CLI: `prismo review` — terminal TUI listing pending items, j/k navigation, a/e/r actions
- Web UI: ReviewItem dashboard
- WhatsApp: ReviewItem inbox (item as message, approve/reject via reply)
- Mobile: ReviewItem review surface
- Ambient: push notifications + voice approval

The CLI surface ships first. Web UI does NOT ship first — CLI is the fastest
iteration loop for ontology validation. Surface investment happens after the
ReviewItem contract proves out via observation.

### What this retires

Explicit retirements / supersessions:

- **[[../proposed-ideas/012-drafts-as-adapter-ritual|Proposed-idea 012]]** —
  superseded. The promote-step refactor is moot because the promote step
  itself disappears. Mark closed with reference to this decision.
- **`prismo capture promote`** — deprecated. Becomes a no-op (or alias for
  "consider for synthesis") and is removed once synthesis-service is live.
- **`drafts/` folder** — legacy. Read-only history. Nothing new lands there.
  Existing files stay where they are (no migration). Sukuna reports
  reorganize per next bullet.
- **Sukuna as standalone markdown-report generator** — Sukuna becomes a
  synthesis-service consumer. Sukuna runs schedule synthesis invocations
  that emit ReviewItems into the queue. No more `drafts/sukuna-YYYY-MM-DD.md`.
- **doctrine-service Day-1 build queue** — deferred until after synthesis-service
  + review-queue + at least one observation week. [[020-doctrine-service-structural-coherence-engine|Decision 020]]
  remains valid; doctrine-service is sequenced as the *post-approval guardrail*,
  not the next build.

### What stays valid

- [[017-three-architectural-laws|Decision 017]] (Three Laws + Service Rule) —
  unchanged, more important than ever
- [[018-synthesis-provenance-and-recursion-prevention|Decision 018]]
  (record_type, provenance) — applies directly to ReviewItem outputs.
  Approved ReviewItems become canon docs with full provenance chain
  (source captures, model used, prompt template, human approver). This is
  the audit trail that makes auto-synthesis trustworthy.
- [[019-lifecycle-loop-closure-pattern|Decision 019]] (lifecycle loop) — still
  applies to doctrine-service when it ships
- [[020-doctrine-service-structural-coherence-engine|Decision 020]]
  (doctrine-service scope) — still valid, just resequenced
- Captures themselves — stay as a useful manual safety net for "I noticed
  this and want it remembered." They become primarily synthesis-service
  fuel, not user-facing work items.

### Filesystem-for-durable-truth principle

The filesystem (canon git repos) contains:
- canon documents (decisions, proposed-ideas, runbooks, architecture, context)
- durable history (committed records)

The filesystem does NOT contain:
- operational limbo states
- half-authored workflow intermediates
- pre-approval drafts
- editing scratch space (that's adapter-local concern)

This is the V2-pure form of the filesystem's role: stable knowledge substrate,
not workflow scratchpad. Captures and ReviewItems live in workflow-state-service
(DB-backed operational state). Only approved canon writes to disk.

## Rationale

### Why "human judgment boundaries" as the center of gravity

Prismo has been circling a deeper question without naming it: what is the
system *for*? Until now, the implicit answer was "structured knowledge
management" — which is true but doesn't define the architectural primitive.
"Human judgment boundaries" names what the system actually optimizes:
the moments where a human decision shapes durable truth. Everything else
exists to make those moments easier and safer.

This framing yields immediate clarity on what to build (boundary-crossing
machinery) and what to stop polishing (workflow scaffolding that doesn't
reduce judgment-boundary energy).

### Why ReviewItems unify Layer 4

Every previous attempt to think about web UI / WhatsApp / mobile required
asking "how does this surface know about drafts / captures / promotion /
authoring?" Each surface threatened to reinvent ontology. With ReviewItems
as the universal integration primitive, surfaces become thin: they render
items, they collect a decision, they post it back. The cognitive ontology
lives in Layer 2; the surfaces are adapters in the Decision 017 Law 3 sense.

### Why synthesis-service must include the quality gate from day one

Without it, "build minimal synthesis-service" produces a noise machine.
Same triage problem as drafts, different folder. The quality gate
(confidence threshold + dedup + backpressure + single-conceptual-change)
is what makes ReviewItems durably useful instead of structurally identical
to the current capture queue.

### Why CLI surface first

Fastest iteration loop. Web UI is a serious investment; investing it before
the ReviewItem ontology proves out via observation risks calcifying the
wrong shape. CLI lets us watch behavior, tune the quality gate, refine the
schema for one week before any UI work.

### Why doctrine-service is now post-approval guardrail

Decision 020 scoped doctrine-service correctly but assumed it was the next
build because it inherited the staleness loop. Under this decision,
doctrine-service still owns structural integrity validation — but it
validates canon *after* approval, not before. Pre-approval is synthesis +
human judgment. Post-approval is doctrine. This sequencing makes both
services smaller and cleaner.

### Why this is the consolidation moment

Five prior decisions (017, 018, 019, 020, plus 014 workflow-state-service)
defined the structural and operational substrate. None of them on their own
made Prismo *useful as a system that maintains itself*. The synthesis +
review-queue addition is what activates the latent modularity. Without it,
Prismo is beautifully structured infrastructure for manually maintaining
thoughts. With it, Prismo becomes a modular cognition system that reduces
organizational labor.

## Consequences

### Immediate (architecture)

- Proposed-idea 012 marked superseded.
- doctrine-service Day-1 build deferred; Decision 020 annotated to reflect
  the resequencing.
- `drafts/` folder enters legacy state; nothing new lands there.
- `prismo capture promote` enters deprecation; behavior preserved as alias
  until synthesis-service replaces it.

### Build sequence (immediate priorities)

1. **ReviewItem contract endpoints** in workflow-state-service —
   the schema above, the seven endpoints, capability-contracts.md updated.
   Tests required (precedent: `tests/test_stale_rules.py`).
2. **Minimal synthesis-service** — one synthesis pattern, quality gate
   enforced. Lives at top-level `synthesis/` (peer to `doctrine/`, `workflow/`,
   `api/`, `context_mcp/`).
3. **`prismo review` CLI subcommand** — list / show / approve / reject / edit.
   Terminal-rendered, no UI dependency.
4. **Observe for one week** — track emission rate, approval rate, rejection
   reasons, edit frequency, time-to-decision, duplicate rate. Use observation
   to tune confidence threshold, dedup sensitivity, backpressure limits.
5. **Refine** based on observation. Only after observation should ontology
   tweaks (review tiers, auto-approval, profile-based tuning) be considered.

### Build sequence (deferred)

- Sukuna refactor as synthesis-service consumer (after synthesis ships)
- doctrine-service Day-1 capabilities (after observation week)
- Web UI ReviewItem dashboard (after CLI proves the ontology)
- WhatsApp / mobile / ambient adapters (independent, after web UI demonstrates
  the contract holds across surfaces)
- Auto-approval tiers (post-observation refinement)
- Per-contributor profile-based synthesis tuning (when contributor count > 1)
- Auth on review endpoints (when non-workstation surfaces are imminent)

### Operational

- Sukuna's existing `drafts/sukuna-*.md` files remain as historical record.
  No migration. Future Sukuna runs emit ReviewItems instead.
- The 5 promoted drafts from the 2026-05-16 triage stay in `drafts/`. Author
  them into canon manually if desired (they're rich enough to warrant
  decision/proposed-idea documents). Or treat them as raw material for the
  first synthesis-service runs once it ships.
- The 1 pending capture (`e1232d48` — adapter-ontology-drift meta-pattern)
  stays pending. It's likely an early synthesis-service test case.

### Tunability becomes centralized

The entire quality-of-output question collapses into one place: synthesis-service
emission criteria. Today's diffuse noise problems (too many captures, unclear
drafts, promote confusion, triage burden, document uncertainty) all become a
single optimization target. Empirical metrics (approval rate, edit frequency,
rejection reasons) replace vibes.

### Trustworthy by design

Because ReviewItems are reviewable, synthesis can start conservative and
evolve upward without risk. Approve only what the human approves. The
human judgment boundary makes iterative improvement safe.

### Decision 020 ↔ 021 relationship

Decision 020 said doctrine-service is the structural coherence engine.
Decision 021 says synthesis-service is the next build, and doctrine-service
sequences after as the post-approval guardrail. Both decisions stay active;
Decision 021 only changes the build *order*, not the scope of doctrine-service.

## Annotation 2026-05-19 — synthesis modes + artifact_type governance

**Three synthesis modes (future architecture direction):**

The synthesis-service capability described here (internal signals → ReviewItems) is Mode 1 of
three modes that are emerging:

| Mode         | Input                                  | Output                                        |
| ------------ | -------------------------------------- | --------------------------------------------- |
| 1. Internal  | captures + canon + sessions            | proposed canon changes, tensions, insights    |
| 2. External  | web + GitHub + papers + open-source    | prior-art reports, ecosystem maps, build-vs-buy |
| 3. Comparative | internal canon + external landscape  | "this area is solved", "this is genuinely novel" |

Modes 2 and 3 are unbuilt. Mode 2 is tracked in
[[../proposed-ideas/014-external-synthesis-prior-art|Proposed-idea 014]]. Mode 3 depends on
Mode 2 being stable. Do not build Modes 2 or 3 until Mode 1 quality gates are calibrated via
observation week.

**artifact_type is a closed set — extensions require governance:**

The `artifact_type` field in the ReviewItem contract is closed:
`"decision | proposed-idea | runbook-update | annotation | recent-changes-entry"`.

Any new artifact type (e.g. `prior-art-report`) requires:
1. Updating this decision (or a superseding decision) to document the new type
2. Updating review CLI rendering to handle the new type
3. Updating any preflight validators that enumerate valid types

New types should NOT be added casually inside proposed-ideas. Each addition is a schema change.

---

## Related captures

- `e7f51070` — memory-vs-interpretation framing (this decision operationalizes it)
- `1801ff71` — V2-pure relocation reframe (this decision is its largest application)
- `997091ae` — orchestrator-vs-runtime open question (still open; orchestrator
  partly clarified here as "the thing that drives the model when synthesis
  runs", but layer-split decision still pending)
- `30230ded` — reviewed_at deferred (still deferred; even less needed now that
  synthesis evaluates significance directly)
- `90df2bbc` — triangulation pattern (this decision is itself a product of
  the pattern, fourth confirmed instance)
- `e1232d48` — adapter ontology drift meta-pattern (this decision avoids a
  fifth instance by stopping promote-step polishing before it became ontology)
