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
| VM networking | VMs on internal subnet (192.168.100.0/24) via NAT — not directly addressable on home network (192.168.1.x) |
| Remote access | VM services require Tailscale or port forwarding — no direct LAN access |
| Proxmox IP | Static at 192.168.1.9 — no DHCP reservation, but ip_forward and iptables rules are now persisted |
