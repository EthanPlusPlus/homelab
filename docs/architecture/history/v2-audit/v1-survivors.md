# V1 Survivors — What Must Carry Into V2

Assets identified as load-bearing. Do not redesign, replace, or discard without explicit decision.

---

## Layer 1 — Durable Substrate

### ~/canon/ + ~/projects/ separation (Decision 007)
The code/knowledge split is a genuine architectural insight. All of V2 builds on this topology. The indexer scanning `~/canon/` instead of `~/projects/` is structural enforcement of MCP-first retrieval.

### canon/ filesystem structure
Markdown + git + filesystem hierarchy. The actual format and storage layer. Not clever, not novel — durable. Every other V2 layer depends on this existing.

### Project isolation model
Each project carries its own `decisions/`, `runbooks/`, `architecture/`, `context/`. Clean boundaries between homelab-level and project-level concerns. Survives into V2 unchanged.

### Decisions as immutable records with supersession chains
The pattern of decisions being adopted once and then explicitly superseded (rather than edited) is correct. The 009→011→012 chain is the right shape even if the individual decisions changed. V2's doctrine-service formalizes this; it does not replace it.

### Drafts-only write constraint
"Truth is curated, not automated." Before any synthesis output becomes canonical, it passes through human review via `docs/drafts/`. This is the structural implementation of "humans retain authority." Must survive into V2 regardless of how much synthesis is automated.

---

## Layer 2 — Services

### context-server as an independent HTTP service
The separation of retrieval from the runtime is the embryo of the Layer 3 abstraction. The service boundary is correct. V2 expands what the service does; it does not restructure it away.

### Semantic indexing + MCP transport
The decision to expose retrieval via MCP (open protocol, HTTP transport) rather than embedding it in Claude Code is the right call. Provider-agnostic by nature.

---

## Multi-user

### Shared memory via symlinks (Decision 010)
Memory living in `~/canon/homelab/docs/memory/` and symlinked into each machine's Claude Code directory is working and correct. V2 extends this; doesn't replace it.

---

## Infrastructure

### Tailscale
Mesh VPN providing remote access without port forwarding. Not being replaced — remains the access layer for V2.

### Proxmox + Ubuntu Server VM
The hypervisor + VM topology is the right shape. Hardware is being replaced but the architecture (Proxmox host → Ubuntu VM → services) survives.
