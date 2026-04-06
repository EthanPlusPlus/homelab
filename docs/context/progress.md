# Progress

## Complete

- Install Proxmox VE bare metal
- Configure WiFi (wpa_supplicant) on Proxmox
- Disable enterprise repo, enable community repo
- Create Ubuntu Server 24.04 VM
- Enable IP forwarding on Proxmox host
- Add NAT iptables rule (MASQUERADE via wlp2s0)
- Persist iptables rules with iptables-persistent
- Configure ens18 static IP via Netplan on Ubuntu VM
- Verify internet access from Ubuntu VM
- Install Docker on Ubuntu Server VM
- Install Portainer
- Configure Tailscale
- Migrate documentation from Word doc to markdown structure
- Set up GitHub private repo
- Clone repo to Ubuntu VM at ~/projects/homelab
- Define project file structure on Ubuntu VM
- Set up context-server repo
- Expand VM logical volume from 15GB to 30GB
- Build doc indexer (ChromaDB + sentence-transformers + FastAPI)
- Build MCP server (FastMCP, streamable-http, port 8001)
- Connect Claude Code to MCP server via Tailscale
- Verified end-to-end retrieval from Claude Code session

## In Progress

- Requirements split (base/light) to avoid CUDA bloat on rebuilds

## Next

- Code indexer (second module of context-server)
- Embedding model upgrade (all-MiniLM-L6-v2 → all-mpnet-base-v2)

## Deferred / Blocked

- RAM upgrade to 32GB — prerequisite for Ollama only
- Ollama / local LLM inference — blocked on RAM upgrade
- Pi-hole — deferred, DNS fragility risk
- Immich — deferred, lower priority than AI layer
