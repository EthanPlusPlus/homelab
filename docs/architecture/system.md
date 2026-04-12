# Prismo — System Overview

Prismo is the name for the whole system: the Proxmox host, the Ubuntu Server VM,
the services running on it, the projects being developed, and the docs and workflow
that govern all of it.

## Components

| Component | Description |
|-----------|-------------|
| Proxmox host | Bare metal on a 2017 iMac, IP 192.168.1.9 |
| Ubuntu Server VM | Ubuntu 24.04, IP 192.168.100.10, Tailscale 100.92.226.121 |
| context-server | AI context layer — doc indexer, code indexer, MCP server |
| Portainer | Docker management UI |
| Tailscale | Mesh VPN, hostname ubuntu-server.tail58b10c.ts.net |

## Projects

| Repo | Purpose |
|------|---------|
| ~/projects/homelab | Prismo's own docs — decisions, runbooks, architecture, context |
| ~/projects/context-server | The AI context retrieval service |
| ~/projects/devcamp | Active development project |

## Working Model

- Prismo infrastructure work happens at the VM root (`/home/ethan`)
- Project work happens inside the relevant repo directory
- The homelab repo follows the same project lifecycle as code projects —
  it just contains docs instead of code
