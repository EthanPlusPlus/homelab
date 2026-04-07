# Open Questions

## Infrastructure

- Should Proxmox get a DHCP reservation on the router to prevent IP drift on reboot?
- Should Ethernet (nic0) be configured as a fallback, or left manual?

## AI Layer

- Index the Java devcamp project first, or homelab docs first?
- What does the MCP server interface look like in practice?
- Should re-indexing be triggered automatically on git pull, or remain manual?
- Should the MCP server require authentication for production use?
- When to add get_related_symbols tool?
- Should the management interface be a CLI, a simple web UI, or both?
- When to add Python support to the code indexer?

## File Structure

- ~~Where does the devcamp Java project live?~~ resolved: `~/projects/devcamp/`
- How are projects linked to the retrieval system?
- When to migrate from GitHub to Gitea + mirror setup?

## Deferred

- Embedding model upgrade (all-MiniLM-L6-v2 → all-mpnet-base-v2) — revisit when retrieval quality becomes a bottleneck
- get_related_symbols tool — deferred until core tools are validated in real sessions
- When does Immich become worth revisiting?
- RAM upgrade timing — is 32GB needed before any Ollama experimentation?
