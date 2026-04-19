# Runbook — New Machine Setup (Prismo)

Steps to configure a new machine to work on Prismo via Claude Code.

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

## Memory gotcha

Memory is scoped to the directory Claude Code is launched from. Launching from
`~/canon/homelab` vs `~/projects/context-server` gives a different (or empty)
memory context — with no warning.

**Always launch Claude Code from the same root directory on every machine.**
The recommended launch directory is `~/canon/homelab`.

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
