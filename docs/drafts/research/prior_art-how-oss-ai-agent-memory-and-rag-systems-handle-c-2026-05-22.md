## Prior Art Analysis — How OSS AI agent memory and RAG systems handle combined vector + relational pers...

**Recommendation:** `adopt`

Postgres+pgvector for combined vector+relational persistence is the dominant production pattern in 2025–2026, validated by Letta's full convergence on it as a sole backend and the broader ecosystem's endorsement for workloads under ~10M vectors. The consolidation provides genuine benefits — transactional consistency between embeddings and relational state, elimination of sync failure modes, and operational simplicity — that directly address Prismo's context. The primary risk is HNSW memory overhead at scale (requires tuning `maintenance_work_mem` to 2–8GB+, and performance degrades past ~10–20M vectors), but this is a well-understood operational problem with documented mitigations, not an architectural dead-end. Defer graph layer (Neo4j/Memgraph) until and unless multi-hop relational queries are demonstrated to be a requirement; no OSS system reviewed adds graph before that need is proven.

## Findings

## OSS AI Agent Memory + RAG: Combined Vector + Relational Persistence — Prior Art Survey

---

### 1. Letta (formerly MemGPT)

**Architecture:** Letta has fully converged on a **single Postgres+pgvector backend** for all state. It uses a three-tier memory model (core memory = always in-context / recall memory = conversation history / archival memory = semantic vector search), and all tiers are persisted in Postgres. Letta creates 42 relational tables to manage agents, messages, memory blocks, organizations, and users — with pgvector handling embedding-backed archival retrieval in the same instance. The official Docker image mounts a pgvector-enabled Postgres and requires `pgvector` extension to be present. Deployments on Aurora PostgreSQL and Railway confirm this is the canonical production pattern, not just a dev convenience.

**Key evidence:** Official docs state "Your database must have the pgvector vector extension installed." AWS blog confirms the single Aurora Postgres instance stores all agent state, conversation history, and memory embeddings. Letta does NOT use a separate vector store in its default configuration.

**Failure mode noted:** Early MemGPT had unstructured archival storage, making complex relational queries (e.g., "which decisions were influenced by facts from source X?") impossible without heavy post-processing. This drove the move to structured, queryable Postgres-backed memory.

---

### 2. Mem0

**Architecture:** Mem0 is the most architecturally explicit about the **multi-store separation problem**. It deliberately uses three stores in parallel: a **vector store** (Qdrant, Pinecone, pgvector, Chroma) for semantic similarity; an **optional graph store** (Neo4j, Memgraph) for entity relationships; and a **relational/key-value layer** for metadata, timestamps, and user/session scoping. When a memory is added, all three are updated in parallel. Mem0 supports two operating modes: base `Mem0` (vector-only, low latency) and `Mem0g` (graph+vector, deeper relational reasoning at higher cost).

**Key evidence:** Official docs confirm the backend includes "an LLM client, a vector-search index, optional graph store, and a memory orchestration service." The hybrid approach allows queries combining the 'what' from vector search with the 'who' and 'where' from the graph store. On LOCOMO benchmark, this hybrid outperforms OpenAI's flat text memory by ~26% on accuracy.

**Failure mode noted:** Default config stores to in-memory/tmp only (Qdrant at `/tmp/qdrant`) if no config is provided — data is lost on restart. This is a documented footgun for developers new to the system. Also: pure vector search cannot answer multi-hop relational questions (e.g., team hierarchy) — the system explicitly acknowledges this and routes those to the graph layer.

---

### 3. LlamaIndex

**Architecture:** LlamaIndex does NOT converge on a single store. It uses a **pluggable, explicitly separated abstraction** — a `PropertyGraphStore` (Neo4j, FalkorDB, NetworkX, or a simple in-memory store) decoupled from a `VectorStore` (pgvector, Qdrant, Chroma, Pinecone, etc.). These are configured independently in a `StorageContext`. Its `PropertyGraphIndex` supports graph nodes that are themselves embedded, letting you attach vector similarity to graph traversal — but the stores remain separate services. LlamaIndex also integrated with PostgresML to unify embedding, vector search, and relational data in a single DB call, explicitly citing reduced network hops and latency as motivation.

**Key evidence:** The `PropertyGraphIndex` API signature exposes both `property_graph_store` and `vector_store` as separate, independently configurable parameters. Official docs note: "You can always combine a graph store with an external vector DB as well." The PostgresML integration blog explicitly says it "unifies embedding, vector search, and text generation into a single network call" as a response to multi-service latency overhead.

