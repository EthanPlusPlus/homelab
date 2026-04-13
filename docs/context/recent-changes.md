# Recent Changes

Rolling log of meaningful system changes. Keep last ~10 entries. One to three lines each.
Oldest entries are removed as new ones are added.

---

- **context-server/docs/ established** — context-server decisions and context split out; each project repo is now self-contained
- **Session bootstrapping established** — CLAUDE.md added to homelab and context-server repos; Prismo system overview added to architecture/; new-machine-setup runbook added
- **Git hooks implemented** — post-merge hooks added to homelab, context-server, and devcamp repos; auto re-indexing fires on git pull in each repo
- **Claude Code installed on VM** — accessible via Tailscale; connected to context-server MCP on port 8001
- **iptables rules persisted** — homelab NAT rule now survives reboots via iptables-persistent on Ubuntu VM
- **ip_forward persisted on Proxmox host** — added net.ipv4.ip_forward=1 to /etc/sysctl.conf
- **VM logical volume expanded** — 15GB → 30GB via LVM
