---
name: review
description: Activate the Review Facet — load pending ReviewItems with full proposal context, judgment doctrine, and recent changes. Use when triaging the review queue, approving or rejecting proposals.
argument-hint: "[optional: specific ReviewItem ID or topic]"
disable-model-invocation: true
effort: low
---

# Review Facet — Human Judgment Mode

The Review Facet context has been pre-assembled in the `[FACET: review]` block above.
Pending ReviewItems and judgment doctrine are loaded.

**Do not re-fetch.**

## If the [FACET: review] block is absent

1. `list_review_queue` — project `homelab`, status `pending`
2. `search_docs` — doc_type `homelab`, category `decisions`, query `human judgment ReviewItem`
3. `get_recent_changes` — project `homelab`

## Commands

```
prismo review list                   — full queue with status
prismo review show <id>              — full proposal text
prismo review approve <id>           — writes canon + commits + reindexes
prismo review reject <id> -r <why>   — closes with reason
prismo review edit <id>              — opens editor, then writes + commits
```

## What you are doing

Evaluating proposals against Prismo's canon doctrine — not general software quality.
What you approve becomes canon. What you reject informs future synthesis calibration.