**Failure mode noted:** The modular separation approach creates synchronization responsibility in application code. LlamaIndex's older `KnowledgeGraphIndex` used only triples — its replacement (`PropertyGraphIndex`) is richer but still requires developers to explicitly wire stores and manage consistency between them.

---

### 4. Cognee

**Architecture:** Cognee implements a **triple-store architecture**: Vector + Graph + Relational, treating them as explicitly separate concerns. Its `cognify` pipeline runs 6 stages: classify → permission check → chunk → LLM-extract entities/relationships → summarize → embed into vector store AND commit edges to graph. Crucially, "the graph and vector stores stay linked: every node in the graph has a corresponding embedding," so graph traversal and semantic search are coherent. It supports PostgreSQL and SQLite as the relational backend, pgvector for vectors, and Neo4j/Memgraph/FalkorDB/NetworkX for graph. Cognee is the most graph-first of the four systems.

**Key evidence:** Cognee's `cognify` migration code explicitly shows three separate init calls: `create_relational_db_and_tables()`, `create_pgvector_db_and_tables()`, `get_graph_engine()`. Its `.memify()` operation prunes stale nodes, reweights edges, and adds derived facts — memory is an evolving structure, not static storage. Ships 14 retrieval modes from classic RAG to chain-of-thought graph traversal. Published benchmarks claim 0.92+ correctness vs. 0.4 for base RAG on complex multi-hop queries.

**Failure mode noted:** Early SDK was not parallelized, making ingestion slow. Updates were fragile. The system acknowledges high engineering complexity to configure and maintain — it is not a simple drop-in. Requires foreign keys to be well-defined for relational→graph migration to work correctly.

---

### 5. Convergence Patterns Across the Field

**Trend toward Postgres+pgvector for simpler workloads:** The broader ecosystem has strongly converged on Postgres+pgvector as the default starting point for teams under ~10M vectors. Letta uses it as its sole backend. LlamaIndex's PostgresML integration treats it as a simplification win. Production practitioners confirm <50ms P95 at this scale with HNSW, with a single backup strategy, connection pool, and RLS policy.

**Graph layer deferred until relational queries break:** Mem0 and Cognee both add graph only when multi-hop relational queries are required. Pure vector search cannot answer structural questions like "who approved project X" or team hierarchy traversal. The field acknowledges this as a ceiling, not a deficiency.

**Separation is still dominant for graph:** No major OSS system has shipped vector+graph in a single Postgres instance. Graph workloads still go to Neo4j, Memgraph, FalkorDB, or NetworkX. SurrealDB is pitching a unified graph+vector+relational engine but is not yet a mainstream choice.

---

### 6. Known Failure Modes

#### Early Consolidation (Postgres+pgvector only) Failure Modes:
- **HNSW memory cliff:** Building HNSW indexes requires holding the entire graph in RAM. Default `maintenance_work_mem` (64MB) causes disk-based fallback that is 10–50x slower. At 5M vectors of 1536-dim, requires ~60GB working memory. Teams consistently hit this at month 2–4 after launch.
- **Index rebuild contention:** HNSW rebuilds require allocating multi-GB RAM on a live production database — no good native throttle. Workarounds (staging table swap, dual-index writes) all introduce windows of missed data or double memory cost.
- **VACUUM/WAL explosion:** High-write vector workloads trigger WAL file explosion and stall vacuum — documented community pain point throughout 2025.
- **Noisy neighbor / CPU contention:** Vector index queries compete with transactional workloads on the same Postgres instance. Separate workloads can saturate I/O.
- **Ghost document reads:** In fragmented stacks (vector DB + relational DB), an agent can retrieve a vector for a document already deleted from the primary store. Consolidated Postgres+pgvector avoids this via ACID transactions.
- **Semantic vs. causal mismatch:** Vector similarity returns text that 'looks like' the query but isn't causally related. Pure vector stores cannot reason about causation or temporal ordering — needs graph or relational structure.

#### Early Separation (multiple specialized stores) Failure Modes:
- **Sync headaches:** Keeping vector embeddings, graph edges, and relational metadata in sync across 3 systems is its own engineering problem. Embedding drift degrades results without warning.
- **Multi-agent write conflicts:** When two agents write to the same vector store concurrently, neither knows about the conflict — retrieval returns whichever embedding was indexed last.
- **Operational overhead:** Multiple failure domains, backup strategies, connection pools, and auth surfaces to manage.
- **Stale embeddings:** If relational data changes and embeddings are not regenerated, similarity search returns semantically stale results.
- **Real memory vs. retrieval confusion:** Vector databases have no native mechanisms for memory consolidation, priority weighting, or deliberate forgetting — critical for agent memory lifecycle.

