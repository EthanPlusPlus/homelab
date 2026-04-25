---
name: Prismo session workflow
description: The 10-step workflow that applies to every change in every project — shared across all team sessions
type: project
---

## The Workflow

This applies to every change in every project — code, docs, config, infrastructure:

0. **Session bootstrap** (first message only) — read `~/canon/homelab/docs/context/recent-changes.md` directly; run a warm-up before any task: ask one question about what the user wants to build, query MCP based on their answer, repeat until context is saturated (2–4 exchanges). One question at a time. Skip if intent is already unambiguous.
1. **Read shared memory** — system, workflow, mcp, shorthands (auto-loaded via symlinks)
2. **Educate via MCP (Phase 1)** — before forming any opinion, query MCP on the topic and everything related. If already fetched this session, use what's in context. If MCP returns nothing and the topic plausibly has prior canon, fall back to a direct ~/canon/ read. If it's genuinely new territory, reason fresh.
3. **Reason and form a solution**
4. **Validate via MCP (Phase 2)** — query MCP against the specific solution: what it implies, assumes, and touches. Check for conflicts and duplication. Skip if relevant docs are already in context.
5. **Propose** — do not execute without explicit sign-off from the person you are working with
6. **Execute the approved plan** — no scope creep, no unrequested changes
7. **Update the docs** — progress.md, recent-changes.md, and any affected runbooks or decisions
8. **Re-index** — `curl -X POST http://localhost:8000/index` after doc changes
9. **Commit and push** — changes land in the repo, hook fires, context stays current

Everything in this system is iterable — code, docs, infrastructure, and these files themselves. Nothing is sacred. If something is wrong or outdated, the right move is to propose a change through the workflow, not work around it.

---

## Key Constraints

- Claude Code executes, but does not decide alone — the person in this session approves all plans
- Canonical docs are the only trusted knowledge source — drafts are not indexed
- Do not modify docs outside the relevant project's docs folder
- After any doc changes, re-index: `curl -X POST http://localhost:8000/index`
- Full constraints live in ~/canon/homelab/docs/context/constraints.md — read them

---

## Parallel Session Protocol

Before committing to canon, always `git pull` in the relevant worktree first.
Check `progress.md` → `## Working On` to see if someone else is actively in that area.

At the start of a session, add a one-liner to `## Working On` in `progress.md`.
Clear it when the session ends.
