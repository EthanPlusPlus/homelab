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
- Expand VM logical volume from 15GB to 30GB
- Claude Code installed on VM
- iptables rules persisted on Ubuntu VM
- ip_forward persisted on Proxmox host via /etc/sysctl.conf
- CLAUDE.md session bootstrapping established across project repos
- Shared memory layer implemented — git-backed, symlinked into Claude Code sessions

## Working On

_(add a one-liner when you start a session — clear it when you're done)_

## In Progress

- **Dev (devakmistry) VM onboarding** — account created (sudo + docker groups), SSH key installed,
  homelab cloned at ~/canon/homelab; memory symlinks and MCP setup still pending (prismo new-machine
  can't run on VM — VM_HOST hardcoded); complete manually next session using add-vm-user.md step 5+

## Next

_(no infrastructure work queued)_

## Deferred / Blocked

- RAM upgrade to 32GB — prerequisite for Ollama only
- Ollama / local LLM inference — blocked on RAM upgrade
- Pi-hole — deferred, DNS fragility risk
- Immich — deferred, lower priority than AI layer
