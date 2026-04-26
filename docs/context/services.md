# Services

## Active

| Service | Host | Access |
|---------|------|--------|
| Proxmox VE | iMac (bare metal) | https://192.168.1.9:8006 |
| Docker | Ubuntu Server VM | — |
| Portainer | Ubuntu Server VM | http://ubuntu-server.tail58b10c.ts.net:9000 |
| Tailscale | Ubuntu Server VM | 100.92.226.121 / ubuntu-server.tail58b10c.ts.net |
| context-server (API) | Ubuntu Server VM | http://localhost:8000 |
| context-server (MCP) | Ubuntu Server VM | http://ubuntu-server.tail58b10c.ts.net:8001/mcp |
| Code indexer (context-server) | Ubuntu Server VM | POST /index/code?project=<name> |

## Planned
| Ollama | Ubuntu Server VM | Blocked on RAM upgrade |

## Deferred

| Service | Reason |
|---------|--------|
| Pi-hole | DNS fragility risk — see decision 004 |
| Immich | Lower priority than AI layer — revisit after retrieval system established |
