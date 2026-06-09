---
id: "035"
title: Harness Adapter Pattern — Layer 1 boundary for harness-specific coupling
status: active
record_type: canonical
category: architecture
date: 2026-06-07
supersedes: []
---

# Decision 035 — Harness Adapter Pattern

## Status

Active — Claude Code adapter exists (retroactively named). Agentic loop adapter
is the next harness (PI-006); it is the heaviest adapter against this interface —
multi-turn, session-aware, full pipeline integration. See PI-006 for scope.

**Annotation 2026-06-07:** The "conversational UI adapter" defined below is
correctly scoped for a thin UI making three API calls. The agentic loop
(PI-006) is a full harness — not a three-call adapter — that requires
conversation state management, per-turn activation routing, and per-response
processing. The normalised interface (three endpoints) still holds as the
contract; the adapter implementation is much heavier than originally implied.

**Annotation 2026-06-09:** The agentic loop harness is now fully designed —
Decisions 036 (role/contract/billing), 037 (conversation continuity), 038
(phase gate). PI-006 is promoted. The loop-server is a separate service; build
plan at `fergie/loop-build-plan.md`. A future OpenCode adapter (coding harness
replacement) was scoped during design: OpenCode exposes an HTTP API + lifecycle
events, so the adapter calls it from Python directly — sequenced after the loop
ships, tracked in fergie.

## Context

The masterplan (Decision 013) states: *"Layer 4 hides volatility (which model, which
version) while exposing continuity."* The roadmap states: *"Decouple organizational
cognition from model vendors."*

These principles were never operationalised into a concrete architectural pattern.
PI-010 (Interaction Observer) raised the open question — hooks vs transcript files —
but was superseded without resolution.

The conversational UI (Decision 032 step 5) is the forcing function. It is the first
non-Claude-Code entry point into Prismo's session lifecycle. Without a named pattern,
two incompatible coupling approaches accumulate. With a named pattern, the UI adapter
is trivially defined before a line of code is written.

## Findings (architect pass, 2026-06-07)

Reading `scripts/prismo` directly before deciding:

**Session identity is already Prismo-generated.** `session ensure` calls
`POST /workflow/session/start` and stores the returned Prismo UUID locally.
Claude Code's `session_id` from the hook JSON is read but never used as the
Prismo session identifier. This coupling point does not exist.

**`POST /pipeline/process-response` is already harness-agnostic.** It accepts
`{response, project}` — plain text. Any harness can call it directly.

**`session ensure` degrades gracefully.** The implementation explicitly falls back
to raw text input for non-Claude invocations (documented in the code comment).

**The only harness-specific code is `capture-response`** — approximately 20 lines of
Python inside one subcommand that reads the Claude Code Stop hook JSON, opens the
JSONL transcript at `transcript_path`, and parses `type == 'assistant'` entries to
extract the last assistant text block.

The system is more portable than the pre-decision discussion implied.

## Decision

### The normalised event interface

Three existing API endpoints constitute the harness-agnostic interface:

```
POST /workflow/session/start          session begins
POST /pipeline/process-response       response text to process  {response, project}
POST /workflow/session/:id/end        session closes
```

These endpoints are the contract. Harness adapters call them. Nothing above Layer 1
references harness-specific formats.

### Harness Adapter Pattern

A harness adapter is a Layer 1 artifact that maps harness-specific events to the
three normalised API calls above. Adapters live at Layer 1. No adapter code or
adapter framework lives above Layer 1.

**Constraint**: every harness adapter implements the same three calls. No adapter may
introduce additional session lifecycle endpoints or bypass the normalised interface.

### Claude Code adapter (existing — retroactively named)

```
UserPromptSubmit hook  →  prismo session ensure  →  POST /workflow/session/start
Stop hook              →  prismo pipeline capture-response
                           ↳ parse Stop hook JSON (Claude Code format)
                           ↳ open transcript_path JSONL (Claude Code format)
                           ↳ extract last assistant text block
                           →  POST /pipeline/process-response
```

`capture-response` is the Claude Code adapter. The JSONL parsing block within it
is the only harness-specific code in the system. It must be marked as Claude Code
specific in the source.

### Conversational UI adapter (to build)

The conversational UI has the response text at the point of rendering — no transcript
file, no JSONL parsing. The adapter is three direct HTTP calls:

```
User opens chat        →  POST /workflow/session/start        (store session_id)
Assistant responds     →  POST /pipeline/process-response     (text already available)
User closes / timeout  →  POST /workflow/session/:id/end
```

No adapter script required. The API client in the UI codebase implements these three
calls directly. This is the simplest possible adapter.

### Code change required (minimal)

Add two comments to `scripts/prismo`:

1. On the `capture-response` subcommand block:
   `# Claude Code adapter — Layer 1 (Decision 035)`

2. On the JSONL parsing block within `capture-response`:
   `# Claude Code JSONL transcript format`

No functional changes. The architecture is already correct; the pattern needed naming.

### Future harnesses

Any future harness (WhatsApp gateway, VS Code extension, another AI CLI) implements
the same three API calls. There is no adapter framework, no shared library, no base
class. The normalised interface is the contract; the adapter is whatever maps the
harness to those three calls.

## What does not change

- `pipeline/processor.py` — harness-agnostic already
- `workflow-state-service` — harness-agnostic already
- Session identity sourcing — Prismo-generated already
- ReviewItem contract and synthesis loop — unaffected
- The three normalised endpoint signatures — these are the stable contract

## Consequences

- `capture-response` is formally the Claude Code adapter. Any refactor of that
  subcommand must preserve the harness adapter boundary.
- The conversational UI does not need a `prismo` CLI dependency. It calls the API
  directly. This is correct — the CLI is a Claude Code harness artifact, not a
  universal Prismo client library.
- New harnesses are assessed by: do they implement the three normalised calls? If yes,
  they are first-class Prismo surfaces. If not, they are coupling violations.
- PI-010's open question (hooks vs transcript files) is answered: transcript files are
  Claude Code adapter internals, not a system-level concern.

## Related

- [[013-v2-masterplan-adopted|Decision 013]] — founding principle: Layer 4 hides
  harness volatility
- [[032-portability-as-commercial-grade-constraint|Decision 032]] — infrastructure
  portability; this decision extends it to harness portability
- [[026-layer-3-5-pipeline-service|Decision 026]] — the pipeline this adapter feeds
- [[028-response-processor-auto-capture|Decision 028]] — `capture-response` (Claude
  Code adapter) is the hook wiring for this decision
- [[../proposed-ideas/010-interaction-observer|PI-010]] — open question (hooks vs
  transcript) now answered
- [[../proposed-ideas/020-workstream-session-grouping|PI-020]] — workstreams group
  sessions across harness boundaries; harness_id on sessions would support this
