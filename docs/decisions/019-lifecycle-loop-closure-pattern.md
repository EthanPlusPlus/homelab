# Decision 019 — Lifecycle loop closure pattern

## Status
Adopted

## Date
2026-05-16

## Context

Phase 1 wrote `lifecycle-semantics.md` defining when canon items are stale. Phase 2 shipped
`get_stale_items` — the detection capability. Nothing invokes it. No cron, no scheduled pass,
no notification, no surface that puts stale items in front of a human. The detection is
fully built; the enforcement loop is open at both ends.

Sukuna 2026-05-15 flagged this. The ChatGPT review reframed it: the failure mode is not
storage limits but **attention dilution**. Stale doctrine doesn't just clutter — it competes
with active doctrine for retrieval ranking and model attention. The longer the loop stays
open, the worse retrieval quality gets, regardless of how good the indexer is.

Phase 3 (doctrine-service, synthesis-service) builds on top of canon. Building on top of
canon that is silently drifting produces architecture that is "theoretically maintained" —
which is exactly how organizational systems rot.

## Decision

A lifecycle loop is closed when these four steps complete:

1. **Detect** — stale state is identified by structural rules (`get_stale_items` already
   does this).
2. **Surface** — detection is delivered to a human via some operational interface (CLI,
   email digest, dashboard — all valid; the abstraction is interaction surface, not browser).
3. **Acknowledge** — the human acts (resolves, defers, archives, dismisses) and that action
   is recorded.
4. **Propagate** — acknowledgment state changes are reflected in canon (or in operational
   state if the resolution is deferral).

Without step 3, the same items appear forever and humans habituate. Signal becomes wallpaper.
Acknowledgment is the load-bearing step that most "alert systems" omit and that turns them
into noise.

### Acknowledgment schema (required)

Stale items gain acknowledgment state, persisted either in canon frontmatter or in the
operational state database:

```yaml
stale_acknowledged_at: <ISO 8601 or null>
stale_acknowledged_by: <contributor id or null>
stale_resolution: <one of: pending | resolved | deferred | dismissed | archived>
stale_resolution_note: <freeform string or null>
stale_reviewed_through: <ISO 8601 — until this date, do not re-surface>
```

`get_stale_items` filters out items with `stale_reviewed_through > now` by default. This is
how acknowledgment translates back into retrieval.

### Implementation neutrality

This decision specifies the *pattern*, not the implementation. Acceptable implementations:

- `prismo stale` CLI listing + `prismo stale ack <id>` for acknowledgment.
- Email digest with reply-to-acknowledge or magic-link acknowledgment.
- A web inbox view (Phase 5).
- A Discord/Telegram bot.
- Pre-session-start surfacing in `start_session` response.

Any of these closes the loop if all four steps are present. The *first* implementation should
be the simplest one that fits the operational reality — at current scale (one primary
contributor), that is a CLI digest with explicit acknowledgment commands.

### Prerequisite for Phase 3

doctrine-service (Phase 3, Layer 1 territory under [[017-three-architectural-laws|Decision 017]])
has staleness enforcement as a responsibility. Phase 3 cannot start until the loop is
demonstrated closed at small scale. A doctrine-service built on top of an open loop is
ornamental, not operational.

This makes loop closure a hard gate. The gate is **signal-conditional**, not time-conditional:

- Start Phase 3 when the loop has actually surfaced at least one real stale item *and* an
  acknowledgment has been applied through the live pattern (detect → surface → ack → propagate).
- OR — if after two operational weeks the loop has surfaced nothing because canon metadata
  cannot generate signal (e.g., missing `updated_at` on most docs), conclude the loop is
  built-but-unobservable-at-scale. In that case, start Phase 3 — doctrine-service's first job
  is to backfill the metadata that makes the loop testable.

The earlier "two-week soak" framing was arbitrary and assumed signal would emerge at our scale.
At a contributor count of one and a slow change rate, that assumption is wrong. Gating on
"have we actually closed the loop once?" is the real test.

## Rationale

**Why pattern, not implementation.** Specifying the implementation would couple this
decision to an interface that will change. Specifying the pattern lets the implementation
evolve (CLI → web inbox → ambient) without re-deciding the architecture.

**Why acknowledgment is structurally required, not optional.** Without it, the loop reduces
to "detect and notify," which is the dominant failure mode of operational tooling. The
acknowledgment step is what creates a feedback channel that retrieval can act on.

**Why this gates Phase 3.** doctrine-service's job is lifecycle enforcement. If the
enforcement loop is not closed at small scale, doctrine-service is being designed against
an unknown — what does enforcement *feel like* in practice? CLI operation surfaces the
real shape of the work before it gets ossified in a service interface.

**Why "Layer 4 = interaction surface, not browser" matters here.** Reframing Layer 4 as
the abstraction rather than the implementation unblocks loop closure. Waiting for a web
UI to close the loop is the kind of premature scope expansion that has prevented closure
for months. A CLI command is already Layer 4 in the abstraction the masterplan actually
defines.

## Consequences

- **Phase 3 is gated on this loop being live and operating for two weeks minimum.**
- **An `acknowledgments` table is added to the operational state database** in the next
  workflow-state-service iteration. Schema as specified above.
- **A `prismo stale` CLI subcommand is added** to the `prismo` script, calling `get_stale_items`
  and rendering with acknowledgment status visible.
- **A scheduled job** (cron on the VM, hourly or daily) calls `get_stale_items` and surfaces
  changes via whatever channel is configured (initially: stdout to a log; email later).
- **`get_stale_items` API gains an `include_acknowledged` parameter**, default false.
- **Sukuna passes shift focus** — staleness is no longer something Sukuna surfaces narratively
  in section 1; it is mechanically tracked. Sukuna's role narrows to observations and
  thinking sections.
- **This is the first concrete instance** of "Layer 4 = interaction surface, not browser"
  in the codebase, and sets precedent for the minimal Layer 4 slice (see v2-progress.md
  Phase 5 notes).
