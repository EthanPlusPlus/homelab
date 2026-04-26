---
id: "001"
title: Subagent Usage in Prismo
status: Proposed — needs further unpacking
---

# 001 — Subagent Usage in Prismo

## Status
Proposed — needs further unpacking

## Background
Prismo's founding principle is that Claude should be a reasoning engine, not a search engine.
MCP pre-filters knowledge context before Claude reasons. The question is whether Claude Code
subagents could extend this pattern — offloading exploration, doc updates, and other bulk work
to subagents to keep the main context clean.

## Initial Reasoning

Three patterns were considered:

**1. Explore subagent for large code tasks**
When a task requires exploring a large unfamiliar codebase (many Glob/Grep/Read cycles),
delegate to an Explore subagent. It returns a synthesis; raw file contents never enter main
context. Token savings are real at scale. This is the most clearly justified pattern.

**2. Doc-update subagent (background)**
After executing a change, spawn a subagent to handle steps 7–9 of the workflow (update
progress.md, recent-changes.md, re-index, commit, push) in the background. Main Claude
continues without housekeeping overhead. Benefit is real but modest — the files are small
and subagent spawn overhead may negate savings.

**3. Plan validation subagent**
Before proposing to Ethan, a Plan subagent validates the solution against current code/docs
and returns a conflict report. Adds opacity at the step where Prismo most needs transparency.
Probably not worth it.

_Update (Decision 012 — Supersedes 011):_ Pattern 3 was briefly adopted as the `hermes`
subagent but reversed. Subagent spawn overhead and cold-start cost outweighed the benefit;
inline Phase 2 MCP queries by the main agent are cheaper and equally auditable. Pattern 3
remains unresolved.

## Key Tension
Subagents fail silently from the main context's perspective — you get a result, not a
reasoning chain. Prismo's workflow requires human review before execution. Subagent opacity
conflicts with this, making mistakes harder to diagnose.

The architectural cleanliness argument is real but so is the debuggability cost. The only
concrete gains beyond cleanliness are background execution and parallelism — both modest at
current scale.

## Open
- At what project scale does the Explore subagent become clearly worth it?
- Is there a lightweight way to surface subagent reasoning for review?
- Does the doc-update subagent make sense once the workflow grows more complex?
- Pattern 3 (plan validation subagent): Hermes was the implementation; reversed by Decision 012. Current status: unresolved, no implementation.
