# Runbook — Starting a New Project in Prismo

Steps to add a new code project to Prismo — repo setup, sparse checkout, docs
worktree, git hooks, and context-server indexing.

## Prerequisites

- Repo exists on GitHub (create it first if needed)
- You are working on the VM (`ubuntu-server`)
- context-server is running at `http://localhost:8000`

---

## Steps

### 1. Clone the repo (sparse — code only)

```bash
git clone <repo-url> ~/projects/<name>
cd ~/projects/<name>

# Exclude docs/ from the working tree
git sparse-checkout init --cone
git sparse-checkout set <dir1> <dir2> ...   # all top-level dirs except docs/
```

Keep `docs/` out of the code working tree. It will live in `~/canon/` instead.

### 2. Add the scripts/ folder and install hooks

Copy the `scripts/` folder from an existing repo (e.g. context-server):

```bash
cp -r ~/projects/context-server/scripts ~/projects/<name>/scripts
```

Edit `scripts/post-merge` to target the new project:

```bash
curl -s -X POST "http://localhost:8000/index/code?project=<name>"
```

Install the hook:

```bash
cd ~/projects/<name>
bash scripts/install-hooks.sh
```

Commit the scripts folder:

```bash
git add scripts/
git commit -m "add prismo re-index hooks"
git push
```

### 3. Create the docs/ folder structure

Still in `~/projects/<name>`, create the docs branch and scaffold:

```bash
git checkout -b docs
mkdir -p docs/{decisions,runbooks,architecture,context,proposed-ideas}
```

Create the required context files:

```bash
cat > docs/context/progress.md << 'EOF'
# Progress

## In Progress

_(nothing currently in progress)_

## Next

_(see proposed-ideas/ for upcoming directions)_

## Done

_(nothing yet)_
EOF

cat > docs/context/recent-changes.md << 'EOF'
# Recent Changes

Rolling log of meaningful system changes. Keep last ~10 entries.

---

_(no changes yet)_
EOF

cat > docs/context/constraints.md << 'EOF'
# Constraints

Active limitations that materially affect design or system behavior.

---

_(none documented yet)_
EOF

cat > docs/open-questions.md << 'EOF'
# Open Questions

_(none yet)_
EOF
```

Copy `STRUCTURE.md` from an existing project and update it for the new project:

```bash
cp ~/canon/context-server/docs/STRUCTURE.md docs/STRUCTURE.md
# Edit to reflect this project's actual folder purposes
```

Add a `CLAUDE.md` at the repo root (not in docs/):

```bash
cat > CLAUDE.md << 'EOF'
# <Project Name>

Brief description of what this project is.

## MCP

Always retrieve context via MCP before reasoning or planning.

To add the MCP server (run from this repo directory):

    claude mcp add context-server --transport http \
      http://ubuntu-server.tail58b10c.ts.net:8001/mcp

## Workflow

0. Start sessions with "hi" to trigger session bootstrap
1. Retrieve context from MCP
2. Check docs/context/ — progress.md, recent-changes.md, constraints.md
3. Propose a plan — wait for approval before touching anything
4. Execute the approved plan
5. Update docs/context/ and any affected docs
6. Re-index: curl -X POST http://localhost:8000/index
7. Commit and push
EOF
```

Commit and push the docs branch:

```bash
git add -A
git commit -m "bootstrap docs structure"
git push -u origin docs
```

Merge into master so CLAUDE.md and scripts/ are on master:

```bash
git checkout master
git merge docs
git push
```

### 4. Create the docs worktree in ~/canon/

```bash
cd ~/projects/<name>

# Enable per-worktree config
git config extensions.worktreeConfig true

# Create the worktree on the docs branch
git worktree add ~/canon/<name> docs

# Scope worktree to docs/ only
cd ~/canon/<name>
git sparse-checkout init --cone
git sparse-checkout set docs
```

Install the worktree-specific re-index hook:

```bash
WORKTREE_GIT_DIR="/home/ethan/projects/<name>/.git/worktrees/<name>"
mkdir -p "$WORKTREE_GIT_DIR/hooks"
cat > "$WORKTREE_GIT_DIR/hooks/post-merge" << 'EOF'
#!/bin/bash
curl -s -X POST http://localhost:8000/index
EOF
chmod +x "$WORKTREE_GIT_DIR/hooks/post-merge"
git config --worktree core.hooksPath "$WORKTREE_GIT_DIR/hooks"
```

### 5. Register the project with context-server

Add the new project to context-server's environment config so it gets indexed.
Check how existing projects are registered:

```bash
cat ~/projects/context-server/.env   # or however CANON_PATH is configured
```

Typically, adding the project's docs path to `CANON_PATH` or the equivalent
multi-project config is sufficient. Confirm with the context-server docs.

### 6. Trigger initial indexing

```bash
# Index docs
curl -X POST http://localhost:8000/index

# Index code
curl -X POST "http://localhost:8000/index/code?project=<name>"
```

Verify both return success before continuing.

### 7. Add MCP server for this repo (on each machine)

From the new repo directory:

```bash
claude mcp add context-server --transport http \
  http://ubuntu-server.tail58b10c.ts.net:8001/mcp
```

This is per-machine and per-repo-directory — it must be run once on each
machine where you'll work on this project.

### 8. Update homelab docs

- Add the new project to `~/canon/homelab/docs/architecture/` if it affects infrastructure
- Add the new service to the service inventory in `~/canon/homelab/docs/context/`
- Update `new-machine-setup.md` to include the new repo's sparse-checkout dirs
- Re-index and push homelab

---

## Checklist

- [ ] Repo cloned with sparse checkout (no docs/ in ~/projects/<name>)
- [ ] scripts/ folder present and hook installed
- [ ] docs/ branch created with full structure
- [ ] CLAUDE.md at repo root (on master)
- [ ] Docs worktree at ~/canon/<name>
- [ ] Worktree re-index hook installed
- [ ] Project registered with context-server
- [ ] Initial index triggered and successful
- [ ] MCP server added for this repo directory
- [ ] Homelab docs updated
