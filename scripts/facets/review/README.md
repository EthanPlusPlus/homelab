# Review Facet

**Purpose:** Shift into human-judgment mode — load pending ReviewItems with full context and active doctrine for triage.

**Activation:** `/review [optional: specific item ID or topic]`
Or automatic when a message is classified as ReviewItem triage.

---

## What It Loads

| Loader | What it fetches | Why |
|--------|----------------|-----|
| `pending_reviews` | Up to 15 pending ReviewItems | The inbox — what needs judgment |
| `judgment_doctrine` | Decisions about ReviewItem boundary, approval patterns | The frame for evaluation |
| `recent_changes` | `context/recent-changes.md` | What changed recently — context for evaluating proposals |
| `domain_specific` | Semantic search on `$ARGS` | If you named a specific topic, loads relevant decisions |

---

## Evaluation Framework

Evaluate against **Prismo's canon doctrine**, not general software quality.

**Approve when:** coherent, correct, well-placed, extends existing doctrine naturally, no duplication
**Reject when:** wrong artifact type, duplicates existing canon, inconsistent with active decisions
**Edit when:** correct direction but needs refinement before landing

---

## Commands

```bash
prismo review list                   # full queue
prismo review show <id>              # full proposal text
prismo review approve <id>           # writes canon + commits + reindexes
prismo review reject <id> -r <why>   # closes with reason
prismo review edit <id>              # opens editor, then writes + commits
```

---

## What You Are Doing

What you approve becomes canon. What you reject is recorded and informs synthesis-service calibration (it adjusts confidence thresholds based on rejection patterns over time).

This is the human-judgment boundary from Decision 021. The review queue is the only place in Prismo where organizational direction is actively set.

---

## Files

| File | Purpose |
|------|---------|
| `facet.yaml` | Machine-readable definition |
| `SKILL.md` | Claude Code thin adapter with fallback |
| `README.md` | This file |
