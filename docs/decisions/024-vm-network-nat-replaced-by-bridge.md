---
id: "024"
title: VM network — NAT/MASQUERADE replaced by direct bridge after fundamental routing failure
status: active
record_type: canonical
date: 2026-05-24
---

# Decision 024 — VM network: NAT replaced by direct bridge

## Status
Adopted

## Date
2026-05-24

## Context

The Ubuntu Server VM was previously on an internal NAT subnet (`192.168.100.0/24`) via
`vmbr0`. Proxmox used `MASQUERADE` on `wlp2s0` (WiFi) to give the VM internet access.

Following a kernel panic and reboot on 2026-05-22, the VM lost internet connectivity.
A 3-day diagnostic effort revealed that the NAT architecture is fundamentally broken on
this kernel — and was likely always broken. Internet connectivity was only working because
**Tailscale was always the real data path**. Once Tailscale went down (logged out during
the reboot), the underlying NAT was exposed as non-functional.

### Root cause

Linux delivers return packets addressed to the host's own IP (`192.168.1.9`) directly
to the INPUT chain — before PREROUTING runs. This means MASQUERADE reverse-NAT translation
never fires for those packets. They are consumed by the host network stack and never
forwarded to the VM. This is not a misconfiguration; it is standard Linux kernel behavior
for locally-addressed packets, and it affects both WiFi and Ethernet interfaces equally.

Attempts to work around this included:
- Explicit FORWARD rules (did not help — packets not reaching FORWARD chain)
- rp_filter=0 (no effect)
- Mangle/policy routing with marks (packets hitting mangle, but not reaching VM)
- Explicit DNAT rules (zero hits — PREROUTING not reached for these packets)
- route_localnet=1 (no effect)
- Proxmox VM firewall disabled (no effect)
- Plugging in Ethernet (same failure mode — not WiFi-specific)

All tcpdump evidence pointed the same way: ICMP and TCP reply packets arriving at the
Proxmox host's physical interface, never appearing on `vmbr0`. conntrack showed
connections stuck as `[UNREPLIED]` throughout.

### Secondary failure: Tailscale/DNS deadlock

When Tailscale is down, `systemd-resolved` has no working DNS servers (all servers were
on the `tailscale0` interface). Tailscale itself needs DNS to reach `controlplane.tailscale.com`.
Classic deadlock. Fixed by adding fallback DNS to `/etc/systemd/resolved.conf`.

## Decision

Replace the NAT/MASQUERADE architecture with a direct bridge:

- Created `vmbr1` on Proxmox, bridged to `nic0` (Ethernet, `192.168.1.25`)
- VM's `net0` interface now attached to `vmbr1`
- VM obtains a direct LAN IP via DHCP from the router (`192.168.1.26` at time of
  adoption — not static, get current with `ip addr show ens18`)
- No MASQUERADE rules required; no `vmbr0` subnet involvement
- Tailscale remains in use for remote access and Tailscale-specific features (MCP, services)
- Fallback DNS (`8.8.8.8`, `1.1.1.1`) added permanently to `/etc/systemd/resolved.conf`
  on the VM to break the Tailscale/DNS deadlock on any future reboot

The old `vmbr0` and NAT rules still exist on Proxmox but are unused.

## Rationale

The NAT architecture cannot be made to work without kernel-level changes or a dedicated
router appliance doing the NAT. The bridge approach is simpler, eliminates a hidden
dependency, and makes the VM a proper first-class LAN citizen.

This incident also surfaces a deeper constraint: **the system has no hardware resilience**.
A kernel panic on the iMac breaks everything. This is a known motivator for the hardware
upgrade path referenced in the V2 masterplan.

## Consequences

- VM IP is DHCP-assigned and may change; `ip addr show ens18` is the canonical lookup
- A DHCP reservation should be added to the router for the VM MAC address to stabilize the IP
- Ethernet (`nic0`) must be plugged in for the bridge to function — long-term plan TBD
- Tailscale hostname (`ubuntu-server.tail58b10c.ts.net`) and IP (`100.92.226.121`) unchanged
- Fallback DNS is now a hard constraint (see `context/constraints.md`)
- The Tailscale/DNS deadlock is a permanent risk on this setup — fallback DNS is the mitigation
- The NAT architecture should be considered a cautionary note in any future VM setup on this host
