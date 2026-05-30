# Sukuna Facet

**Purpose:** Shift into canon maintenance mode — load stale items, pending reviews, open proposals, and recent changes to support a structured observation pass.

**Activation:** `/sukuna [optional: specific area to focus on]`
Or automatic when a message is classified as a canon review / consistency pass.

---

## What It Loads

| Loader | What it fetches | Why |
|--------|----------------|-----|
| `recent_changes` | `context/recent-changes.md` | What has shifted recently — starting point for consistency check |
| `active_doctrine` | Top 10 active decisions | The governing constraint set to check against |
| `open_proposals` | Top 8 proposed-ideas (status: proposed) | What's actively being considered — check for stale/superseded |
| `stale_items` | Unacknowledged stale items | What has already been flagged by the lifecycle rules |
| `pending_reviews` | Pending ReviewItems | What's waiting for judgment — relevant to observation pass |
| `topology` | `GET /runtime/topology` | Current intelligence roles and authority — structural truth |

---

## Three Passes

Work through in order — don't skip ahead:

**1. Consistency** — terminology drift, stale cross-references, formatting divergence, status mismatches

**2. Observations** — patterns with no decision record, contradictions, concepts never formally defined, proposed-ideas whose purpose is already answered

**3. Thinking** — no constraints, challenge everything, name the most important unconsidered question

---

## Surface Findings as Captures

Do **not** write to `docs/drafts/`. Do **not** modify canon directly.

`prismo capture "<finding>"` for each observation. Captures flow through synthesis → ReviewItems → human review. This is the Decision 021 path.

The `sukuna.md` agent (scripts/sukuna.md) still writes to drafts/ as V1 behavior. This Facet is the V2 replacement — same cognition, correct output path.

---

## Files

| File | Purpose |
|------|---------|
| `facet.yaml` | Machine-readable definition |
| `SKILL.md` | Claude Code thin adapter with fallback |
| `README.md` | This file |
