---
id: "015"
status: active
record_type: canonical
category: architecture
---
# Decision 015 — Synthesis provider abstraction (Layer 2 / Layer 3 boundary)

## Status
Adopted

## Date
2026-05-16

## Context

The operational brief engine (Phase 2) needs to generate prose from a structured ContextBundle.
Prose generation requires a language model. context-server is a Layer 2 service. Layer 2 must
not depend on a specific model provider — that's a Layer 3 concern per the masterplan.

The implementation chose a `SynthesisProvider` Protocol abstraction, mirroring the existing
`EmbeddingProvider` pattern: context-server depends on a capability interface, the concrete
provider is selected at runtime via env var. The `AnthropicSynthesisProvider` and a stub
`LocalSynthesisProvider` are the initial implementations.

Sukuna 2026-05-15 flagged that this choice has no decision record, and additionally questioned
whether `SynthesisProvider` and `EmbeddingProvider` should be unified into a single
`RuntimeProvider` (Roadmap Initiative 3.1).

## Decision

Adopt `SynthesisProvider` as a separate Protocol abstraction for now.

### Interface

```python
class SynthesisProvider(Protocol):
    def synthesize(self, task: str, context: str, max_tokens: int = 500) -> str: ...
```

### Selection

`SYNTHESIS_PROVIDER` env var. `SYNTHESIS_MODEL` env var for the underlying model name.
Default: `anthropic` / `claude-haiku-4-5-20251001`. See [[023-synthesis-interpretive-augmentation|Decision 023]] for the two-tier model discipline — operational synthesis uses Haiku (`SYNTHESIS_MODEL`); interpretive augmentation uses Sonnet (`ANALYSIS_MODEL`). The `SynthesisProvider.synthesize()` interface covers Class 1 only; Class 2 tool-use + multi-turn loop is a separate contract.

### Boundary

context-server (Layer 2) calls `get_synthesis_provider().synthesize(...)`. context-server
never imports `anthropic` directly. The provider package (`runtime/`) is the only place
provider SDKs are imported.

### Sibling pattern

This mirrors `EmbeddingProvider` exactly. Both abstractions live in their own modules; both
are selected by env var; both are accessed via factory functions. The Layer 2 / Layer 3
boundary is enforced consistently.

## Open question — unify with `RuntimeProvider`?

V2 Roadmap Initiative 3.1 describes a single `RuntimeProvider` interface exposing
`query / stream / embed / toolCall / summarize`. Both `SynthesisProvider` and `EmbeddingProvider`
fit under that umbrella.

Sukuna 2026-05-15 argued the parallel-providers pattern is premature decomposition and that
both should collapse into one `RuntimeProvider` registry.

This decision defers that question. Two parallel Protocols are easy to maintain at current
scale, and unifying prematurely risks a misshaped abstraction. The unification is a Phase 4
(Runtime Abstraction System) concern, not a Phase 2 concern. When Phase 4 starts, a new
decision will either keep them separate or fold them into `RuntimeProvider`.

## Consequences

- `runtime/` is the canonical home for provider implementations.
- New synthesis-consuming features (Phase 3 synthesis-service, contribution capture, etc.)
  consume the `SynthesisProvider` capability, not the Anthropic SDK directly.
- Local inference support (Phase 4) becomes a `LocalSynthesisProvider` implementation —
  no Layer 2 changes required.
- The decision to unify with `EmbeddingProvider` under `RuntimeProvider` is explicitly deferred
  to Phase 4.
