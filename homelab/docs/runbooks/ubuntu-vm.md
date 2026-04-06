# Runbook — Ubuntu Server VM

## Specs

| Property | Value |
|----------|-------|
| OS | Ubuntu Server 24.04 LTS |
| Disk | 32GB |
| RAM | 4GB |
| CPU | 2 cores |
| IP | 192.168.100.10/24 (static) |
| Gateway | 192.168.100.2 (Proxmox vmbr0) |
| DNS | 8.8.8.8, 1.1.1.1 |

## Netplan Configuration

File: `/etc/netplan/00-installer-config.yaml`

```yaml
network:
  version: 2
  ethernets:
    ens18:
      addresses:
        - 192.168.100.10/24
      routes:
        - to: default
          via: 192.168.100.2
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

## Docker

- Version: 29.3.1
- Service running on boot

## Portainer

- Image: portainer/portainer-ce:latest
- Port: 9000
- Access via Tailscale: http://100.92.226.121:9000

## Tailscale

| Property | Value |
|----------|-------|
| IPv4 | 100.92.226.121 |
| Hostname | ubuntu-server.tail58b10c.ts.net |
