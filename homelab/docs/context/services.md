# Services

## Active

| Service | Host | Access |
|---------|------|--------|
| Proxmox VE | iMac (bare metal) | https://192.168.1.9:8006 |
| Docker | Ubuntu Server VM | — |
| Portainer | Ubuntu Server VM | http://100.92.226.121:9000 |
| Tailscale | Ubuntu Server VM | 100.92.226.121 / ubuntu-server.tail58b10c.ts.net |

## Planned

| Service | Host | Notes |
|---------|------|-------|
| Code indexing | Ubuntu Server VM | Next — AI context layer |
| Retrieval API / MCP server | Ubuntu Server VM | Follows indexing |
| Ollama | Ubuntu Server VM | Blocked on RAM upgrade |

## Deferred

| Service | Reason |
|---------|--------|
| Pi-hole | DNS fragility risk — see decision 004 |
| Immich | Lower priority than AI layer — revisit after retrieval system established |
