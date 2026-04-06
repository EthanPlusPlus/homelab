# Decision 004 — Pi-hole deferred

## Status
Deferred

## Context
Pi-hole was planned as a Proxmox LXC container for network-wide DNS filtering and ad blocking.

## Decision
Deprioritised indefinitely. DNS is critical infrastructure — if Pi-hole becomes unstable on a single-machine homelab with no redundancy, it can break all network access.

## Conditions for revisiting
- Homelab has demonstrated stability over time
- OR a redundancy strategy is in place (e.g. fallback DNS configured on router)
- AND AI layer goals are already established
