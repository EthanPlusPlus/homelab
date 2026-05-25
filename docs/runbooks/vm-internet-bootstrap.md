# Runbook — VM Internet Bootstrap

## Architecture

The Ubuntu Server VM (`192.168.100.10`) gets internet access via **Tailscale subnet
router** on Proxmox. Proxmox runs Tailscale with `--advertise-routes=192.168.100.0/24`,
advertising the internal subnet to the Tailscale network. VM traffic exits via the
Tailscale tunnel on Proxmox's WiFi — this works because Proxmox's own outbound traffic
is not subject to the NAT return-path problem that makes MASQUERADE non-functional.

NAT/MASQUERADE rules exist on Proxmox but **do not provide internet access**. Do not
attempt to use or fix them. See `constraints.md` for the full technical explanation.

---

## The Bootstrap Deadlock

On reboot, Tailscale on the VM needs to reach `controlplane.tailscale.com` to
authenticate. This requires internet, which requires Tailscale — a deadlock.

**Fix:** A `tailscale-proxy.service` on Proxmox runs a socat listener that proxies
HTTPS connections to Tailscale's control plane over Proxmox's own working internet
connection. The VM's `tailscaled` is configured to use this proxy for its initial
bootstrap.

---

## Services That Must Be Running on Proxmox

| Service | Purpose |
|---------|---------|
| `tailscale-proxy.service` | socat proxy: `TCP:8443` → `controlplane.tailscale.com:443` |
| `ip-forward.service` | sets `net.ipv4.ip_forward=1` at boot |
| Tailscale (`tailscaled`) | subnet router advertising `192.168.100.0/24` |

Check all three:

```bash
# On Proxmox
systemctl status tailscale-proxy
systemctl status ip-forward
tailscale status
```

Tailscale status should show `--advertise-routes=192.168.100.0/24` active.

---

## Recovery — VM Has No Internet

If the VM loses internet after a reboot or Tailscale disruption:

**Step 1 — Check Proxmox Tailscale:**

```bash
# On Proxmox
tailscale status
```

If Tailscale is not running or not authenticated:

```bash
tailscale up --advertise-routes=192.168.100.0/24 --accept-routes
```

**Step 2 — Check socat proxy:**

```bash
systemctl status tailscale-proxy
systemctl start tailscale-proxy  # if stopped
```

**Step 3 — Check VM Tailscale:**

```bash
# On VM
tailscale status
```

If logged out:

```bash
tailscale up  # uses configured proxy for bootstrap
```

**Step 4 — Check DNS on VM:**

```bash
resolvectl status
```

If no DNS servers are active, `/etc/systemd/resolved.conf` should have:

```ini
DNS=8.8.8.8 1.1.1.1
FallbackDNS=9.9.9.9
```

Restart resolved if needed:

```bash
systemctl restart systemd-resolved
```

---

## VM Network Config

- Interface: `ens18` on `vmbr0`
- Static IP: `192.168.100.10/24`
- Default gateway: `192.168.100.2` (Proxmox vmbr0 interface)
- DNS: managed by `systemd-resolved` with Tailscale + fallback

Tailscale on Proxmox acts as the exit node for the `192.168.100.0/24` subnet.
The route must be approved in the Tailscale admin console (one-time setup).
