# Constraints

Active limitations that materially affect design or system behavior.
If a constraint disappeared, something would work differently.

---

## Claude Reasoning

### Two-Phase Canon Discipline (Decision 011)

Applies to any project with a canon at `~/canon/<project-name>/`. Triggered, not always-on.

**Triggers — engage when about to:**
- Surface a proposal, plan, recommendation, or decision to Ethan
- Write or modify canon
- Change architecture or service config

Skip for: clarifying questions, code reads, tool discovery, factual lookups about system state.

**Phase 1 — Saturate:**
Query the context-server MCP with `doc_type=<project-name>` before forming a view. Reuse
session context if already fetched. If MCP returns empty but canon should plausibly exist
(topic in-scope, decision-type, adjacent hits, system state implies prior decision), fall
back to a direct `~/canon/<project-name>/` read.

**Phase 2 — Mandatory Hermes Dispatch:**
Before surfacing, dispatch the `hermes` subagent with the proposal, project name
(`doc_type`), and canon path. Hermes returns findings in four buckets: (1) conflicts with
canon, (2) duplication of resolved questions, (3) assumptions canon contradicts, (4) canon
gaps the proposal would fill. Surface Hermes' full output to Ethan. Do not silently revise.
Re-dispatch on revision.

The tool call is the evidence. A self-reported check does not count.

**Structural enforcement (per-machine):**
- `UserPromptSubmit` hook in `~/.claude/settings.json` — preventative per-turn reminder
- `Stop` hook in `~/.claude/settings.json` — detection gate before response ends

See Decision 011 for full rationale and open risks.

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
