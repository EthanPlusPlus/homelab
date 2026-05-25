# ip-forward.service

Proxmox systemd unit. Ensures `net.ipv4.ip_forward=1` is set at boot, required
for Tailscale subnet routing to forward VM traffic through the Tailscale tunnel.

**Install path:** `/etc/systemd/system/ip-forward.service` on Proxmox host.

```ini
[Unit]
Description=Enable IP forwarding
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/sysctl -w net.ipv4.ip_forward=1
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable with:

```bash
systemctl daemon-reload
systemctl enable --now ip-forward
```
