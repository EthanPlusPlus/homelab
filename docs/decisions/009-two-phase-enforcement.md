# Decision 009 — Structural enforcement of the two-phase MCP query discipline

## Status
Superseded by Decision 011

## Context
The two-phase MCP query discipline (constraints.md — "MCP Before Every Thought") was
correct in principle but failed in practice: Phase 2 was routinely skipped, and Claude
would bypass MCP by reading `~/canon/` directly. Confronting Claude after the fact
confirmed the instructions were clear — the problem was not comprehension, it was that
no structural gate existed to force compliance.

Two failure modes were identified:
1. **Execution failure** — Phase 2 simply wasn't run before proposing.
2. **Bypass failure** — Direct filesystem reads of `~/canon/` substituted for MCP queries,
   voiding the retrieval layer entirely.

## Decision
Enforce the two-phase discipline at two independent layers:

**Layer 1 — Mandatory proposal template (schema enforcement)**
Every proposal, plan, or recommendation must begin with a completed Phase 1 and Phase 2
header before the proposal body. An absent or incomplete header is visibly wrong to Ethan
without requiring any tooling. This is documented in constraints.md.

**Layer 2 — Stop hook (execution enforcement)**
A `Stop` hook in `~/.claude/settings.json` fires every time Claude is about to finish a
response. It injects a Phase 2 check reminder into the conversation. If a proposal was
made without Phase 2, Claude sees the reminder and must run it before stopping.

Both layers are required together:
- The schema makes omission visible and auditable.
- The hook makes omission structurally harder to complete without noticing.

## Rationale
Instructions alone were proven insufficient — Claude acknowledged clear instructions and
still skipped Phase 2. The fix needed to move the enforcement from the instruction layer
to the structural layer. The schema targets the output; the hook targets the execution
moment. Neither alone is sufficient: schema without hook still allows skipping; hook
without schema makes the compliance invisible in the output.

## Alternatives Considered
- **Better instructions** — already proven ineffective; rejected.
- **Hook only** — enforces execution but makes failures invisible in output; rejected alone.
- **Schema only** — makes failures visible but doesn't catch them at the moment of stopping; rejected alone.
- **Remove ~/canon/ filesystem access** — breaks the legitimate MCP-null fallback path; rejected.

## Consequences
- All proposals now require a visible Phase 1 / Phase 2 header.
- The Stop hook fires on every response — Claude must acknowledge it's not applicable
  for non-proposal responses, which is low overhead.
- If the schema fields are filled in but Phase 2 results aren't actually integrated,
  the Critic's concern applies: enforcement solved execution, not comprehension. That
  failure mode will require a different intervention if observed.
- This is the first time a Claude Code hook has been used in Prismo — expand the
  pattern if it proves effective.
