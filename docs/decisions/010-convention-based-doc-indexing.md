# Decision 010 — Convention-based multi-project doc indexing

## Status
Adopted

## Context
The original doc indexer read from a single `DOCS_PATH` environment variable, mounted as `/docs` in the container and pointing to `~/projects/homelab/docs`. Adding a second project's docs required a new volume mount, a new env var, and an indexer code change — a manual three-step process every time a new project was created.

The problem surfaced when trying to index study materials for an exam-prep project. The friction confirmed that the initialisation process would not scale as Prismo grows to include more projects.

The `~/projects` directory was already mounted at `/projects` inside the container for the code indexer — the doc indexer just wasn't using it.

## Decision

Replace single-path `DOCS_PATH` with automatic discovery of `<project>/docs/` subdirectories under `PROJECTS_PATH`.

Convention: any directory under `~/projects/` that contains a `docs/` subdirectory is automatically indexed on the next `POST /index`. No compose changes, no env var changes, no code changes — just create the folder.

## Changes Made

**`indexers/docs/indexer.py`**
- Removed `DOCS_PATH` env var; now reads `PROJECTS_PATH` (already present)
- `index_docs()` iterates over `PROJECTS_PATH/*/docs/` — discovers projects automatically
- Hidden directories (`.git`, etc.) are skipped

**`api/main.py`**
- `/search/docs` now accepts an optional `category` query param in addition to `doc_type`
- Supports compound ChromaDB filter when both are supplied (`$and`)

**`context_mcp/main.py`**
- `search_docs` tool: `doc_type` is now a project name (e.g. `homelab`, `exam-prep`); `category` is the subdirectory filter (e.g. `decisions`, `architecture`)
- `list_related_decisions` fixed: was passing `doc_type="decisions"` (broken after this change); now passes `category="decisions"` — works cross-project

**`docker-compose.yml`**
- Removed `- /home/ethan/projects/homelab/docs:/docs:ro` volume mount
- Removed `DOCS_PATH=/docs` environment variable
- `PROJECTS_PATH=/projects` was already present — no change needed

## Metadata Schema Change

| Field | Before | After |
|-------|--------|-------|
| `doc_type` | first subdirectory under `/docs` (e.g. `decisions`) | project name (e.g. `homelab`) |
| `category` | did not exist | first subdirectory under `<project>/docs/` (e.g. `decisions`) |
| `path` | relative to `/docs` | relative to `<project>/docs/` — same format |

The full wipe-and-rebuild on every `/index` call meant no migration was needed — the first re-index after deploy rebuilt everything with the new schema.

## Project Initialisation (New Workflow)

To add a new project's docs to the index:

```
mkdir -p ~/projects/<name>/docs/
# add markdown files
curl -X POST http://localhost:8000/index
```

That is the complete process. No other changes required.

## Consequences
- Any project under `~/projects/` with a `docs/` folder is indexed automatically
- `doc_type` filter in MCP/API now scopes to a project; `category` scopes within a project
- `list_related_decisions` now searches across all projects' `decisions/` folders
- Existing homelab docs are unaffected — they now live at `doc_type=homelab`
- exam-prep project (`~/projects/exam-prep/docs/`) was the first non-homelab project indexed
