# Proposed Idea 002 — Migrate from GitHub to Gitea

## Status
Proposed — conditions not yet met

## Background
Decision 005 chose GitHub as the canonical remote because Gitea would share the same failure
domain as the rest of the homelab — a single machine with no redundancy. GitHub provides
off-site durability in the interim.

## The Plan
Once the homelab is stable and has some redundancy, migrate to a self-hosted Gitea instance
with a GitHub push mirror. Gitea becomes primary; GitHub is the fallback.

This keeps off-site durability while making Gitea the canonical remote.

## Conditions for Moving Forward
- Homelab has demonstrated sustained stability
- Some redundancy strategy is in place (second machine, offsite backup, or similar)
- Gitea running as a Docker container on the Ubuntu VM (or a dedicated LXC)

## Open
- Where does Gitea run — VM Docker container or Proxmox LXC?
- How is the GitHub push mirror configured and verified?
- Does anything else depend on the GitHub remote URL that would need updating?
