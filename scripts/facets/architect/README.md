# Architect Facet

**Purpose:** Shift into architectural reasoning grounded in Prismo's current system
reality — not generic software engineering principles.

**Activation:** `/architect [optional: specific area]`
Or automatic when a message is classified as architectural (see activation hints in
`facet.yaml`).

---

## What It Does

When activated, the Architect Facet pre-assembles context before the model's reasoning
turn begins. The pipeline service executes these loaders in order:

| Loader | What it fetches | Why |
|--------|----------------|-----|
| `architectural_laws` | Decision 017 full text | Non-negotiable constraints — the Three Laws govern all architectural reasoning |
| `governing_doctrine` | Top 10 active decisions | The current constraint set. Proposals must be consistent with these. |
| `recent_changes` | `context/recent-changes.md` | What shifted recently that might be relevant to the discussion |
| `open_proposals` | Top 5 proposed-ideas | What is actively being considered — avoids re-proposing open work |
| `topology` | `GET /runtime/topology` | Authority boundaries, execution modes, current intelligence roles |
| `domain_specific` | Semantic search on `$ARGS` | If you typed `/architect synthesis layer`, pulls decisions specific to that area |

The model sees this bundle before it starts reasoning. It does not fetch during its turn.

---

## Reasoning Posture

The Architect Facet changes *how* the model reasons, not just what it knows.

**You are not a generic architect.** The loaded doctrine is your constraint set — not
a reference, not inspiration. A proposal that violates Law 3 is wrong regardless of how
elegant it is. A pattern that introduces Claude-coupling is wrong regardless of how
convenient it is today.

**Before proposing anything:**
- Which existing decision does this touch or extend?
- Does it respect the layer it belongs to? (Layers are governance tiers — ownership
  and authority — not pipeline stages)
- Does it introduce Claude-coupling that violates Law 3?
- Is there a simpler composition of what already exists?

**When evaluating proposals:**
- Measurement or judgment? (Law 1 vs Law 2 — determines which layer it belongs to)
- What does it compose from vs introduce net-new?
- What breaks if the underlying model changes?

**When you spot a tension:**
- Name it before proposing resolution
- Surface as a capture if it's not already a ReviewItem

---

## When to Use It

**Use `/architect` when:**
- Designing a new service, module, or layer
- Evaluating whether a proposal fits the existing architecture
- Deciding where a capability belongs (Layer 1? 2? 3? 3.5?)
- Noticing something feels wrong architecturally but can't articulate why
- Reading or writing a decision record

**Don't expect it when:**
- Asking factual questions about system state (use the MCP directly)
- Debugging code (use normal sessions)
- Reviewing a PR for bugs (use `/code-review`)

---

## Files

| File | Purpose |
|------|---------|
| `facet.yaml` | Machine-readable definition — activation hints, context loaders, heuristics. This is what the pipeline assembler executes. |
| `SKILL.md` | Claude Code thin adapter — registers the `/architect` skill, references the pre-assembled context block, provides fallback if context-server is unreachable. |
| `README.md` | This file — human-readable design intent. |

---

## Extending This Facet

To add a new context loader, edit `facet.yaml` and add an entry to `context_loaders`.
Supported types: `doc_fetch`, `search`, `recent_changes`, `runtime_topology`,
`conditional_search`. See `pipeline/assembler.py` for the full dispatch table.

To adjust activation sensitivity, tune `threshold` in `facet.yaml`. Lower = activates
on more messages. 0.72 is the current value — calibrated to avoid firing on non-design
conversations while catching obvious architectural discussions.

To add activation examples that improve automatic detection, add entries to
`activation.examples`. Include descriptive forms ("tell me about the architecture")
not just imperative ones ("let's redesign the system").
