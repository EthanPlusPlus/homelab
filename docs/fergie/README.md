# fergie/

**Fergie time** — the extra minutes at the end of the match where the work gets
finished. This folder tracks the agentic loop build (Decisions 036/037/038):
implementation plans, open spec tasks, and progress that doesn't fit the
existing canon folders.

## What belongs here

- The loop build plan and its phase tracking (`loop-build-plan.md`)
- Spec drafts for loop components before they harden into decisions or code
- Progress notes specific to this build

## What does not belong here

- Decisions (→ `decisions/` — 036, 037, 038 are the loop's governing records)
- Live system state (→ `context/`)
- Anything that outlives the loop build — when the build completes, durable
  content migrates to its proper home and this folder's contents archive

## Relationship to v2-progress.md

`architecture/v2-progress.md` remains the overarching phase index — the loop
build is tracked there as part of Phase 5 (human interaction layer) with a
pointer here. This folder holds the detail that would bloat the index. One
direction of truth: v2-progress.md points here, never duplicates.
