---
id: "004"
title: Git-Backed Memory Portability
status: Superseded — see decision 010
---

# 004 — Git-Backed Memory Portability

## Status

Proposed — trade-off requires deliberate decision

## Problem

Claude Code memory lives in `~/.claude/projects/<path-derived-key>/memory/` and is
scoped to the directory Claude Code is launched from. This creates two failure modes:

1. **Silent loss** — launching from a different directory (even on the same machine)
   gives a different or empty memory context with no warning.
2. **Manual sync** — syncing memory across machines requires a manual `scp` step that
   is easy to forget and has no automation.

The result is that the multi-machine experience is inconsistent: sessions on a secondary
machine start cold or with stale memory, silently degrading Claude's reasoning.

## Proposed Direction

Move memory into the homelab git repo (`~/canon/homelab/docs/memory/` or similar),
committed and versioned alongside other canonical docs. Claude Code sessions would
reference it via a symlink or explicit path rather than the default `~/.claude/` location.

**What this gives you:**
- Memory syncs automatically with `git pull` — no manual `scp`
- Memory is versioned and auditable
- All machines and Claude instances share the same memory state

## Key Trade-Off

The homelab repo is public on GitHub. Memory currently contains behavioral preferences,
session feedback, and project context that may include details not intended to be public.

**Before adopting this approach, decide:**
- Is the homelab repo staying public? If so, what content is acceptable in public memory?
- Should memory be split — public behavioral rules vs. private project state?
- Would a separate private repo (or local-only file with MEMORY.md as a stub) work better?

## Alternative: Symlink-Based Consolidation (Without Git)

Rather than committing memory to git, establish a canonical memory location on the VM
(e.g. `/home/ethan/.claude/prismo-memory/`) and symlink all per-project memory paths
to it. Memory stays local and private, but the multi-directory problem is solved.
Cross-machine sync would still require `scp` but from a single known location.

## Open Questions

- Does Claude Code follow symlinks for the memory directory?
- What is the right boundary between what goes in memory vs. what goes in canon docs?
- If memory is git-backed, should it be in the homelab repo or a separate private repo?
