# Decision 008 — code indexer design

## Status
Adopted

## Context
Building the second module of the context retrieval layer — a code indexer that lets Claude query project codebases structurally and semantically, supporting all four development modes: greenfield, debugging, refactoring, and code review.

## Decisions

### tree-sitter for parsing
Fast, lightweight, polyglot, produces a proper AST. Industry standard for code parsing — used by GitHub Copilot, Neovim, and most modern editors. Supports incremental parsing for files that change often. Falls short of full semantic analysis (no type resolution, no cross-file name resolution) but sufficient for symbol extraction and reference tracking at this scale.

### Hybrid storage: ChromaDB + SQLite
Two stores, one per concern:
- ChromaDB (code_symbols collection) — semantic entry points, embedding-based search
- SQLite (code_graph.db) — structural traversal, symbol lookup, reference/call graph

ChromaDB metadata is not suited for graph traversal queries. SQLite handles find_references, blast radius, and symbol lookup cleanly with simple relational tables.

### Symbol-level chunking with enriched embedding text
Each symbol (class, method, constructor, interface) is a chunk. Embedding text is enriched: enclosing class + symbol type + name + docstring + signature. This gives the model more signal than embedding a raw signature alone.

### Language config registry
languages.py acts as a registry — file extensions, symbol node types, and reference node types per language. Adding a new language requires: installing the tree-sitter grammar package, adding an entry to languages.py. No other changes needed. Currently supports Java. Python config is stubbed.

### Five MCP tools for code
- search_code — semantic search over symbols
- get_symbol — exact symbol lookup by name
- find_references — usages and callers via SQLite
- get_file_summary — all symbols in a file, structural overview
- get_related_symbols — deferred, to be added

## Known limitations
- Method body signatures truncated at 300 characters — sufficient for orientation, may need tuning
- tree-sitter provides syntax awareness only, not full semantic analysis
- Call graph is best-effort — dynamic dispatch and reflection will be missed
- Reference confidence not yet labelled

## What is manual
- Triggering re-index after code changes: POST /index/code?project=devcamp
- Adding a new language: install grammar package + update languages.py
- Adding a new project to the index: POST /index/code?project=<name>
- These are candidates for a future simple management interface

## Consequences
- Code indexer lives at indexers/code/ in context-server repo
- devcamp is the first indexed project (57 Java files, 231 symbols, 1516 references)
- SQLite db lives alongside ChromaDB in the chroma_store volume
- Full MCP tool surface now: search_docs, get_doc_section, list_related_decisions, search_code, get_symbol, find_references, get_file_summary
