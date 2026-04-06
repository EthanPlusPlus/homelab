# Decision 007 — MCP server transport and hosting

## Status
Adopted

## Context
The MCP server needs to be reachable from Claude Code running on a local machine, while the server itself runs on the Ubuntu VM.

## Decision
Use streamable-http transport over Tailscale. The MCP server binds to 0.0.0.0:8001 inside Docker, exposed on the VM's Tailscale IP (100.92.226.121:8001). Claude Code connects via http://100.92.226.121:8001/mcp.

## Alternatives Considered
- stdio transport — requires the MCP server to run locally, not on the VM
- SSE transport — older pattern, streamable-http is the current standard

## Consequences
- No additional networking setup required — Tailscale handles secure connectivity
- Claude Code config lives in ~/.claude.json on the local machine
- MCP server must be running for Claude Code to have retrieval access