---

### 7. Summary Table

| System | Vector | Relational/State | Graph | Convergence |
|---|---|---|---|---|
| Letta (MemGPT) | pgvector (in Postgres) | Postgres (42 tables) | None | **Single DB (Postgres+pgvector)** |
| Mem0 | Qdrant/pgvector/Chroma | Metadata KV layer | Neo4j/Memgraph (optional) | **Separated; hybrid optional** |
| LlamaIndex | Pluggable (pgvector, Qdrant, etc.) | Pluggable (PostgresML option) | Neo4j/FalkorDB/NetworkX | **Explicitly separated; modular** |
| Cognee | pgvector | PostgreSQL/SQLite | Neo4j/Memgraph/NetworkX | **Explicitly separated; triple-store** |

**Bottom line:** The field has NOT converged on a single DB for vector+graph. It HAS converged on Postgres+pgvector for vector+relational in simpler agent architectures (Letta being the clearest example). Graph is added as a third system only when multi-hop relational reasoning is required. Prismo's Postgres+pgvector consolidation aligns with the dominant production pattern for this class of system.

## Sources

- https://docs.letta.com/guides/docker/postgres/
- https://aws.amazon.com/blogs/database/how-letta-builds-production-ready-ai-agents-with-amazon-aurora-postgresql/
- https://railway.com/deploy/letta-ai-agent
- https://arxiv.org/html/2504.19413v1
- https://docs.mem0.ai/cookbooks/essentials/choosing-memory-architecture-vector-vs-graph
- https://blog.stackademic.com/mem0-memo-ai-memory-layer-purpose-and-core-functionality-375cc5a2bfd0
- https://medium.com/@parthshr370/from-chat-history-to-ai-memory-a-better-way-to-build-intelligent-agents-f30116b0c124
- https://memo.d.foundation/breakdown/mem0
- https://www.mindstudio.ai/blog/agent-memory-infrastructure-mem0-vs-openai
- https://developers.llamaindex.ai/python/framework/module_guides/indexing/lpg_index_guide/
- https://www.llamaindex.ai/blog/introducing-the-property-graph-index-a-powerful-new-way-to-build-knowledge-graphs-with-llms
- https://www.llamaindex.ai/blog/simplify-your-rag-application-architecture-with-llamaindex-postgresml
- https://www.cognee.ai/blog/fundamentals/how-cognee-builds-ai-memory
- https://www.cognee.ai/blog/deep-dives/relational-database-to-knowledge-graph-cognee-dlt
- https://github.com/topoteretes/cognee
- https://dev.to/om_shree_0709/cognee-building-the-next-generation-of-memory-for-ai-agents-oss-3jm1
- https://www.digitalapplied.com/blog/build-self-hosted-rag-postgres-pgvector-tutorial-2026
- https://teachmeidea.com/pgvector-postgres-rag/
- https://dev.to/mianzubair/4-pgvector-mistakes-that-silently-break-your-rag-pipeline-in-production-4e0p
- https://tech-champion.com/database/the-vector-hangover-hnsw-index-memory-bloat-in-production-rag/
- https://dev.to/philip_mcclarence_2ef9475/scaling-pgvector-memory-quantization-and-index-build-strategies-8m2
- https://alex-jacobs.com/posts/the-case-against-pgvector/
- https://redis.io/blog/common-challenges-working-with-vector-databases/
- https://atlan.com/know/agentic-ai-memory-vs-vector-database/
- https://blog.needle.app/p/vector-databases-arent-memory-heres
- https://towardsdatascience.com/a-practical-guide-to-memory-for-autonomous-llm-agents/
- https://serokell.io/blog/design-patterns-for-long-term-memory-in-llm-powered-architectures
- https://atlan.com/know/best-ai-agent-memory-frameworks-2026/
- https://medium.com/@bumurzaqov2/top-10-ai-memory-products-2026-09d7900b5ab1
- https://upsun.com/blog/configuring-pgvector-postgres-for-rag/
- https://medium.com/@mohitsoni_/postgresql-18-pgvector-the-definitive-guide-to-building-production-grade-rag-pipelines-239ee9c0e56f
- https://memgraph.com/blog/from-rag-to-graphs-cognee-ai-memory
- https://www.velodb.io/glossary/what-is-pgvector
- https://github.com/pgvector/pgvector/issues/844

*confidence: 0.91 | analysis_type: prior_art*