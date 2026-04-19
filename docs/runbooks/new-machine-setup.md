# Runbook — New Machine Setup (Prismo)

Steps to configure a new machine to work on Prismo via Claude Code.

## Prerequisites

- Claude Code installed
- Tailscale connected with access to `ubuntu-server.tail58b10c.ts.net`

## Steps

### 1. Create the directory structure

```bash
mkdir ~/projects
mkdir ~/canon
```

### 2. Clone and set up homelab (knowledge base)

```bash
git clone git@github.com:EthanPlusPlus/homelab.git ~/canon/homelab
cd ~/canon/homelab && bash scripts/install-hooks.sh
```

### 3. Clone code repos (sparse — no docs/)

For each code repo:

```bash
git clone <repo-url> ~/projects/<repo-name>
cd ~/projects/<repo-name>

# Exclude docs/ from the working tree
git sparse-checkout init --cone
git sparse-checkout set <dir1> <dir2> ...   # list all dirs except docs/

# Install the code re-index hook
bash scripts/install-hooks.sh
```

Current code repos and their directories to include (omitting docs/):

**context-server:**
```bash
git sparse-checkout set api chroma_store context_mcp indexers
```

### 4. Create docs worktrees in ~/canon/

For each code repo that has docs:

```bash
cd ~/projects/context-server

# Enable per-worktree config
git config extensions.worktreeConfig true

# Create the docs worktree
git worktree add ~/canon/context-server

# Scope the worktree to docs/ only
cd ~/canon/context-server
git sparse-checkout init --cone
git sparse-checkout set docs

# Install a worktree-specific hook (calls /index, not /index/code)
WORKTREE_GIT_DIR="/home/ethan/projects/context-server/.git/worktrees/context-server"
mkdir -p "$WORKTREE_GIT_DIR/hooks"
cat > "$WORKTREE_GIT_DIR/hooks/post-merge" << 'EOF'
#!/bin/bash
curl -s -X POST http://localhost:8000/index
EOF
chmod +x "$WORKTREE_GIT_DIR/hooks/post-merge"
git config --worktree core.hooksPath "$WORKTREE_GIT_DIR/hooks"
```

Each repo has a `CLAUDE.md` at its root that bootstraps Claude Code sessions
automatically — no additional context setup required.

### 5. Add the MCP server

Run from inside the repo directory you'll be working in:

    claude mcp add context-server --transport http \
      http://ubuntu-server.tail58b10c.ts.net:8001/mcp

Verify: `claude mcp list`

### 6. Copy the memory directory (optional — personal memory only)

The memory directory holds personal behavioral preferences and session feedback.
It is not required to work on Prismo, but restores continuity across machines.

Find your local memory path — it is derived from the directory Claude Code is
launched from:

    # macOS example, launching from ~/projects/homelab:
    ~/.claude/projects/-Users-<username>-projects-homelab/memory/

> **Gotcha:** Memory is scoped to the directory Claude Code is launched from. If
> you launch from `~/canon/homelab` vs `~/projects/context-server`, you get
> different (or empty) memory with no warning. Always launch from the same root
> directory on each machine, or memory will be silently absent.

Copy from a machine that already has it:

    scp -r <user>@ubuntu-server.tail58b10c.ts.net:~/.claude/projects/<source-path>/memory/ \
      ~/.claude/projects/<local-path>/memory/

This is an accepted manual step with no automation.

## Notes

- The MCP server requires Tailscale to be active.
- Re-run the MCP add command for each new repo you work in.
