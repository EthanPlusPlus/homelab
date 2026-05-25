## Trade-Off Analysis — kuzu (embedded graph DB) vs SQLite adjacency tables for doctrine-service superse...

**Recommendation:** `SQLite adjacency tables`

At Prismo's current and projected canon scale (hundreds to low-thousands of nodes, shallow supersession chains, low branching factor, infrequent writes), SQLite recursive CTEs with proper indexes perform in milliseconds — indistinguishably from Kuzu — while adding zero new dependencies and zero abandonment risk. Kuzu's core value proposition (production-grade embedded graph analytics) was invalidated by its acquisition by Apple and subsequent archival in October 2025; adopting a frozen binary or betting on an early-stage community fork (LadybugDB) for doctrine-service's foundational graph layer is an asymmetric risk with no offsetting performance return at current scale. The correct build strategy is SQLite adjacency tables now, with a structured migration trigger defined at >50K nodes or when multi-type variable-depth Cypher queries become materially harder to express as recursive CTEs than they are worth — at which point ArcadeDB (Apache 2.0, actively maintained) or FalkorDB are the superior migration targets, not the frozen Kuzu codebase.

## Findings

## Kuzu (embedded graph DB) vs. SQLite Adjacency Tables for Doctrine-Service Supersession Graph Traversal

---

### Option A: SQLite Adjacency Tables + Recursive CTEs

#### Strengths
- **Zero new dependency.** SQLite is already the most deployed database in the world (>1 trillion deployments). No binary to vendor, no schema migration risk, no unfamiliar tooling.
- **Recursive CTEs are proven for this scale.** Real-world production experience confirms that with proper indexing, SQLite adjacency tables handle graph traversal over tens-of-thousands of nodes in milliseconds. One practitioner's detailed account states: "with proper indexing, it's fast enough for knowledge graphs in the tens-of-thousands-of-nodes range — which covers most single-team or single-project use cases."
- **Supersession chains are shallow trees, not dense meshes.** Doctrine-service canon docs — decisions, runbooks, architecture docs — form low-branching-factor chains. SQLite recursive CTEs degrade only at >100k entities with *deep* traversals (depth 6+) or high branching factors. At thousands of nodes with low branching, the recursive CTE runs in milliseconds.
- **Operational simplicity is extreme.** The entire stack runs as a single binary. Backup is a file copy. The query language (SQL + recursive CTEs) is universally known.
- **OLTP-friendly.** SQLite handles both reads and writes transactionally and supports WAL mode for concurrent reads. Canon relationship writes are rare (documents change infrequently), so write-lock contention is not a real concern.

#### Weaknesses
- **Recursive CTE has a known node-revisit problem.** SQLite's recursive CTE cannot natively deduplicate visited nodes within the recursive step, meaning graphs with cycles or diamond-shaped supersession chains can revisit nodes. A `GROUP BY` post-step is needed as a workaround, which is slower.
- **Query expressiveness ceiling.** Cypher's pattern matching for multi-hop relationship queries (e.g., `MATCH (a)-[:SUPERSEDES*1..5]->(b)`) is substantially more expressive than recursive CTEs. As relationship types multiply (supersession + reference + dependency), CTEs become increasingly verbose.
- **Performance degrades non-linearly with depth.** At depth 4 with a branching factor of 10, you're visiting ~10,000 nodes per query. SQLite handles this in milliseconds with indexes, but at 500k entities at depth 6, it becomes noticeable.
- **SQLite has no graph-native storage format.** Graph topology is implicit in row data, meaning join-heavy traversal becomes O(n) table scans if indexes are not carefully maintained.

#### Known failure modes
- Forgetting to index both `from_node_id` and `to_node_id` columns causes catastrophic performance regression on recursive steps.
- Missing a cycle guard (`WHERE depth < N`) causes infinite recursion.
- As edge types multiply (supersession, reference, dependency), separate CTEs or UNION queries are required, compounding maintenance burden.

---

### Option B: Kuzu (Embedded Graph DB)

#### Strengths
- **Purpose-built for exactly this workload.** Kuzu is designed for embedded, in-process graph analytics — the "DuckDB for graphs" positioning — with columnar storage, vectorized query execution, worst-case-optimal joins, and factorized execution.
- **OpenCypher query language.** `getSupersessionGraph` and `resolveRelationships` map naturally to Cypher pattern queries like `MATCH (a:Decision)-[:SUPERSEDES*]->(b)`. Variable-depth traversal, multi-type edge matching, and relationship property filtering are first-class, not workarounds.
- **Validated at extreme scale.** The engine has been benchmarked on the LDBC-SF100 benchmark (280M nodes, 1.7B edges) and shows significant speed advantages over Neo4j on n-hop path-finding queries, specifically due to hybrid join algorithms. At thousands of nodes, latency is effectively immeasurable.
- **In-process, no server to manage.** Like SQLite, Kuzu runs embedded in the application process with disk persistence. No external process, no network calls.
- **MIT-licensed codebase.** The archived canonical Kuzu codebase is MIT-licensed and the engine is stable, documented in a peer-reviewed CIDR 2023 research paper from the University of Waterloo.

