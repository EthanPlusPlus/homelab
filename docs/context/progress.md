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

## In Progress

- Define project file structure on Ubuntu VM

## Next

- Set up code indexing service (AI context layer)
- Build local retrieval API / MCP server

## Deferred / Blocked

- RAM upgrade to 32GB — prerequisite for Ollama only
- Ollama / local LLM inference — blocked on RAM upgrade
- Pi-hole — deferred, DNS fragility risk
- Immich — deferred, lower priority than AI layer
