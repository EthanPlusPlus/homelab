# Runbook — Proxmox Setup

## WiFi Configuration (wpa_supplicant)

WiFi is not natively supported by Proxmox. Configured manually via wpa_supplicant.

Static IP set to 192.168.1.9, gateway 192.168.1.1 on wlp2s0.

## Repository Configuration

- Enterprise repo: disabled
- Community (free) repo: enabled

## Virtual Bridge (vmbr0)

- IP: 192.168.100.2/24
- Internal subnet only — not bridged to any physical NIC
- Acts as gateway for all VMs

## VM Internet Access — Tailscale Subnet Router

NAT/MASQUERADE does **not** work on this setup. Return packets addressed to the Proxmox
host IP (`192.168.1.9`) are consumed by the host's INPUT chain before conntrack can
reverse-NAT them to the VM. This affects all protocols and all physical interfaces
(WiFi and Ethernet). All workarounds were attempted and failed in the 2026-05-22 incident.

VM internet access is provided by Tailscale running as a subnet router on Proxmox:

```bash
tailscale up --advertise-routes=192.168.100.0/24 --accept-routes
```

This must be re-run after any Tailscale logout. The `--advertise-routes` flag must also
be approved in the Tailscale admin console once.

IP forwarding must be enabled (the `ip-forward.service` systemd unit handles this at boot):

```bash
sysctl -w net.ipv4.ip_forward=1
# persisted via /etc/systemd/system/ip-forward.service
```

The MASQUERADE iptables rules still exist (from original setup) but are harmless and
do not provide connectivity. See `runbooks/vm-internet-bootstrap.md` for bootstrap
procedure and recovery steps.
