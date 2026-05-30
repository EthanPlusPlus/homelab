# Migration Facet

**Purpose:** Shift into migration-aware reasoning — interface dependency tracing, rollback awareness, and Service Rule enforcement — before touching any interface, schema, or contract.

**Activation:** `/migrate [what is being migrated]`
Or automatic when a message is classified as a migration context.

---

## What It Loads

| Loader | What it fetches | Why |
|--------|----------------|-----|
| `architectural_laws` | Decision 017 full text | The Three Laws govern what can change and how |
| `migration_doctrine` | Decisions about migration, interfaces, Service Rule | The constraint set for this specific work type |
| `recent_changes` | `context/recent-changes.md` | What changed recently — relevant to dependency surface |
| `topology` | `GET /runtime/topology` | Current service boundaries and authority |
| `domain_specific` | Semantic search on `$ARGS` | Decisions specific to what's being migrated |

---

## The Four Rules

1. **Grep call sites before changing any interface.** Do not assume you know them all.
2. **Service Rule gate** — every route must be in `capability-contracts.md` before code ships.
3. **Identify irreversible state** — pgvector HNSW indexes, committed data, published schemas.
4. **Write the rollback plan before the migration.**

---

## The Reference Failure

The pgvector migration (2026-05-29): `doctrine/router.py` still called the old ChromaDB interface after it was replaced. The call site was missed. Nothing caught it until runtime. This Facet prevents that class of failure.

---

## Files

| File | Purpose |
|------|---------|
| `facet.yaml` | Machine-readable definition |
| `SKILL.md` | Claude Code thin adapter with fallback |
| `README.md` | This file |
