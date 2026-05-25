## Feasibility Analysis — Consolidate Prismo persistence to PostgreSQL + pgvector: replace ChromaDB and SQ...

**Recommendation:** `feasible_with_constraints`

The SQLAlchemy + pgvector + FastAPI stack is well-proven in open-source production projects and the ChromaDB → pgvector migration is routine since embeddings are model-dependent and transfer directly. The primary constraints are: (1) a pre-migration audit of workflow-state-service SQLAlchemy models for SQLite-lenient patterns (unconstrained String lengths, auto-generated constraint names) that PostgreSQL will reject, and (2) wiring `CREATE EXTENSION vector` into the Alembic migration chain before adding the vector column. At Prismo's corpus scale (hundreds to low thousands), pgvector's exact sequential scan provides 100% recall — strictly better than ChromaDB's default ANN behavior — so no HNSW index tuning is needed initially, and the operational consolidation (single backup target, single connection string, eliminated ChromaDB container) is a genuine improvement even for a single-contributor system.

## Findings

## What Others Have Built

**SQLAlchemy + pgvector + FastAPI stack is well-trodden.** Grafana ships a production `vectorapi` service using exactly this combination — FastAPI for the HTTP layer, SQLAlchemy for the ORM, pgvector for vector storage, and sentence-transformers (pytorch) for embeddings (github.com/grafana/vectorapi). Multiple open-source RAG API projects (danny-avila/rag_api, F4k3r22/RAG-FastAPI-Server) demonstrate the same stack in real deployments. The `pgvector-python` library provides a first-class `pgvector.sqlalchemy.Vector` column type that drops into existing SQLAlchemy ORM models with minimal ceremony.

**ChromaDB → pgvector migrations are well-documented and considered routine.** The consensus across multiple comparison sources is that embeddings are model-dependent, not database-dependent — vectors export directly. The migration requires: (1) a script to `get()` all documents/embeddings from Chroma and `INSERT` them into a pgvector table, and (2) rewriting query code from Chroma's Python SDK to SQL `ORDER BY embedding <=> $query_vec LIMIT k`. No re-embedding is needed since sentence-transformers is staying unchanged.

**SQLite → PostgreSQL via SQLAlchemy is also well-understood**, with the primary friction being PostgreSQL's stricter constraint enforcement vs. SQLite's permissive model. Common failure modes: auto-generated constraint names exceeding Postgres's 63-char identifier limit, `String(n)` length limits being silently ignored in SQLite but enforced in Postgres, and boolean/datetime dialect differences. With Alembic already managing schema, the migration path is: update `DATABASE_URL`, run `alembic upgrade head`, fix any constraint/type violations.

## Retrieval Quality at Prismo Scale (Hundreds to Low Thousands of Docs)

**At this corpus size, pgvector matches or exceeds ChromaDB quality.** For datasets under ~10K vectors, pgvector's sequential scan (no index needed) performs exact nearest-neighbor search with 100% recall — no ANN approximation loss whatsoever. Benchmarks show sequential scans perform well up to ~10K rows (~36ms on modest hardware). ChromaDB uses ANN internally by default, meaning pgvector's exact scan at this scale is actually *higher* recall. An HNSW index is not required at hundreds-to-low-thousands scale and should not be added until the corpus clearly warrants it, since it trades recall for speed unnecessarily at this size.

For reference, one benchmark (all-MiniLM-L6-v2 embeddings, 20-newsgroups dataset, 100–10K docs) showed pgvector and ChromaDB performing comparably at small sizes, with pgvector pulling ahead under concurrent load. A separate large-corpus benchmark showed pgvector averaging 9.81s vs. ChromaDB's 23.08s under concurrent queries, though this is at a scale irrelevant to Prismo's current corpus.

## Hard Parts in Practice

1. **Operational overhead increase**: SQLite and ChromaDB (embedded) require zero server management. Adding PostgreSQL introduces a new daemon, connection pooling concerns, startup ordering in docker-compose, and backup strategy changes. This is the real cost for a single-contributor system — not performance or quality.

