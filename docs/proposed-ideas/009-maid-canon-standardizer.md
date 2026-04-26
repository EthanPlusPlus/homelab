# 009 — Sukuna: Canon Maintenance and Thinking Agent

## Status
In progress — agent definition and invocation script built; onboarding wired; pending first run

## Background

Canon accumulates inconsistency over time: terminology drifts, cross-references rot, formatting
diverges between files written at different sessions. A recurring agent can handle the mechanical
parts — but canon discipline constrains how far it can go autonomously.

Originally scoped as "Maid" (a consistency-only standardizer). Expanded during design to absorb
the thinking/synthesis role from proposed-idea 008's "Non-use agent" concept — since the agent
already loads all of `~/canon/` for the consistency pass, the context is free to reuse.

---

## Design

A single agent reads all of `~/canon/` in one pass and works through three sections in order:

### Section 1 — Consistency Pass
- Terminology drift, formatting divergence, stale cross-references
- Output: diff-style wording fixes + bulleted structural findings

### Section 2 — Observations
- Patterns across projects without decision records
- Contradictions between proposed-ideas and decisions
- Gaps: concepts assumed but never formally defined
- Capped at 7 bullets, specific file references required

### Section 3 — Thinking (directed or free-wheel)
- If a direction is provided at invocation: focus on that topic
- If no direction: free-wheel across open proposed-ideas
- Unconstrained — challenge decisions, tear apart assumptions, propose conflicts
- 10 bullets max, punchy not verbose

**Directable thinking** solves the diminishing-returns concern (Critic, council session): when
canon stabilises between runs, a direction keeps section 3 fresh and targeted.

---

## Design Constraint: Drafts-Only

Direct autonomous commits to canonical folders are blocked by Decision 003:

> "Truth is not automated — it is curated. The pipeline reduces effort but does not replace judgment."

Sukuna writes to `~/canon/homelab/docs/drafts/sukuna-YYYY-MM-DD.md` only. It commits and pushes
the draft file — nothing else. Ethan reviews, applies what's useful, and commits to canon directly.

---

## Implementation

- Agent definition: `~/canon/homelab/scripts/sukuna.md` → symlinked to `~/.claude/agents/sukuna.md`
- Invocation script: `~/canon/homelab/scripts/sukuna [optional direction]`
- Onboarding: agent symlink added to `add-vm-user.md` step 5
- Cross-machine: symlink wired on each machine via onboarding flow; homelab repo is the distribution mechanism

Invoke:
```bash
~/canon/homelab/scripts/sukuna                          # free run
~/canon/homelab/scripts/sukuna "focus on proposed-idea 008"  # directed
```

---

## Scalability Hook

The architecture is designed for future thinker subagents. The invocation script runs a Claude
orchestrator session; additional subagents can be spawned alongside Sukuna to read its output
and respond. No architectural rework needed — add subagents to the orchestrator call.

---

## Open Questions

- **Cadence**: on-command for now; scheduling TBD
- **add-vm-user.md improvement**: the onboarding runbook needs a proper script (currently manual steps)
- **Section 3 gating**: consider running section 3 only when new proposed-ideas have been added since last run, to manage diminishing returns at scale
