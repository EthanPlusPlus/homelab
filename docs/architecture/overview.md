# Network Architecture

## Topology

```
Internet
  → Home Router (192.168.1.1)
  → Proxmox Host (192.168.1.9) via WiFi (wlp2s0)
    → Ubuntu Server VM (192.168.100.10) via NAT
```

## Proxmox Host

| Property | Value |
|----------|-------|
| IP | 192.168.1.9 (static) |
| Interface | wlp2s0 (WiFi) |
| Gateway | 192.168.1.1 |
| Web UI | https://192.168.1.9:8006 |

## VM Subnet

| Property | Value |
|----------|-------|
| Subnet | 192.168.100.0/24 |
| Proxmox gateway (vmbr0) | 192.168.100.2 |
| Ubuntu VM | 192.168.100.10 |

## NAT Configuration

| Setting | Value |
|---------|-------|
| IP forwarding | net.ipv4.ip_forward=1 in /etc/sysctl.conf |
| iptables rule | MASQUERADE from 192.168.100.0/24 via wlp2s0 |
| Persistence | iptables-persistent, saved to /etc/iptables/rules.v4 |

## Known Constraints

- WiFi does not support Linux bridging natively — forces NAT architecture
- VMs cannot be bridged directly to home network
- Proxmox IP may drift on reboot — consider DHCP reservation on router
- Ethernet (nic0) available as fallback if WiFi causes issues
