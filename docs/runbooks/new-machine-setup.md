# Runbook — New Machine Setup (Prismo)

Steps to configure a new machine to work on Prismo via Claude Code.

## Prerequisites

- Claude Code installed
- Tailscale connected with access to `ubuntu-server.tail58b10c.ts.net`

## Steps

### 1. Clone the relevant repos

Clone whichever repos you need to work on:

    git clone <repo-url> ~/projects/<repo-name>

Each repo has a `CLAUDE.md` at its root that bootstraps Claude Code sessions
automatically — no additional context setup required.

### 2. Add the MCP server

Run from inside the repo directory you'll be working in:

    claude mcp add context-server --transport http \
      http://ubuntu-server.tail58b10c.ts.net:8001/mcp

Verify: `claude mcp list`

### 3. Copy the memory directory (optional — personal memory only)

The memory directory holds personal behavioral preferences and session feedback.
It is not required to work on Prismo, but restores continuity across machines.

Find your local memory path — it is derived from the directory Claude Code is
launched from:

    # macOS example, launching from ~/projects/homelab:
    ~/.claude/projects/-Users-<username>-projects-homelab/memory/

Copy from a machine that already has it:

    scp -r <user>@ubuntu-server.tail58b10c.ts.net:~/.claude/projects/<source-path>/memory/ \
      ~/.claude/projects/<local-path>/memory/

This is an accepted manual step with no automation.

## Notes

- The MCP server requires Tailscale to be active.
- Re-run the MCP add command for each new repo you work in.
