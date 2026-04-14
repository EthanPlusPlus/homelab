# Open Questions

## Infrastructure

- Should Proxmox get a DHCP reservation on the router to prevent IP drift on reboot?
- Should Ethernet (nic0) be configured as a fallback, or left manual?

## AI Layer

- ~~Index the Java devcamp project first, or homelab docs first?~~ resolved: both indexed
- ~~What does the MCP server interface look like in practice?~~ resolved: operational via FastMCP on port 8001
- Should the MCP server require authentication for production use?
- ~~When to add Python support to the code indexer?~~ resolved: Python support added

## File Structure

- ~~Where does the devcamp Java project live?~~ resolved: `~/projects/devcamp/`
- ~~How are projects linked to the retrieval system?~~ resolved: create `~/canon/<name>/docs/`, POST /index — auto-discovered via CANON_PATH
- ~~When to migrate from GitHub to Gitea + mirror setup?~~ → see proposed-ideas/002-gitea-migration.md

## Deferred

- When does Immich become worth revisiting?
- RAM upgrade timing — is 32GB needed before any Ollama experimentation?
