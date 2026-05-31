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

**Do not spawn a subagent or run the `scripts/sukuna.md` script.** That is the V1 path —
it writes to `docs/drafts/` which violates Decision 021. The facet IS the Sukuna pass.
Run it inline: work through the three sections yourself using the loaded context above,
then surface each finding as `prismo capture "<finding>"`. Captures flow through
synthesis → ReviewItems → human review.

This Facet replaces the sukuna.md agent's context-loading step. No markdown files.
No `docs/drafts/`. No subagent dispatch.
