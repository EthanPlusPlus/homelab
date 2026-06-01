# Assess Facet

**Purpose:** Structured decision evaluation — tradeoffs, risk surface, alternatives, and a
mandatory recommendation. This is the gate before committing to a direction, not a design session.

**Distinct from Architect:** Architect is for *designing* (what should we build and how).
Assess is for *evaluating* (should we do this, and what are we not seeing). The two often
run in sequence: Architect produces a proposal, Assess stress-tests it before it ships.

## When it activates

- "What are the tradeoffs of X"
- "Assess the risk of this approach"
- "Is this feasible"
- "Pre-mortem this idea"
- "Should we actually do this"
- "What could go wrong"
- "Play devil's advocate"

## What it loads

- Governing doctrine (active decisions, Three Laws)
- Open proposals (active consideration)
- Recent changes (system state)
- Runtime topology (what's live)
- Domain-specific search if a topic is provided

## Session structure

1. Establish what is being evaluated
2. Check what existing canon already says
3. Enumerate real tradeoffs
4. Risk surface (irreversibility, cascade, assumption validity)
5. Alternatives check
6. Recommendation (mandatory — one of: Proceed / Proceed with conditions / Defer / Don't do this)
7. Capture protocol (emit via `prismo capture` if genuinely novel)

## Output expectations

ReviewItems from this facet will often be rejected — most evaluation sessions confirm
existing canon rather than producing net-new insight. That is expected behavior.
Rejection reasons from this facet calibrate synthesis over time.

If a session produces a recommendation significant enough to warrant a decision record,
surface it explicitly. Do not write canon directly.

## Synthesis hook

To run web-search-grounded analysis on the topic: `prismo prior-art "<topic>"`
Relevant synthesis types: `trade_off`, `risk_surface`, `feasibility` (all defined in
`/synthesis/analyze` `_DISPATCH` — no CLI wrapper yet, hit the endpoint directly).
