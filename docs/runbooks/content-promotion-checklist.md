# Content Promotion Checklist: Proposed → Experimental → Active

## When promoting a document's status (frontmatter or body), sync both locations.

**Trigger:** A document's `status` field in frontmatter is being changed (e.g., `proposed` → `experimental` → `active`).

**Checklist:**

1. Update frontmatter `status:` field to new state.
2. Update body text to reflect the same state — search for prose descriptions like "Proposed," "being evaluated," "actively in use," etc.
3. If the document is a **decision**, ensure `## Status` section (if present) is consistent with frontmatter.
4. If the document is a **proposed-idea** or **architecture note**, scan the opening paragraph and any status-narrative sections.
5. Verify linked references (e.g., `[[...]]` citations) still make sense in the new context.
6. If promoting to `active`, confirm **Decision 020** metadata expectations are met: frontmatter complete, required sections present, title format correct.

**Why:** Status inconsistency between frontmatter and body creates ambiguity for readers and retrieval systems. Frontmatter drives lifecycle automation (e.g., stale-flag timers under **lifecycle-semantics.md**); body text is what humans read. Both must agree.

**Example:** PI-021 was promoted to `experimental` (frontmatter) but retained text saying "Proposed" (body). A reader checking the document would see conflicting signals.