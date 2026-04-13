# Runbook — "Make This Canon"

## What It Means

When Ethan says **"make this canon"** (or similar: "add this to canon", "canonise this"),
it means: take the thing just decided, discussed, or built — and run the full
documentation and indexing workflow so it becomes part of the permanent knowledge base.

This is the shorthand for the full doc workflow, triggered on demand.

---

## The Workflow

1. **Identify what needs documenting** — a decision, a new runbook, an architecture
   change, a constraint, a recent change. Pick the right doc type and location.

2. **Write it** — in the correct file under `~/canon/<project>/docs/`:
   - New decision → `decisions/00N-name.md`
   - New procedure → `runbooks/name.md`
   - State change → `context/recent-changes.md` + `context/progress.md`
   - Architecture change → `architecture/*.md`

3. **Re-index**
   ```bash
   curl -X POST http://localhost:8000/index
   ```

4. **Commit and push** — from the canon worktree:
   ```bash
   cd ~/canon/<project>
   git add -A && git commit -m "..."
   git push
   ```

5. **Merge docs branch into master** (for code repos with docs worktrees):
   ```bash
   cd ~/projects/<project>
   git merge <docs-branch>
   git push
   ```

6. **Done** — the knowledge is indexed, committed, and retrievable via MCP.

---

## Notes

- homelab docs live in `~/canon/homelab/` — no merge step needed (primary clone)
- context-server docs live in `~/canon/context-server/` — merge `context-server` branch into `master` after committing
- If unsure which doc type fits, check `docs/STRUCTURE.md`
