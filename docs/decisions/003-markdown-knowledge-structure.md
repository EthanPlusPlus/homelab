# Decision 003 — Structured markdown over monolithic Word document

## Status
Adopted

## Context
Project knowledge was stored in a single Word document (homelab_documentation.docx). As the project grows toward a retrieval system, this becomes a liability — poor signal-to-noise ratio, not version-controllable, not retrieval-friendly.

## Decision
Migrate to modular markdown files, colocated with the project, structured for retrieval:

```
docs/
  architecture/   # system structure, topology, hardware
  decisions/      # what was decided, why, what was rejected
  runbooks/       # how to do specific operational tasks
  context/        # current state of services and progress
  open-questions.md
  drafts/         # unreviewed extractions from conversations
```

## Rejected Approaches
- **Monolithic Word doc** — low signal-to-noise, hard to retrieve from, not version-controlled
- **Raw conversation indexing** — too noisy, weak structure, redundant once knowledge is distilled

## Key Principle
Conversations are for exploration — markdown is for consolidation.
Truth is not automated — it is curated. The pipeline reduces effort but does not replace judgment.

## Consequences
- Word document retired as canonical source after migration
- All future decisions, architecture changes, and runbooks go into this structure
- Drafts folder acts as staging area for conversation-extracted knowledge pending review
