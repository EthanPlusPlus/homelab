---
id: "006"
title: Mobile Gateway to Prismo
status: proposed
notes: direction resolved by Decision 021 — all Layer 4 surfaces are thin ReviewItem renderers; open question is build sequencing only
---

# 006 — Mobile Gateway to Prismo

## Status

Proposed — direction resolved by [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]]: mobile is a thin ReviewItem renderer (list/show/approve/reject), same contract as `prismo review` CLI. Open question is build sequencing only (CLI ships first per Decision 021).

## The Idea

A way to interact with Prismo from a phone — triggering tasks, querying knowledge,
adding ideas to canon — without needing to be at a computer.

## Leading Candidate

Claude Dispatch (part of Claude Cowork, early research preview as of 2026-03-17)
could act as the mobile entry point. You text a task from your phone; something
on the Mac side executes it with access to Prismo's context.

Reliability is currently ~50% on complex tasks. Worth revisiting as the product matures.

## Open Questions

- Is Claude Dispatch the right gateway, or is there a simpler/more reliable path?
- What categories of tasks make sense to trigger from mobile? (Querying? Light writes? Full execution?)
- How much of the Prismo workflow can realistically run without a human in the loop?

## Why It Matters

Prismo is currently desktop-only. A mobile gateway would close the gap between
having an idea on the go and getting it into canon before it's lost.
