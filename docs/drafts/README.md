# Drafts (legacy — Decision 021)

Frozen folder per [[../decisions/021-reviewitems-as-judgment-boundary|Decision 021]].
**No new files land here.** Historical drafts and captures preserved as-is,
excluded from retrieval (`record_type=draft`).

New pre-approval content lives as ReviewItems in workflow-state-service
(`/review/queue`, surfaced via `prismo review`). Approved ReviewItems are
written directly into canonical folders by the approve endpoint.
