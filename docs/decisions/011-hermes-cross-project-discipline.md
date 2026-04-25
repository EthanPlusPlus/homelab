# Decision 011 — Hermes: triggered cross-project canon discipline

## Status
Superseded by Decision 012

## Supersedes
Decision 009 — Structural enforcement of the two-phase MCP query discipline

## Context

Decision 009 established structural enforcement of the two-phase discipline via a mandatory
proposal template header (Layer 1) and a Stop hook (Layer 2). In practice:

- Phase 1 was still skipped — "every thought" uniform friction decayed into no coverage.
- Phase 2 was unenforceable as a self-check: "run MCP against your solution" left no
  auditable trace. Claude could acknowledge the rule and skip it in the same turn.
- The proposal template (Layer 1) was fillable without actually running Phase 2 — schema
  compliance was decoupled from behavioral compliance.

Two design changes were needed: (1) explicit triggers instead of always-on, (2) Phase 2 as
a subagent dispatch rather than a self-check.

## Decision

### Triggers (replaces "every thought")

Engage the discipline only when about to:
- Surface a proposal, plan, recommendation, or decision to Ethan
- Write or modify canon
- Change architecture or service config

Skip for: clarifying questions, code reads, tool discovery, factual lookups about system state.

### Phase 1 — Saturate (main agent)

Query the context-server MCP with `doc_type=<project-name>` to scope results by project.
Search the topic and adjacent areas before forming a view. Reuse session context if already
fetched. If MCP returns empty but canon should plausibly exist (topic in-scope, decision-type,
adjacent hits, system state implies prior decision), fall back to reading
`~/canon/<project-name>/` directly.

### Phase 2 — Hermes adversarial review (replaces self-check)

Before surfacing, dispatch the `hermes` subagent with:
- **Proposal** — full text
- **Project name** — the MCP `doc_type` (e.g., `homelab`, `context-server`)
- **Canon path** — `~/canon/<project-name>/`

Hermes is adversarial: it queries canon against the proposal and returns findings in four
structured buckets:
1. Direct conflicts with existing canon
2. Duplication of already-resolved questions
3. Assumptions the proposal makes that canon contradicts
4. Canon gaps the proposal would fill

Main Claude surfaces Hermes' full output to Ethan before committing to a position. The tool
call is the evidence. A self-reported check does not count. If the proposal is revised after
review, Hermes must be re-dispatched on the revision.

### Structural enforcement layers

**Layer 1 (schema visibility) — retired:** The mandatory proposal template header from
Decision 009 is replaced. Hermes' structured four-bucket output surfaced in full is the new
visibility mechanism. Tradeoff: the old header was always visible in the response body even
if Phase 2 was skipped; the new design has no in-response fallback if Hermes is skipped.
This is accepted because the Hermes dispatch creates a harder gate — the tool call either
happened (with logged output) or it didn't. Unlike a header, the call cannot be filled in
without actually running Phase 2.

**Layer 2 (Stop hook) — updated:** The Stop hook in `~/.claude/settings.json` is retained
and updated to check for Hermes dispatch (previously checked for MCP Phase 2 queries).
Fires on every response as a last-chance detection gate.

**Layer 3 (UserPromptSubmit hook) — new:** A UserPromptSubmit hook in
`~/.claude/settings.json` injects a per-turn discipline reminder on every user prompt.
Preventative: fires before reasoning begins.

### Cross-project scope

This discipline applies to any project with a canon at `~/canon/<project-name>/`. Decision
011, adopted in the homelab canon, carries system-level authority for cross-project
behavioral conventions — the same basis on which `docs/STRUCTURE.md` is "authoritative
across projects" for documentation structure.

Each project's context-server MCP index is keyed by project name (`doc_type`). No
per-project declaration is needed; the filesystem convention (`~/canon/<name>/`) and MCP
`doc_type` naming are the declaration layer. New projects are added by creating the
directory and re-indexing.

### Hermes: canonical description

Hermes lives at `~/.claude/agents/hermes.md` (per-machine; not in canon). This decision
record preserves the input/output contract so new machines can reconstruct the agent:

- **Input:** proposal (full text) + project name (doc_type) + canon path
- **Method:** Step 1 — query MCP with doc_type scoping; Step 2 — fallback to direct
  `~/canon/` reads if MCP returns nothing; Step 3 — compare proposal across four axes
- **Output:** four-bucket structured report (conflicts, duplication, contradicted
  assumptions, canon gaps) or "None." per bucket
- **Scope:** adversarial only — does not suggest revisions, does not comment on code
  quality or security, does not dispatch further subagents, does not modify files

## Rationale

**Why Hermes dispatch is more reliable than old Phase 2 MCP instruction:** The old Phase 2
was a mental step — "run MCP against your solution" — with no externalized output and no
fixed format. A Hermes dispatch is a tool call that either appears in the transcript or
doesn't. The output is structured and auditable. The subagent starts cold with no prior
commitment to the proposal passing. This is structurally harder to skip than an internal
query, even if the decision to dispatch is still instruction-driven.

**Why trigger fuzziness is acceptable:** "Every thought" eliminated judgment calls but
decayed into no coverage. The trigger list introduces some judgment about whether a given
response qualifies as a "proposal" or "recommendation," but the UserPromptSubmit + Stop
hooks provide per-turn safety nets. Ambiguous cases default to dispatching: the cost of an
unnecessary Hermes call is low; the cost of a missed canon conflict is high.

**Proposed-idea 001 (Pattern 3) resolved:** Pattern 3 (plan validation subagent) was
tentatively rejected for adding opacity. The Hermes design addresses this: output is
structured and surfaced in full before Claude commits to a position; findings are not
silently applied. Pattern 3 is resolved as adopted via this decision.

**Proposed-idea 008 (Validator) partially resolved:** The Validator agent described in
008's Structured Decision Pipeline is instantiated by Hermes. The broader pipeline
(Proposer, Devil's Advocate, Scribe) and Persistent Observing Agents remain proposed.

## Open Risks

**Custom subagent dispatch (unresolved):** The Agent tool's `subagent_type` parameter did
not dispatch `hermes` correctly in the session where this decision was adopted —
"Agent type 'hermes' not found" was returned despite the agent being defined in
`~/.claude/agents/hermes.md`. Most likely cause: custom agents written mid-session require
a fresh session to be dispatchable. Until confirmed, Phase 2 falls back to dispatching a
`general-purpose` agent briefed with Hermes' full system prompt and inputs. The four-bucket
output contract and "tool call is the evidence" rule still apply regardless of which agent
type satisfies the dispatch.

## Alternatives Considered

- **Hermes suggests revisions:** Rejected — if Hermes proposes a fix and main Claude
  applies it silently, the adversarial gate becomes a rubber stamp.
- **Better instructions alone:** Rejected — proven ineffective, per Decision 009's context.
- **"Every thought" retained:** Rejected — uniform friction decayed into no coverage;
  targeted triggers are less complete but actually enforced.

## Consequences

- All projects with `~/canon/<project>/` fall under this discipline.
- `context/constraints.md` updated: discipline section replaced.
- `proposed-ideas/001-subagent-usage.md` annotated: Pattern 3 resolved as adopted.
- `proposed-ideas/008-agentic-decision-pipeline.md` annotated: Validator instantiated.
- Decision 009 status set to "Superseded by Decision 011."
- Per-machine assets not in canon: `~/.claude/agents/hermes.md`, `~/CLAUDE.md`,
  `~/.claude/settings.json` hooks. Distribution of these assets across machines is an
  open question not resolved by this decision.
