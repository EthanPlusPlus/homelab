# Repair broken cross-references in canon

## Purpose

Broken double-bracket wiki-links fail silently during retrieval — lookups return nothing
instead of the intended document. Detection is automated
([[../proposed-ideas/021-doctrine-xref-validation|PI-021]], shipped 2026-06-07);
repair is manual. This runbook covers the repair loop.

## When to run

- `prismo doctrine validate` or `GET /doctrine/xrefs` reports `broken_xref` violations
- After renaming or moving a canon document
- During Sukuna passes

## Procedure

1. **Detect** — run the automated check (do not grep by hand):

   ```bash
   prismo doctrine validate          # all rules, includes xrefs
   curl -s -H "Authorization: Bearer $API_KEY" \
     "$CONTEXT_API/doctrine/xrefs?project=<name>"   # xrefs only
   ```

   **Freshness caveat:** the check runs against the index, not the filesystem.
   A just-written file looks like a broken target until re-index
   (`POST /index`). Re-index before treating results as authoritative.

2. **Diagnose** each violation — typical causes:
   - Typo in the slug (e.g. `032-portability-commercial-constraint` vs actual
     `032-portability-as-commercial-grade-constraint`)
   - Stale slug from a renamed file (check `git log --follow` on the target)
   - Reference into `drafts/` or `history/` pointing at a doc that was
     deleted or never indexed (drafts are not indexed by default)

3. **Repair** — update the link slug to the current filename (no `.md`).
   If a file was renamed, grep canon for the old slug and fix *every* referrer.

4. **Verify** — re-index, then re-run step 1; the violation count must drop.

## Note on accepted legacy violations

`history/` and `drafts/` docs carry old-format references that predate current
conventions. Repairing those is optional — they are records, not live canon.
Live-canon violations (decisions/, proposed-ideas/, architecture/, runbooks/)
should be fixed promptly.
