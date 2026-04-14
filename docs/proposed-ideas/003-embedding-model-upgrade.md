# Proposed Idea 003 — Embedding model upgrade

## Status
Proposed — deferred until triggered

## Background
The context-server doc indexer currently uses `all-MiniLM-L6-v2` for embeddings. This was
chosen for speed and low resource usage at the time of initial build.

`all-mpnet-base-v2` is a stronger model — better semantic accuracy, especially for longer
documents and nuanced queries — but slower and more memory-intensive.

## The Case for Upgrading
If retrieval quality becomes a noticeable bottleneck — MCP returning irrelevant results,
missing obvious matches, or requiring multiple query reformulations to get useful context —
the embedding model is the first lever to pull.

## Trigger Condition
Upgrade when retrieval quality is a real bottleneck in real sessions. Not before.
Premature upgrade adds complexity and rebuild time for uncertain gain.

## Open
- What does a quality regression test look like for the doc indexer?
- Does the upgrade require a full re-index, or can embeddings be recomputed incrementally?
- Is `all-mpnet-base-v2` within acceptable memory limits on this VM?
