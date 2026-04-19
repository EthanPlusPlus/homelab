# Recent Changes

Rolling log of meaningful system changes. Keep last ~10 entries. One to three lines each.
Oldest entries are removed as new ones are added.

---

- **Shared memory implemented (decision 010)** — `~/canon/homelab/docs/memory/` added with system.md, workflow.md, mcp.md, shorthands.md; symlinked into each machine's Claude Code memory dir by `prismo new-machine`; personal MEMORY.md pruned to index only; proposed-idea 004 superseded; STRUCTURE.md updated
- **proposed-idea 006: mobile gateway** — concept captured; Claude Dispatch as leading candidate but approach not decided
- **`prismo` CLI script implemented** — `scripts/prismo` in homelab repo; `new-machine`, `new-project`, `index`, `status` subcommands; new-machine-setup.md simplified to 2 commands; 005 marked implemented
- **Workflow audit — onboarding and new-project gaps closed** — new-machine-setup.md step numbering bug fixed; memory path gotcha documented (CWD-scoped, silent on mismatch); new-project.md runbook written (full sparse-checkout + worktree + hook + indexing flow); proposed-ideas 004 (git-backed memory) and 005 (prismo CLI) added
- **Canon distilled into `proposed-ideas/`** — open-questions cleaned up (3 resolved items struck through, gitea/embedding model moved to proposed-ideas); context-server Next items migrated to proposed-ideas/; both STRUCTURE.md files updated; 5 proposed-ideas entries total across homelab and context-server
- **`proposed-ideas/` folder added to doc structure** — new layer between open-questions and decisions; for ideas with some reasoning but not yet adopted or fully unpacked; first entry: subagent usage in Prismo
- **MCP dual-query discipline established** — constraint added: query MCP before reasoning (educate) and after forming a solution (validate conflicts/duplication) for every thought; session caching and ~/canon/ fallback documented; fuzziness around null-result handling noted as open question
- **~/canon/ introduced — code/knowledge separation** — docs removed from code working trees via sparse-checkout; all knowledge (homelab, context-server docs, exam-prep) now lives in ~/canon/; context-server indexes from CANON_PATH=/canon; doc_type names unchanged (homelab, context-server); enforces motto: Claude reasons via MCP, not filesystem scans
- **context-server/docs/ established** — context-server decisions and context split out; each project repo is now self-contained
- **Session bootstrapping established** — CLAUDE.md added to homelab and context-server repos; Prismo system overview added to architecture/; new-machine-setup runbook added
- **Git hooks implemented** — post-merge hooks added to homelab, context-server, and devcamp repos; auto re-indexing fires on git pull in each repo
- **Claude Code installed on VM** — accessible via Tailscale; connected to context-server MCP on port 8001
- **iptables rules persisted** — homelab NAT rule now survives reboots via iptables-persistent on Ubuntu VM
- **ip_forward persisted on Proxmox host** — added net.ipv4.ip_forward=1 to /etc/sysctl.conf
- **VM logical volume expanded** — 15GB → 30GB via LVM
