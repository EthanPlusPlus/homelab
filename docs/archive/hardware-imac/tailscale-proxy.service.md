# tailscale-proxy.service

Proxmox systemd unit. Runs a socat listener that proxies VM Tailscale bootstrap
traffic to the Tailscale control plane. Required because the VM can't reach the
internet directly without Tailscale already running — the proxy breaks the deadlock
by using Proxmox's own working internet connection.

The destination `192.200.0.101` is a Tailscale control plane IP (used instead of
the hostname to avoid needing DNS resolution at proxy start time).

**Install path:** `/etc/systemd/system/tailscale-proxy.service` on Proxmox host.

```ini
[Unit]
Description=Tailscale control plane proxy for VM bootstrap
After=network.target

[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:8443,fork,reuseaddr TCP:192.200.0.101:443
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable with:

```bash
systemctl daemon-reload
systemctl enable --now tailscale-proxy
```
