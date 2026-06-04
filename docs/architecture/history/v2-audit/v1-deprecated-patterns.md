# V1 Deprecated Patterns — Accidental Complexity to Drop in V2

These patterns worked in V1 but are not worth carrying forward. Each is a workaround for absent infrastructure, not a design choice to preserve.

---

## Workflow Rituals

### Session bootstrap warm-up conversation
The ask → MCP query → ask → MCP query loop was solving a cold-start problem: sessions had no context, so the first half was wasted on re-discovery. The fix is a Layer 2 context bundle generated at session start. The conversation ritual goes away when the bundle exists. Do not replicate this loop into the web UI.

### Pull-before-commit parallel session protocol
Manual coordination for a problem Layer 2's workflow-state-service solves structurally. When the service tracks active contributors and detects conflicts, this becomes unnecessary.

### "Start sessions with hi" trigger
A prompt ritual with no decision basis. Propagated into flight-planner and even project scaffolds where it doesn't belong. Remove from all project templates.

---

## Git Workflow

### Docs worktree branch merges into master (Decision 008 — deleted)
The merge ceremony was created to keep docs and code history aligned on a single branch. In V2, docs and code are indexed independently — the shared history on master buys nothing. Drop the requirement entirely. Each repo's docs branch can stay as a permanent working branch.

---

## Enforcement Patches

### Stop hook + UserPromptSubmit hook
Both are behavioral patches compensating for absent structural enforcement. Once workflow-state-service generates operational context automatically, these become unnecessary. They should not be forward-ported to V2 project setups.

---

## CLI Automation

### prismo bash script
Encodes multi-step setup sequences that drift from runbooks (it already has a known bug: VM_HOST hardcoded). In V2, these operations become Layer 2 API calls. The script is a prototype that served its purpose; V2 does not need a bash successor.

---

## Hermes
The adversarial review subagent. Tried, reversed. Cold-start cost outweighed the benefit. Inline Phase 2 MCP queries by the main agent are cheaper and equally auditable. Do not re-implement as part of V2 runtime design.
