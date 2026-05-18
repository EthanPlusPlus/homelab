# V1 Service Map — Current Services and V2 Disposition

Current state of all services running on Prismo, with their role in V2.

---

## Infrastructure

| Service | Current Role | V2 Disposition |
|---------|-------------|----------------|
| Proxmox VE | Hypervisor on iMac (192.168.1.9) | Survives — hardware being replaced, topology stays |
| Ubuntu Server VM | Primary compute (Ubuntu 24.04, 192.168.100.10) | Survives — migrated to new hardware |
| Tailscale | Mesh VPN, remote access | Survives unchanged |
| Portainer | Docker management UI | Survives unchanged |

---

## Application Services

| Service | Current Role | V2 Disposition |
|---------|-------------|----------------|
| context-server API | Semantic retrieval over canon docs + code | Evolves → context-server v2 (critical path) |
| context-server MCP | MCP transport for Claude Code | Survives as one transport; capability contracts abstract above it |
| Obsidian sync pipeline | Mac edits → git push → server pull → re-index | Survives; may be supplemented by web UI contribution capture |
| Flight Planner | Development project, port 8080 | Unrelated to Prismo infra — continues independently |

---

## Automation & Agents

| Service | Current Role | V2 Disposition |
|---------|-------------|----------------|
| prismo CLI (scripts/prismo) | Automates new-project and new-machine setup | Deprecated — replaced by Layer 2 API calls in V2 |
| Sukuna (scripts/sukuna) | Canon maintenance agent, on-demand | Per [[../../decisions/021-reviewitems-as-judgment-boundary\|Decision 021]], becomes a synthesis-service consumer that emits ReviewItems instead of writing reports to `drafts/`. The "Sukuna v2 as separate service" framing was dropped. |
| CLAUDE.md governance | Session behavior, canon discipline, workflow rules | Deprecated as primary governance — becomes a thin Claude runtime adapter; governance moves to workflow-state-service |
| Hooks (Stop, UserPromptSubmit) | Behavioral enforcement patches | Deprecated — removed once structural workflow enforcement exists |

---

## Services To Be Built (V2)

| Service | Program | Priority |
|---------|---------|----------|
| context-server v2 | Program 2 | Critical |
| workflow-state-service | Program 2 | High |
| doctrine-service | Program 2 | High |
| synthesis-service | Program 2 | Medium |
| runtime abstraction layer | Program 3 | High |
| local inference stack | Program 3 / 4 | Medium |
| Prismo web UI | Program 5 | High |
| WhatsApp integration | Program 5 | High (nearest-term teammate access) |

---

## Hardware Note

All services currently run on the iMac (2017, Proxmox). Hardware is being replaced with a proper server. Key constraint driving hardware spec: local inference requires ~40–48GB GPU VRAM for a 70B parameter model. Hardware decision deferred until after runtime abstraction layer design (Phase 4).
