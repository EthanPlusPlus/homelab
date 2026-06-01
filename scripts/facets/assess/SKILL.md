---
name: assess
description: Activate the Assess Facet — shift into structured evaluation mode with governing doctrine, active proposals, runtime topology, and recent changes loaded. Use when stress-testing a decision, evaluating tradeoffs, or doing a risk assessment before committing to a direction.
argument-hint: "[optional: specific decision or approach to evaluate]"
disable-model-invocation: true
effort: medium
---

# Assess Facet — Decision Evaluation Mode

The Assess Facet context has been pre-assembled in the `[FACET: assess]` block above.
Governing doctrine, active proposals, runtime topology, and recent changes are loaded.

**This is an evaluation session, not a design session.** Work through the six-step
heuristic in the loaded context. Make a call at the end.

## If the [FACET: assess] block is absent

1. `search_docs` — doc_type `prismo`, category `decisions`, top_k `10`
2. `search_docs` — doc_type `prismo`, category `proposed-ideas`, status `proposed`, top_k `8`
3. `get_recent_changes` — project `prismo`
4. `get_runtime_topology`
5. If a specific topic was provided, `search_docs` on that topic, top_k `8`

## Important

Do not design solutions in this session — that is Architect mode.
Surface findings via `prismo capture "<finding>"` if genuinely novel.
End with an explicit recommendation: Proceed / Proceed with conditions / Defer / Don't do this.
