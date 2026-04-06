# Runbook — Proxmox Setup

## WiFi Configuration (wpa_supplicant)

WiFi is not natively supported by Proxmox. Configured manually via wpa_supplicant.

Static IP set to 192.168.1.9, gateway 192.168.1.1 on wlp2s0.

## Repository Configuration

- Enterprise repo: disabled
- Community (free) repo: enabled

## NAT Setup

```bash
# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Add MASQUERADE rule
iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -o wlp2s0 -j MASQUERADE

# Persist rules
apt install iptables-persistent
iptables-save > /etc/iptables/rules.v4
```

## Virtual Bridge (vmbr0)

- IP: 192.168.100.2/24
- Bridges nic1 (internal only)
- Acts as gateway for all VMs
