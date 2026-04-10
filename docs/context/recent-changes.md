# Recent Changes

Rolling log of meaningful system changes. Keep last ~10 entries. One to three lines each.
Oldest entries are removed as new ones are added.

---

- **Code indexer validated** — full retrieval loop confirmed in Claude Code session; `search_code`, `get_symbol`, `find_references`, `get_file_summary` all operational
- **Code indexer built** — tree-sitter + SQLite + ChromaDB; indexed devcamp project (57 Java files, 231 symbols, 1516 references); added code MCP tools
- **MCP server connected** — Claude Code connecting to context-server over Tailscale on port 8001; end-to-end doc retrieval verified
- **MCP server built** — FastMCP 1.27.0, streamable-http transport, port 8001; tools: `search_docs`, `get_doc_section`, `list_related_decisions`
- **Doc indexer built** — ChromaDB + sentence-transformers (`all-MiniLM-L6-v2`) + FastAPI on port 8000
- **VM logical volume expanded** — 15GB → 30GB via LVM
- **Context server repo created** — separate repo from `homelab`; deployed to Ubuntu VM
- **Documentation migrated** — Word doc → markdown structure in private GitHub repo; cloned to Ubuntu VM at `~/projects/homelab`
- **Tailscale configured** — Ubuntu VM accessible at `100.92.226.121` / `ubuntu-server.tail58b10c.ts.net`
- **Docker + Portainer installed** — running on Ubuntu Server VM; Portainer at `http://100.92.226.121:9000`
