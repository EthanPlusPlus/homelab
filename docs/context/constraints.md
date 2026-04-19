# Constraints

Active limitations that materially affect design or system behavior.
If a constraint disappeared, something would work differently.

---

## Claude Reasoning

### MCP Before Every Thought

Every idea, finding, or proposed solution must pass through a two-phase MCP query
before being surfaced:

1. **Educate first** — before forming any opinion, query MCP on the topic and
   everything connected to it. If that context was already fetched this session,
   use it — no re-query needed.

   If MCP returns nothing and the topic plausibly has prior canon (it's within
   Prismo's established scope, or a decision that would have had to be made to
   reach the current system state), fall back to a direct read of the relevant
   ~/canon/ file before reasoning. If it's genuinely new territory, reason fresh.

2. **Validate the solution** — once a decision is formed, query MCP against that
   specific decision: what it implies, what it assumes, what it touches. Check for
   conflicts with existing decisions and duplication of already-resolved questions.
   Skip if the relevant docs are already in context.

This applies to every thought — not just infrastructure changes or major decisions.
The fuzziness around "should technically be there" is a known open question.

### Mandatory Proposal Template

Every proposal, plan, or recommendation surfaced to Ethan must begin with this
header. A proposal without it is structurally incomplete — do not skip it.

```
Phase 1 — Educate
  Queries: [MCP queries run before reasoning]
  Key findings: [what informed the approach]

Phase 2 — Validate
  Queries: [MCP queries run against this specific solution]
  Conflicts: [conflicts with existing decisions, or "none"]
  Duplication: [overlap with existing canon, or "none"]
```

Direct reads of `~/canon/` are only permitted as a Phase 1 fallback when MCP
returns nothing for a topic that plausibly has prior canon. They are not a
substitute for MCP. If a direct read was used, note it under Phase 1 queries.

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
| Proxmox IP | Static at 192.168.1.9 — no DHCP reservation, but ip_forward and iptables rules are now persisted |

