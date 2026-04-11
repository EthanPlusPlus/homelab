# Runbook: Git Hooks (Auto Re-index)

## Purpose

Each project repo contains a `post-merge` hook that automatically triggers
re-indexing in the context-server when `git pull` brings in new changes.

This means you never need to manually call the index endpoints after pulling.

---

## How It Works

Each repo has:
```
scripts/
  post-merge        ← the hook script, tracked in git
  install-hooks.sh  ← installs the hook by symlinking into .git/hooks/
```

When `git pull` completes and new commits are merged, `post-merge` fires
and calls the appropriate context-server endpoint for that repo.

| Repo | What gets indexed |
|------|------------------|
| homelab | docs (`/index`) |
| context-server | code (`/index/code?project=context-server`) |
| devcamp | code (`/index/code?project=devcamp`) |

---

## Install After Cloning

After cloning any project repo, run once from the repo root:

```bash
./scripts/install-hooks.sh
```

This symlinks `scripts/post-merge` into `.git/hooks/post-merge` so git can find it.

**Known limitation:** This step is manual and easy to forget after a fresh clone.
The hook will silently not fire until it is installed.
See open-questions.md if automating this becomes worth revisiting.

---

## Adding a New Project

1. Copy the `scripts/` folder from an existing repo into the new repo
2. Update `scripts/post-merge` to call the correct project name:
   ```bash
   curl -s -X POST "http://localhost:8000/index/code?project=<your-project>"
   ```
3. Run `./scripts/install-hooks.sh` after cloning
4. Commit the `scripts/` folder to the repo

---

## Verify the Hook Is Installed

```bash
ls -la .git/hooks/post-merge
```

Should show a symlink pointing to `scripts/post-merge`.

---

## Manual Re-index (Fallback)

If the hook is not installed or you need to force re-index:

```bash
# Docs
curl -X POST http://localhost:8000/index

# Code
curl -X POST "http://localhost:8000/index/code?project=<project-name>"
```
