---
name: migrate
description: Activate the Prismo Migration Facet — shift into migration-aware reasoning with interface dependency tracing, rollback awareness, and Service Rule enforcement. Context is pre-assembled by the pipeline service. Use before any migration, interface change, schema change, or breaking refactor.
argument-hint: "[optional: what is being migrated]"
disable-model-invocation: true
effort: low
---

# Migration Facet — Runtime Cognition Shaping

The Migration Facet context has been pre-assembled in the `[FACET: migrate]` block above.
Reason from that context — migration doctrine, architectural laws, and topology are loaded.

**Do not re-fetch.**

## If the [FACET: migrate] block is absent

1. `get_doc_section` — `decisions/017-three-architectural-laws.md`, doc_type `homelab`
2. `search_docs` — doc_type `homelab`, category `decisions`, query `migration interface contract service rule`
3. `get_recent_changes` — project `homelab`
4. `get_runtime_topology`

## The rule this Facet enforces

The doctrine bug (2026-05-29 pgvector migration): interface changed, call site in
`doctrine/router.py` was missed, nothing caught it. Grep call sites. Run the Service Rule
check. Write the rollback plan before writing the migration.
