# Decision 001 — NAT over bridging for VM networking

## Status
Adopted

## Context
Proxmox is running on WiFi (wlp2s0). Linux does not support bridging over WiFi interfaces natively. VMs need internet access.

## Decision
Use NAT (MASQUERADE via iptables) to route VM traffic through the Proxmox host's WiFi interface. VMs live on an internal subnet (192.168.100.0/24).

## Alternatives Considered
- **Bridging** — not possible over WiFi without workarounds
- **Ethernet (nic0)** — available but unused; would enable bridging if needed in future

## Consequences
- VMs are not directly addressable from the home network (192.168.1.x)
- Remote access to VM services requires either port forwarding or Tailscale
- Tailscale adopted as the solution for remote access (see services.md)
