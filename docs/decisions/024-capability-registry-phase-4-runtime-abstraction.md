---
id: "024"
title: CapabilityRegistry — Phase 4 runtime abstraction
status: active
record_type: canonical
date: 2026-05-26
---

# Decision 024 — CapabilityRegistry: Phase 4 runtime abstraction

## Status
Adopted

## Date
2026-05-26

## Context

Decision 015 deferred the open question: should `SynthesisProvider` and `EmbeddingProvider`
be unified into a single `RuntimeProvider` (per Roadmap Initiative 3.1), or kept as separate
Protocols?

Phase 4 starts now. The deferral expires.

The forcing insight from 2026-05-26: **model swappability is the core architectural property
of Prismo V2, not a Phase 4 nice-to-have.** A feature that only works with one provider is
incomplete. The abstraction only exists if it holds across a second real runtime. Until a second
runtime is built and proved, the provider interfaces are theoretical.

The roadmap defines V2 as "a persistent organizational cognition substrate with interchangeable
AI runtimes." That is not aspirational. It is the completion criteria.

## Decision

### Do not create a monolithic `RuntimeProvider`

The roadmap sketches a single `RuntimeProvider` with `query / stream / embed / toolCall /
summarize`. This would force embedding and language generation — fundamentally different
compute profiles, latency characteristics, and provider markets — to be implemented by the
same class. That is the wrong abstraction.

### Create a `CapabilityRegistry`

A registry that maps capability name → provider instance. Each capability has its own
interface. The registry routes, dispatches, and manages provider lifecycle.

```python
registry = CapabilityRegistry()
registry.get("synthesize")   # → SynthesisProvider
registry.get("embed")        # → EmbeddingProvider
registry.get("analyze")      # → AnalysisProvider (future — Class 2 synthesis)
```

The registry is the stable boundary. Capabilities behind it are independently swappable.
New capabilities (query, plan, codegen) register against the same registry without touching
callers.

### Build `ClaudeCodeSynthesisProvider` as the second runtime

The second runtime proves the abstraction. `ClaudeCodeSynthesisProvider` implements
`SynthesisProvider` using `claude -p` (Claude Code non-interactive mode) rather than the
Anthropic API directly.

Consequences:
- Uses the Claude Code subscription, not API credits, for synthesis calls
- Web search works (Claude Code has it built in)
- Same interface as `AnthropicSynthesisProvider` — callers are unchanged
- Selected via `SYNTHESIS_PROVIDER=claude-code`

If synthesis works identically through both providers, the abstraction is real.
If it breaks, there is a hidden coupling to fix before further Phase 4 work.

### Scope boundary — Class 2 synthesis stays direct

`synthesis/analyze.py` (prior-art, trade-off, feasibility analysis) uses the Anthropic SDK
directly for multi-turn tool-use loops. This is a different contract: not `synthesize()` but
a structured `analyze()` capability with tool invocation. Wrapping it behind a provider
interface is Phase 4 follow-on work, not this decision. The `AnalysisProvider` Protocol is
declared here as a named future extension point but not implemented.

## Rationale

**Why CapabilityRegistry over RuntimeProvider.** Embedding and synthesis have different
scaling profiles, cost structures, latency requirements, and provider markets. A single
`RuntimeProvider` that must implement `embed` + `synthesize` + `toolCall` would either
be an anemic interface (lowest common denominator across all providers) or require providers
to stub methods they don't support. The registry pattern avoids this — each capability is
independently swappable, and a provider only needs to implement the capabilities it covers.

**Why ClaudeCodeSynthesisProvider first.** It is the fastest path to a second real runtime:
`claude` is already installed and authenticated on the VM, no new infrastructure required.
It also directly addresses the billing surprise from 2026-05-25 — synthesis calls routing
through the subscription instead of API credits. Local inference (Ollama) is the third
runtime and completes the provider triangle (API → CLI → local).

**Why model swappability is completion criteria.** Prismo V1's failure mode was solving for
current constraints (small context windows, frugal prompts). V2's architecture is explicitly
abundance-oriented (masterplan Section 1.2: "Loose coupling everywhere. No model is permanent.")
A feature that breaks on provider swap was never complete. The CapabilityRegistry enforces
this as infrastructure, not discipline.

## Capability contract surface

```python
# Existing (unchanged interfaces)
class SynthesisProvider(Protocol):
    def synthesize(self, task: str, context: str, max_tokens: int = 500) -> str: ...

class EmbeddingProvider(Protocol):
    def encode(self, text: str) -> list[float]: ...
    def encode_batch(self, texts: list[str]) -> list[list[float]]: ...

# New runtime module
class CapabilityRegistry:
    def register(self, capability: str, provider: object) -> None: ...
    def get(self, capability: str) -> object: ...

# Declared future extension point (not implemented this decision)
class AnalysisProvider(Protocol):
    def analyze(self, topic: str, analysis_type: str, context: str) -> dict: ...
```

## Consequences

- `runtime/registry.py` ships as the new central dispatch layer.
- `runtime/claude_code_provider.py` ships as the second `SynthesisProvider` implementation.
- `SYNTHESIS_PROVIDER=claude-code` selects it. No other env vars or code changes needed for callers.
- `get_synthesis_provider()` and `get_embedding_provider()` factory functions remain as
  convenience accessors; internally they delegate to the registry.
- Local inference (Ollama) is the next `SynthesisProvider` implementation — Phase 4 follow-on.
- `AnalysisProvider` wrapping `analyze.py` is Phase 4 follow-on.
- Every new capability added to Prismo must register against the `CapabilityRegistry` and
  have at least two provider implementations before the capability is considered complete.
  This is the enforcement mechanism for the model-swappability completion criterion.

## Related
- [[015-synthesis-provider-abstraction]] — open question this decision resolves
- [[017-three-architectural-laws]] — Law 3: capability contracts are primary
- [[020-doctrine-service-structural-coherence-engine]] — precedent: module-first before process split
- [[023-synthesis-interpretive-augmentation]] — Class 2 synthesis scope boundary
