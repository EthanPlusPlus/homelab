# Documentation Structure

This file defines the rules, folder purposes, and conventions for this documentation system.
It is the authoritative reference for how knowledge is captured, maintained, and retrieved.

---

## Guiding Principle

Just enough structured, retrievable documentation — never more.
Every doc should earn its place. If removing it would not hurt, it should not exist.

---

## What this repo is

`~/canon/homelab/` is the **Prismo system canon** by convention (see `memory/system.md`).
The repo name is historical — Prismo emerged out of the homelab project.

It carries two things at once:

1. **Prismo system-wide governance** — V2 masterplan/roadmap, architectural laws,
   cross-cutting decisions (013–019), shared session memory, the prismo CLI script.
2. **Homelab-as-a-component specifics** — hardware specs, Proxmox/Ubuntu VM setup
   runbooks, service inventory, networking constraints.

The structure below applies to both. Decisions affecting Prismo-the-system live here.
Decisions affecting a single component's internals (e.g. how context-server implements
lifecycle-aware retrieval) live in that component's canon at `~/canon/<component>/`.

The eventual rename to `~/canon/prismo/` is deferred to when there's a forcing function
(web UI exposing project structure, new contributor onboarding). Until then the rule
above keeps things from getting more tangled.

---

## Indexing Boundaries

- `decisions/`, `runbooks/`, `architecture/`, `context/` — **indexed and trusted**
- `drafts/` — **not indexed by default**; treated as non-canonical until distilled
- `memory/` — **not indexed**; injected directly into Claude Code sessions via symlinks
- `STRUCTURE.md`, `open-questions.md`, `problem.md` — indexed top-level files; trusted

---

## Folders

### `context/`

Purpose: Live state of the project. What is true right now.

Belongs here:
- Current service inventory
- What is done, in progress, and next
- Active constraints
- Recent changes log

Does not belong here:
- Why something was decided (→ `decisions/`)
- How to do something (→ `runbooks/`)
- What the system is intended to look like (→ `architecture/`)

Example shape:

```
# Progress

## Complete
- Install Proxmox VE bare metal
- Configure WiFi on Proxmox

## In Progress
- Embedding model upgrade

## Next
- Auto re-index on git pull
```

---

### `decisions/`

Purpose: Record why something was decided. One file per decision.

Belongs here:
- Architectural choices and their rationale
- Tradeoffs considered
- Rejected alternatives

Does not belong here:
- Current state (→ `context/`)
- Step-by-step procedures (→ `runbooks/`)

Naming: `NNN-short-slug.md` (e.g. `007-mcp-transport.md`)

Example shape:

```
# Decision 001 — NAT over bridging

## Status
Adopted

## Context
WiFi does not support Linux bridging natively.

## Decision
Use NAT via iptables MASQUERADE on Proxmox host.

## Rationale
Simpler, works within current constraints.

## Alternatives Considered
- Bridging — not viable over WiFi

## Consequences
VMs are not directly addressable on LAN.
```

---

### `runbooks/`

Purpose: Step-by-step procedures for repeatable tasks.

Belongs here:
- Installation and setup procedures
- Recovery and maintenance steps
- Any task that will be repeated or referenced under pressure

Does not belong here:
- Reasoning or rationale (→ `decisions/`)
- Current state (→ `context/`)

Example shape:

```
# Runbook: Expand VM Logical Volume

## Prerequisites
- VM powered off

## Steps
1. Resize disk in Proxmox UI
2. Run `lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv`
3. Run `resize2fs /dev/ubuntu-vg/ubuntu-lv`

## Verify
df -h /
```

---

### `architecture/`

Purpose: Intended design of the system — what it is meant to look like.

Belongs here:
- Hardware specs
- Network topology
- Service relationships and boundaries
- Intended design decisions

Does not belong here:
- Actual current state (→ `context/`)
- Procedures (→ `runbooks/`)

Note: `architecture/` is the intended design. `context/` is the actual current state.
Drift between the two is meaningful and worth tracking.

---

### `drafts/` (legacy — Decision 021)

Frozen as historical record. **No new files land here.** Pre-approval content now lives
in workflow-state-service as ReviewItems; approved ReviewItems are written directly
into canonical folders by the approve endpoint. See [[decisions/021-reviewitems-as-judgment-boundary|Decision 021]]
and `architecture/phase1/capability-contracts.md` (ReviewItem endpoints).

Drafts already present (capture-*.md, sukuna-*.md) remain as-is and are excluded
from indexed retrieval (`record_type=draft`).

---

### `proposed-ideas/`

Purpose: Ideas worth capturing that have some reasoning behind them but are not yet adopted or fully unpacked.

Belongs here:
- Ideas raised in conversation with enough substance to be worth tracking
- Directions that are partially or fully reasoned but not yet implemented
- Anything too developed for `open-questions.md` but not ready for `decisions/`

Does not belong here:
- Adopted decisions (→ `decisions/`)
- Unresolved questions with no position yet (→ `open-questions.md`)
- Random notes with no reasoning behind them

Lifecycle:
```
proposed-ideas/ → unpack further or build → promote to decisions/ (Adopted), or remove if rejected
```

Naming: `NNN-short-slug.md`, same numbering convention as decisions.

---

### `memory/`

Purpose: Shared session bootstrap files — injected into every Claude Code session via symlinks
in `~/.claude/projects/<key>/memory/`. Updates automatically on `git pull`.

Note: This folder exists only in the homelab repo. Individual project repos do not have a
`memory/` folder — they use `CLAUDE.md` for project-specific session context.

Belongs here:
- System overview (hardware, services, directory structure)
- Shared workflow steps
- MCP connection details and query discipline
- Named workflow shorthands

Does not belong here:
- Personal behavioral preferences (→ personal memory, not committed)
- User-specific feedback (→ personal memory)
- Project-specific context (→ CLAUDE.md or project docs)

Not indexed by context-server. Content here is loaded directly into sessions, not via MCP.

---

### `open-questions.md`

Purpose: Flat list of unresolved questions not yet mature enough to become decisions.

Belongs here:
- Anything that needs a decision but does not have one yet
- Deferred questions worth tracking

Does not belong here:
- Resolved questions (move to relevant decision or remove)
- Active tasks (→ `context/progress.md`)

---

### `problem.md` _(optional)_

Purpose: Product north star — the problem this project exists to solve, in the project's own voice. Anchors downstream decisions by giving them a "why" to point back to.

Belongs here:
- The root problem being solved, with enough depth to distinguish it from surface symptoms
- Why existing solutions fall short (if relevant)
- Who is affected and how

Does not belong here:
- Solutions or approaches (→ `decisions/` or `proposed-ideas/`)
- Current system state (→ `context/`)
- Design intent (→ `architecture/`)

Optional: a project without a clearly articulated north star should not fabricate one. Leave the file out until the framing is real.

Reference shape: narrative opener followed by root-cause depth (e.g. 5-whys structure).

---

## Naming Conventions

- Filenames: lowercase, hyphen-separated (`recent-changes.md`, not `RecentChanges.md`)
- Decision files: `NNN-short-slug.md`, zero-padded to three digits
- No spaces in filenames

---

## Keeping Docs Honest

- `context/` must be updated at the end of every meaningful session
- `decisions/` entries are immutable once adopted — add a new entry to supersede
- `recent-changes.md` is a rolling log — keep only the last ~10 entries
- If a doc has not been read or referenced in months, question whether it earns its place
