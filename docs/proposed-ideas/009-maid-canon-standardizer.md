# 009 — Maid: Automated Canon Standardizer

## Status
Proposed — design constraint identified, not yet implemented

## Background

Canon accumulates inconsistency over time: terminology drifts, cross-references rot, formatting diverges between files written at different sessions. Fixing this manually is tedious and easy to defer. A recurring agent could handle the mechanical parts — but canon discipline constrains how far it can go autonomously.

Related to proposed-idea 008's "Canon scanner" concept under Persistent Observing Agents. That section already called out the unresolved prerequisite: write-back governance.

---

## The Idea

A "maid" subagent that runs on a cron job, reads through all of `~/canon/`, and identifies:

- Inconsistent terminology (e.g. "Prismo" vs "prismo", service names)
- Formatting divergence (headers, frontmatter, list style)
- Broken or stale cross-references between docs

---

## Design Constraint: Drafts-Only

Direct autonomous commits to canonical folders are blocked by Decision 003:

> "Truth is not automated — it is curated. The pipeline reduces effort but does not replace judgment."

The established lifecycle for AI-proposed changes is: `drafts/ → human review → distilled into canonical docs`. The maid must respect this lifecycle.

**The maid writes to `drafts/` only. It does not commit to canonical folders.**

Each run produces a diff-style or annotated proposal in `drafts/maid-YYYY-MM-DD.md`. Ethan reviews it, applies what's good, and commits. The maid reduces effort; it does not replace judgment.

This also sidesteps the worktree branch complexity (Decision 008) — writing a draft file requires no branch discipline.

---

## Open Questions

- **Scope**: All of `~/canon/` crosses project boundaries. Each project may have different conventions. Should maid be per-project or global?
- **Cron cadence**: Weekly? On-demand only? After each canon commit?
- **Output format**: Inline diff, annotated copy, or bulleted list of findings?
- **Canon write-back governance**: Before maid could ever auto-commit (even to non-canonical folders), a decision record defining what autonomous agents may write needs to exist. That decision doesn't exist yet.
- **Relationship to 008**: Maid is a concrete, scoped instance of 008's Canon scanner. Should it be tracked there, or is a standalone proposal cleaner?

---

## Prerequisites

- No new tooling needed for the drafts-only mode — Claude Code cron via the `schedule` skill is sufficient.
- Canon write-back governance decision required before expanding maid's write scope beyond `drafts/`.
