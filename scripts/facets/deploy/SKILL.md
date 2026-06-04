# deploy facet

Activates when the user signals they're deploying or shipping a change.
Runs through the deploy checklist: Service Rule pre-check, commit/push,
rebuild container, health check, re-index if needed, smoke test, topology verify.
