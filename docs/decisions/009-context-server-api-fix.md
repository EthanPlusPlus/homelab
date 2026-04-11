# Decision 009 — context-server API stability fixes

## Status
Adopted

## Context
The context-server API (port 8000) was crashing on every container start, making the MCP server
unable to serve any requests. The uvicorn worker subprocess was dying during module import before
it could bind to the socket.

Two separate bugs combined to cause this:

1. **uvicorn `--reload` + httpx fork bug** — `--reload` mode spawns a child worker via fork.
   `SentenceTransformer` is loaded at module level in `api/main.py`, which triggers a HuggingFace
   Hub metadata check over httpx. The forked child inherits a closed httpx client from the parent,
   causing `RuntimeError: Cannot send a request, as the client has been closed.`

2. **HuggingFace model cache not persisted** — the `all-MiniLM-L6-v2` model was cached in the
   container's ephemeral writable layer. Any container recreation (e.g. after a config change or
   restart policy trigger) wiped the cache, forcing a fresh download on next start — which then
   hit bug #1.

## Decision
1. Remove `--reload` from the uvicorn command in `docker-compose.yml`. The reload flag is a
   development convenience and is not appropriate for a persistent homelab service.
2. Add a named Docker volume (`hf_cache`) mounted at `/root/.cache/huggingface` so the downloaded
   embedding model survives container recreations.

## Alternatives Considered
- Set `HF_HUB_OFFLINE=1` + `TRANSFORMERS_OFFLINE=1` — forces offline mode but requires the model
  to already be cached. Fails on first run after any volume wipe. Rejected as insufficient alone.
- Bake the model into the Docker image via a `RUN` step in the Dockerfile — valid long-term option
  but requires a full image rebuild and increases image size. Deferred; the volume approach is
  simpler and achieves the same result.

## Consequences
- The API now starts reliably across container restarts and recreations
- `--reload` is gone; code changes require `docker compose restart api` to take effect
- Model download happens once per volume lifetime, not on every container start
