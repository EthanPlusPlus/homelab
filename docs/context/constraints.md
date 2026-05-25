# Constraints

Active limitations that materially affect design or system behavior.
If a constraint disappeared, something would work differently.

---

## Claude Reasoning

### Canon Discipline (Decision 012)

Applies to any project with a canon at `~/canon/<project-name>/`. Triggered, not always-on.

**Triggers — engage when about to:**
- Surface a proposal, plan, recommendation, or decision to Ethan
- Write or modify canon
- Change architecture or service config

Skip for: clarifying questions, code reads, tool discovery, factual lookups about system state.

**Phase 1 — Saturate:**
Query the context-server MCP with `doc_type=<project-name>` before forming a view. Reuse
session context if already fetched. If MCP returns empty but canon should plausibly exist,
fall back to a direct `~/canon/<project-name>/` read.

**Phase 2 — Validate (inline):**
Query MCP against the specific proposal: what it implies, assumes, and touches. Check for
conflicts and duplication. MCP tool calls in the transcript are the evidence — a self-reported
check does not count. Skip if relevant docs are already in context from Phase 1.

**Session bootstrap (first message of every session):**
Read `~/canon/homelab/docs/context/recent-changes.md` directly. Then run a warm-up before
any task: ask one question about what the user wants to build, query MCP on their answer,
repeat until context is saturated (2–4 exchanges). One question at a time, conversational tone.

See Decision 012 for full rationale.

---

## Tooling & Agents

### Cross-Machine Portability

All scripts, agent definitions, and tooling must work on any machine that has cloned
the homelab repo. Cross-machine access is always a concern — never design Prismo tooling
as VM-only. The homelab repo (`~/canon/homelab/`) is the distribution mechanism: anything
committed there is available everywhere via `git pull`.

Corollary: agent definitions (e.g. `~/.claude/agents/`) must be symlinked from
`~/canon/homelab/scripts/` and wired up by the onboarding flow, not installed ad-hoc.

---

## Infrastructure

| Constraint | Detail |
|------------|--------|
| RAM | 8GB current — limits concurrent workloads; 32GB upgrade pending |
| CPU | Intel i5 quad-core, CPU-only — no GPU acceleration for inference |
| Storage | Ubuntu VM logical volume at 30GB |
| Network | Proxmox runs on WiFi (wlp2s0) — Linux bridging not supported over WiFi |
| VM networking | VM on `vmbr0` (192.168.100.0/24), static IP `192.168.100.10`. NAT/MASQUERADE rules exist but **do not provide internet access** — return packets are consumed by the host INPUT chain before conntrack can reverse-NAT them. This is a fundamental kernel behavior, not a configuration bug. All workarounds (DNAT, fwmarks, rp_filter, route_localnet, proxy ARP, Ethernet) were attempted and failed. |
| VM internet access | Provided entirely by **Tailscale subnet router** on Proxmox (`--advertise-routes=192.168.100.0/24`). VM traffic exits via the Tailscale tunnel on Proxmox's WiFi — this path works because Proxmox's own outbound traffic is not subject to the NAT return-path problem. See `runbooks/vm-internet-bootstrap.md`. |
| VM internet bootstrap | VM Tailscale needs DNS to authenticate on boot; DNS depends on Tailscale — deadlock. Resolved by `tailscale-proxy.service` on Proxmox (socat proxying port 8443 → `controlplane.tailscale.com:443`). VM `tailscaled` is configured to use this proxy for bootstrap. |
| Remote access | VM services require Tailscale — not directly addressable on home LAN (192.168.100.x is internal only) |
| Proxmox IP | Static at 192.168.1.9 |
| DNS resilience | `/etc/systemd/resolved.conf` on VM has `DNS=8.8.8.8 1.1.1.1` and `FallbackDNS=9.9.9.9` — required as a second layer of defence against the Tailscale/DNS deadlock |
