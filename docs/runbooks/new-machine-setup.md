# Runbook — New Machine Setup (Prismo)

> **Note:** This runbook is for the rare case of a remote developer working from their
> local machine. The primary onboarding path is SSH access to the VM — see
> `add-vm-user.md` instead.

Steps to configure a new **local machine** to connect to Prismo remotely via Claude Code.

## Prerequisites

- Claude Code installed
- Tailscale connected with access to `ubuntu-server.tail58b10c.ts.net`
- SSH access to the VM (for optional memory sync)

## Steps

### 1. Clone homelab

```bash
git clone git@github.com:EthanPlusPlus/homelab.git ~/canon/homelab
cd ~/canon/homelab && bash scripts/install-hooks.sh
```

### 2. Run the setup script

```bash
~/canon/homelab/scripts/prismo new-machine
```

The script will:
- Create `~/projects` and `~/canon`
- Offer to clone and configure each known code repo (sparse checkout, docs worktree, hooks)
- Register the MCP server for each directory
- Offer to copy memory from the VM

### 3. Verify

```bash
~/canon/homelab/scripts/prismo status
```

All hooks should be green and context-server reachable.

---

## Memory

Shared memory (system overview, workflow, MCP details, shorthands) lives in
`~/canon/homelab/docs/memory/` and is symlinked into your local Claude Code memory
directory by `prismo new-machine`. It updates automatically on `git pull`.

Personal memory (behavioral preferences, feedback) is synced optionally via scp
and stays local — it is never committed to the repo.

Memory is still scoped to the directory Claude Code is launched from.
**Always launch from `~/canon/homelab`** — that is the directory `prismo new-machine`
wires the symlinks for.

---

## Sparse checkout reference

If you need to add or update sparse checkout dirs manually for a code repo:

**context-server:**
```bash
git -C ~/projects/context-server sparse-checkout set api chroma_store context_mcp indexers
```

---

## Adding a new repo later

Run `prismo new-machine` again — it skips anything already set up and only
handles what's missing. Or run `prismo new-project <name> <url>` for a repo
that wasn't part of the original setup.
