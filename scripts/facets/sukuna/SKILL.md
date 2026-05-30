---
name: sukuna
description: Activate the Sukuna Facet — shift into canon maintenance mode with stale items, pending reviews, open proposals, and recent changes loaded. Use when doing a consistency pass, auditing the canon, or surfacing observations.
argument-hint: "[optional: specific area to focus on]"
disable-model-invocation: true
effort: low
---

# Sukuna Facet — Canon Maintenance Mode

The Sukuna Facet context has been pre-assembled in the `[FACET: sukuna]` block above.
Stale items, pending reviews, open proposals, and recent changes are loaded.

**Do not re-fetch. Surface findings as captures — not drafts.**

## If the [FACET: sukuna] block is absent

1. `get_recent_changes` — project `homelab`
2. `search_docs` — doc_type `homelab`, category `decisions`, top_k `10`
3. `search_docs` — doc_type `homelab`, category `proposed-ideas`, status `proposed`, top_k `8`
4. `list_stale_items` — project `homelab`
5. `list_review_queue` — project `homelab`, status `pending`

## Important

This Facet replaces the sukuna.md agent's context-loading step.
Surface findings as `prismo capture "<finding>"` — not by writing files.
See proposed-idea 013 for the full Sukuna → ReviewItems path.
