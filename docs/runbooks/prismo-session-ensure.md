---
id: prismo-session-ensure
title: Prismo Session Ensure — UserPromptSubmit Hook
status: active
---

# Prismo Session Ensure — UserPromptSubmit Hook

## Overview

`prismo session ensure` is invoked by the UserPromptSubmit hook to initialize or resume a
Prismo session. It hydrates context, seeds focus, and emits lifecycle signals.

## Hook Input Format

The UserPromptSubmit hook passes a JSON envelope on stdin:

```json
{
  "session_id": "<uuid>",
  "transcript_path": "<path>",
  "cwd": "<working-directory>",
  "permissions": {},
  "prompt": "<user-provided-text>"
}
```

## Focus Seeding

Extract `.prompt` from the JSON envelope, truncate to 200 chars, store as `current_focus`.

**Important:** Filter out system-injected content before seeding. When a background task
completes and re-triggers the hook, the `prompt` field may contain XML tags (e.g.
`<task-notification>...`) rather than user text. If the extracted text starts with `<`,
skip focus-seeding entirely — it is a system message, not a real user prompt.

Fix shipped 2026-05-19 (`scripts/prismo`).

## Behavior on New Session

1. Close orphan active sessions for the same project + contributor
2. Start new session via `POST /workflow/session/start`
3. Seed `current_focus` from prompt (if not system-injected)
4. Emit `[V2 HYDRATED CONTEXT]` block:
   - Top 5 active doctrine items
   - Active proposals count
   - Top 3 recent changes
   - Unresolved tensions
   - Unacknowledged stale items (if any)

## Behavior on Existing Session

Silent — no re-hydration or focus update.

## Error Handling

Never blocks user prompts. Degrades gracefully if context-server is unreachable.

## Session End (Required)

Before ending a session:

1. **Update `recent-changes.md`** — add an entry summarising what shipped: decisions made, docs created/updated, artifacts produced. Keep the rolling log to ~10 entries.
2. **Commit all changes** — stage and commit all doc updates in canon repo(s) with a clear summary message.
3. **Close session** — `prismo session end` writes `current_focus` + capture count as summary before closing.