#### Weaknesses — CRITICAL RISK: Project Abandonment
- **Kuzu Inc. was acquired by Apple in October 2025.** The GitHub repository was archived, active development stopped, and the original core team is now at Apple. This is not a soft deprecation — the project is frozen.
- **Community forks (LadybugDB, Vela-Engineering/kuzu) exist but carry real risk.** Multiple sources confirm the forks have no corporate backing, no core team continuity, and uncertain roadmaps. "Building production infrastructure on an abandoned project fork is a risk most teams can't justify."
- **LadybugDB is still maturing.** Its v0.15 release (March 2026) is the fork's first major milestone, adding Arrow/DuckDB integration and security fixes — but it is still an early-stage experiment by the original project's standards.
- **OLAP-optimized, not OLTP.** Kuzu was designed for analytical batch workloads. It has a single-writer constraint in the original and most forks. For a doctrine-service that writes relationships incrementally as documents are authored, this is a minor but real ergonomic friction point.
- **Adds a binary dependency with uncertain future.** Any Kuzu version pinned today will not receive security patches from the original team. The project is frozen at the version Apple acquired.
- **Integration overhead at current scale is disproportionate.** At hundreds-to-low-thousands of nodes with shallow supersession chains, the performance gap between Kuzu and SQLite recursive CTEs is essentially zero. The engineering cost of adopting, learning, and maintaining a now-abandoned embedded graph DB is not justified by any measurable performance return at Prismo's current scale.

---

### Comparative Summary Table

| Criterion | SQLite Adjacency | Kuzu (as of May 2026) |
|---|---|---|
| Current-scale performance (1K–10K nodes) | ✅ Milliseconds with indexes | ✅ Faster, but gap immeasurable |
| Future-scale performance (100K+ nodes) | ⚠️ Degrades at high depth+branching | ✅ Architecturally superior |
| Query expressiveness | ⚠️ Recursive CTEs, verbose for multi-type edges | ✅ OpenCypher, natural for graph patterns |
| Dependency risk | ✅ Zero — SQLite is eternal | ❌ Project archived Oct 2025, Apple acquisition |
| Maintenance continuity | ✅ 20+ year track record | ❌ Frozen; forks are early-stage community efforts |
| Operational simplicity | ✅ Single file, known tooling | ⚠️ Simpler than Neo4j but new dep + uncertain support |
| License | ✅ Public domain | ✅ MIT (frozen codebase) |
| Write concurrency | ✅ WAL mode, fine for infrequent writes | ⚠️ Single-writer constraint |
| Migration path if outgrown | ✅ Clear: add closure table or migrate to ArcadeDB/FalkorDB | ✅ Clear: already using Cypher, migrate Cypher queries |

---

### Scale Threshold Analysis

The break-even point where SQLite adjacency becomes problematic is approximately >100K nodes with traversal depth ≥ 6 and high branching factor. Canon documents (decisions, runbooks, architecture docs) at Prismo:
- Are **low-branching** (a decision typically supersedes 1–3 predecessors, not 10+)
- Have **shallow chains** (supersession chains rarely exceed 5–10 hops)
- Are **write-infrequent** (documents are authored, not streamed)
- Are **expected to reach thousands, not hundreds of thousands**

This profile stays well within SQLite's comfortable operating range for the foreseeable future.

---

### The Kuzu Abandonment Risk Is the Deciding Factor

The entire value proposition of Kuzu rested on it being an actively maintained, production-grade embedded graph DB. That value proposition collapsed in October 2025. Adopting a frozen dependency — or betting on an early-stage community fork — for a foundational infrastructure service (doctrine-service) introduces an unacceptable long-term maintenance risk that is entirely disproportionate to the performance benefit, which is effectively zero at current scale.

## Sources

- https://dev.to/rohansx/sqlite-as-a-graph-database-recursive-ctes-semantic-search-and-why-we-ditched-neo4j-1ai
- https://arcadedb.com/blog/neo4j-alternatives-in-2026-a-fair-look-at-the-open-source-options/
- https://arcadedb.com/blog/from-kuzudb-to-arcadedb-migration-guide/
- https://vela.partners/blog/kuzudb-ai-agent-memory-graph-database
- https://blog.ladybugdb.com/post/ladybug-spreading-its-wings/
- https://gdotv.com/blog/weekly-edge-kuzu-acquisition-apple-s3-graph-analytics-neo4j-vs-postgresql/
- https://github.com/prrao87/kuzudb-study
- https://thedataquarry.com/blog/embedded-db-2/
- https://docs.kuzudb.com/
- https://www.graphgeeks.org/blog/what-every-developer-needs-to-know-about-in-process-dbmss
- https://sqlite.org/forum/info/3b309a9765636b79
- https://devsolus.com/sqlite-recursive-cte-how-to-use-them/
- https://www.blog.brightcoding.dev/2025/09/24/kuzu-the-embedded-graph-database-for-fast-scalable-analytics-and-seamless-integration/
- https://gdotv.com/blog/weekly-edge-kuzu-forks-duckdb-graph-cypher-24-october-2025/

*confidence: 0.92 | analysis_type: trade_off*