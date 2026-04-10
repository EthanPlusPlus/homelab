# Constraints

Active limitations that materially affect design or system behavior.
If a constraint disappeared, something would work differently.

---

## Infrastructure

| Constraint | Detail |
|------------|--------|
| RAM | 8GB current — limits concurrent workloads; 32GB upgrade pending |
| CPU | Intel i5 quad-core, CPU-only — no GPU acceleration for inference |
| Storage | Ubuntu VM logical volume at 30GB |
| Network | Proxmox runs on WiFi (wlp2s0) — Linux bridging not supported over WiFi |
| VM networking | VMs on internal subnet (192.168.100.0/24) via NAT — not directly addressable on home network (192.168.1.x) |
| Remote access | VM services require Tailscale or port forwarding — no direct LAN access |
| Proxmox IP | Static at 192.168.1.9 but no DHCP reservation — may drift on reboot |

---

## AI / Retrieval Layer

| Constraint | Detail |
|------------|--------|
| Claude role | Reasoning and architecture only — no direct execution |
| Cowork role | File creation and execution only — no architecture decisions |
| Retrieval dependency | Claude Code must retrieve context before reasoning — no assumed persistent memory |
| Canonical source | Only indexed docs are trusted retrieval sources — drafts are excluded by default |
| Embedding model | `all-MiniLM-L6-v2` — lower quality than `all-mpnet-base-v2`; upgrade deferred until retrieval quality is a bottleneck |
| Local inference | Blocked until RAM upgrade — Ollama requires 32GB to run useful models |