2. **Async driver friction**: When FastAPI uses async endpoints, the PostgreSQL connection driver choice matters. `asyncpg` is the canonical async choice but has edge cases in some deployment environments; `psycopg2` is synchronous. Several practitioners reported needing to fall back to sync connections wrapped in async handlers when deployment environments didn't cooperate.

3. **SQLite → Postgres constraint landmines**: SQLite ignores `String(n)` length limits and is lenient on constraint naming. Existing SQLAlchemy models likely have latent issues (long auto-generated constraint names, unconstrained text fields) that PostgreSQL will enforce. A pre-migration audit of the workflow-state-service models is required.

4. **pgvector HNSW index tuning (future concern, not present)**: At current scale, no index is needed. If the corpus grows past ~10K docs, the default `probes=1` on IVFFlat will produce poor recall. HNSW with defaults (`m=16, ef_construction=64`) is the recommended path forward and gives ~98% recall@10.

5. **Alembic migration for pgvector column type**: Adding a `vector(N)` column via Alembic requires the `CREATE EXTENSION IF NOT EXISTS vector` DDL to run first. This is a one-time setup step that needs to be wired into the migration script or app startup.

## Infrastructure Simplification Assessment

Eliminating ChromaDB removes one container, one Python dependency tree (chromadb has a heavy footprint), one data directory to back up, and one set of startup ordering concerns. SQLite is file-based and has no container overhead, but its backup must be done carefully (WAL mode + file copy). Consolidating to a single PostgreSQL instance with pg_dump covers both the relational data and the vector embeddings in one atomic backup — a genuine operational improvement even for a solo developer.

## Is Postgres the Right Call at Current Scale?

The majority of practitioners and comparison sources agree: if you are already on PostgreSQL (or plan to add it for the relational layer), pgvector is the unambiguous right choice vs. running a separate ChromaDB. The counterargument — 'premature for a solo system' — has merit only if Postgres is being added *solely* for vectors. In Prismo's case it is replacing *both* ChromaDB *and* SQLite, so the per-service overhead is paid once. The consolidation net is positive even at current scale.

## Sources

- https://github.com/grafana/vectorapi
- https://github.com/danny-avila/rag_api
- https://github.com/pgvector/pgvector-python
- https://blog.elest.io/pgvector-vs-chromadb-when-to-extend-postgresql-and-when-to-go-dedicated/
- https://pecollective.com/tools/chroma-vs-pgvector/
- https://tiffena.me/blog/performance-benchmarking-of-embedding-similarity-search-chromadb-vs.-postgresql-pgvector/
- https://www.newtuple.com/post/speed-and-scalability-in-vector-search
- https://neon.com/docs/ai/ai-vector-search-optimization
- https://aws.amazon.com/blogs/database/supercharging-vector-search-performance-and-relevance-with-pgvector-0-8-0-on-amazon-aurora-postgresql/
- https://dev.to/philip_mcclarence_2ef9475/ivfflat-vs-hnsw-in-pgvector-which-index-should-you-use-305p
- https://agentskb.com/kb/pgvector/
- https://4xxi.com/articles/vector-database-comparison/
- https://encore.dev/articles/best-vector-databases
- https://medium.com/@fredyriveraacevedo13/building-a-fastapi-powered-rag-backend-with-postgresql-pgvector-c239f032508a
- https://www.fmularczyk.pl/posts/2023_06_sqlite_to_postgresql/
- https://dzone.com/articles/python-async-sqlite-postgresql-development
- https://medium.com/@filipespacheco/migrating-the-sqlite-from-a-localhost-application-to-a-postgres-in-neon-829ab0909cc4
- https://blog.greeden.me/en/2025/08/12/no-fail-guide-getting-started-with-database-migrations-fastapi-x-sqlalchemy-x-alembic/
- https://github.com/sqlalchemy/sqlalchemy/discussions/11529

*confidence: 0.92 | analysis_type: feasibility*