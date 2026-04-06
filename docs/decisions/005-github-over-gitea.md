# Decision 005 — GitHub over Gitea (for now)

## Status
Decided

## Context
Needed a remote home for the homelab documentation repo. Gitea (self-hosted) was the natural long-term choice, but the homelab currently runs on a single machine with no redundancy.

## Decision
Use a GitHub private repo as the canonical remote for now.

## Reason
Gitea would run on the same physical machine as everything else — it would share the same failure domain. If the machine goes down, the git remote goes down with it, which defeats the point of having a remote at all. GitHub provides off-site durability without any additional infrastructure.

## Future
Migrate to a self-hosted Gitea instance with a GitHub push mirror once the homelab is stable and has redundancy. This keeps a public fallback while making Gitea the primary.
