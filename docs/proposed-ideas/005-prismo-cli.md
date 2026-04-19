---
id: "005"
title: Prismo CLI / Automation Script
status: Proposed — design needed before implementation
---

# 005 — Prismo CLI / Automation Script

## Status

Proposed — design needed before implementation

## Problem

Several Prismo operations involve multi-step manual command sequences that are:
- Documented in runbooks that can drift from reality (and have)
- Easy to execute partially or in the wrong order
- Repeated identically for every new project or machine setup

The two highest-friction operations are:

1. **New machine setup** — ~6 steps, git sparse checkout, worktree creation, manual hook
   construction with hardcoded absolute paths, MCP server registration
2. **New project setup** — ~8 steps, same categories, plus docs scaffolding

## Proposed Direction

A `prismo` shell script (or small collection of scripts) that encodes the canonical
sequences. Possible subcommands:

```
prismo new-project <name> <repo-url>   # full project setup from scratch
prismo new-machine                     # interactive machine onboarding
prismo index [--code <project>]        # trigger re-index (docs or code)
prismo status                          # show indexed projects, hook health
```

The script would live in the homelab repo (`scripts/prismo`) and be available on any
machine that has homelab cloned.

## Key Tension

Prismo's workflow is deliberately manual and reviewed at every step. A script that
automates setup introduces a new abstraction layer that:
- Can fail silently (especially git sparse-checkout and worktree state)
- Is harder to debug when it does fail
- Adds a maintenance surface (the script itself must be updated when the process changes)

The alternative — manual commands from a well-maintained runbook — is also a failure
mode, just a slower one. The question is which failure mode is more acceptable.

## Preconditions

Before building the script:
1. The new-project runbook must be stable and verified correct (written 2026-04-19)
2. Decide on memory portability approach (see 004) — the script may need to handle
   memory setup differently depending on that decision
3. Decide whether the script targets VM-only or all machines

## Open Questions

- Should `prismo` be a single script or a collection (like `git` subcommands)?
- How do we test it without having a fresh machine to test against?
- Does it handle the worktree hook path correctly, or does that stay manual?
