# Lifecycle Semantics

Defines the valid states for canon objects and the rules governing transitions between them. The purpose is to prevent canon entropy — the accumulation of outdated, ambiguous, or never-resolved content that pollutes retrieval.

The key insight: the problem is not having the right states. It is enforcing transitions. These rules give Sukuna v2 and the doctrine-service the criteria to detect when transitions are needed.

---

## States

### active

The object is operationally authoritative. Retrieval systems prioritize active objects. Decisions are in force. Proposals are being acted on. Projects are current.

**Entry:** explicit adoption after human review
**Retrieval priority:** highest

---

### proposed

An idea or direction under consideration. Not yet acted on. Not yet rejected.

**Entry:** creation of a new proposal
**Stale rule:** if a proposal has been `proposed` for more than 90 days with no updates, Sukuna flags it for review
**Retrieval priority:** medium — surfaced when querying for open work, not for doctrine

---

### experimental

Actively being evaluated. Something is being tried. Different from `proposed` in that work is actually happening; different from `active` in that it has not been formally adopted.

**Entry:** explicit decision to try something
**Exit:** either adopted (→ `active`) or reversed (→ `archived`)
**Stale rule:** if `experimental` for more than 60 days with no updates, Sukuna flags it
**Retrieval priority:** medium

---

### superseded

Replaced by a newer object. The object is no longer authoritative but is preserved for historical context and to understand the supersession chain.

**Entry:** when a newer decision explicitly names this one in its `supersedes` field
**Required:** `superseded_by` field must point to the replacement
**Retrieval priority:** low — only surfaced when explicitly traversing history or supersession chains

---

### archived

No longer operationally relevant. Not superseded by anything specific — just no longer applicable (e.g., deferred indefinitely, environment changed, project ended).

**Entry:** explicit decision to archive; or Sukuna recommendation accepted by human
**Retrieval priority:** none by default — excluded from standard retrieval, available by explicit query

---

### closed

Specific to proposals. The proposal was evaluated and a decision was made: either implemented (and a decision record was created), superseded, or deliberately not pursued.

**Entry:** proposal resolved — always requires a close note explaining outcome
**Retrieval priority:** none — excluded from standard retrieval

---

## Transition Rules

```
proposed    → experimental  (decision to try it)
proposed    → active        (decision to adopt without experiment)
proposed    → superseded    (newer proposal replaces it)
proposed    → closed        (evaluated, not pursued)
proposed    → archived      (abandoned without decision)

experimental → active       (adopted after evaluation)
experimental → archived     (reversed after evaluation)

active      → superseded    (replaced by newer decision)
active      → archived      (no longer applicable)

superseded  → (terminal — no further transitions)
archived    → (terminal — no further transitions)
closed      → (terminal — no further transitions)
```

**No backward transitions.** Once archived, superseded, or closed, an object stays there. If the situation changes, create a new object.

---

## Staleness Detection Rules

These are the criteria Sukuna v2 and the doctrine-service use to flag objects for human review.

| State | Staleness Trigger |
|-------|------------------|
| proposed | No activity for 90 days |
| experimental | No activity for 60 days |
| active (decision) | Referenced system no longer exists; or contradicts a newer active decision |
| active (proposal) | No activity for 30 days |
| superseded | Missing `superseded_by` pointer |

**Stale ≠ archived.** Sukuna flags; human decides.

---

## Supersession Chain Requirements

When a decision supersedes another:

1. New decision must list `supersedes: "<id>"` in frontmatter
2. Old decision must be updated: `superseded_by: "<id>"` and `status: superseded`
3. Both records are preserved — the chain is navigable
4. Sukuna v2 validates chain integrity on every run

Example chain: `009 → 011 → 012` (each supersedes the previous; all preserved)

---

## Lifecycle and Retrieval

The retrieval system in V2 uses lifecycle state as a first-class filter.

Default retrieval behavior:
- **Include:** active, proposed, experimental
- **Exclude by default:** superseded, archived, closed
- **Explicit include available:** for history traversal, onboarding generation, and contradiction detection

This prevents retrieval pollution from stale content — one of the core failure modes of V1.
