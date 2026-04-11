# Recent Changes

Rolling log of meaningful system changes. Keep last ~10 entries. One to three lines each.
Oldest entries are removed as new ones are added.

---

- **Git hooks implemented** — post-merge hooks added to homelab, context-server, and devcamp repos; auto re-indexing fires on git pull in each repo
- **Claude Code installed on VM** — accessible via Tailscale; connected to context-server MCP on port 8001
- **MCP connection fixed** — Claude Code can now retrieve context from context-server MCP server
- **iptables rules persisted** — homelab NAT rule now survives reboots via iptables-persistent on Ubuntu VM
- **ip_forward persisted on Proxmox host** — added net.ipv4.ip_forward=1 to /etc/sysctl.conf
- **Code indexer validated** — full retrieval loop confirmed in Claude Code session; search_code, get_symbol, find_references, get_file_summary all operational
- **Code indexer built** — tree-sitter + SQLite + ChromaDB; indexed devcamp project (57 Java files, 231 symbols, 1516 references)
- **MCP server built and connected** — FastMCP 1.27.0, streamable-http, port 8001; Claude Code retrieving context over Tailscale
- **Doc indexer built** — ChromaDB + sentence-transformers + FastAPI on port 8000
- **VM logical volume expanded** — 15GB → 30GB via LVM
