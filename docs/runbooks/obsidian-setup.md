# Obsidian Setup

View and edit all of Prismo's canon from a single Obsidian vault on your Mac (or any desktop machine). Changes made in Obsidian sync to GitHub and the server auto-pulls them, keeping the context-server index current.

---

## Mac Setup — One-liner

> **Prerequisite:** Tailscale must be connected before running this.

Run this on your Mac. It clones the repos, installs the sync script, and sets up auto-sync via launchd:

```bash
bash <(curl -fsSL http://ubuntu-server.tail58b10c.ts.net:8000/scripts/obsidian-bootstrap.sh)
```

Then open Obsidian → "Open folder as vault" → `~/obsidian-canon/`.

That's it. The rest of this document explains the architecture and manual steps if needed.

The script is served directly by the context-server API (`/scripts` static mount → `/canon/homelab/scripts/`), so it always reflects the latest version in canon.

---

## Architecture

```
Mac (Obsidian vault)
  ~/obsidian-canon/
    homelab/          ← clone of git@github.com:EthanPlusPlus/homelab.git
    context-server/   ← clone of git@github.com:EthanPlusPlus/context-server.git
                        checked out on branch: context-server
    exam-prep/        ← plain folder (no git), copy manually or skip

  ~/bin/canon-sync.sh ← sync script, run manually or via launchd
```

The server runs a cron every 2 minutes that pulls from GitHub and re-indexes.

---

## Mac Setup (manual)

The bootstrap script handles all of this automatically. These steps are here for reference or troubleshooting.

### 1. Clone the repos

```bash
mkdir -p ~/obsidian-canon
git clone https://github.com/EthanPlusPlus/homelab.git ~/obsidian-canon/homelab
git clone https://github.com/EthanPlusPlus/context-server.git ~/obsidian-canon/context-server
git -C ~/obsidian-canon/context-server checkout context-server
```

> The context-server docs live on the `context-server` branch — not master.
> macOS will prompt for GitHub credentials on first clone — use a Personal Access Token as the password.

### 2. Open as an Obsidian vault

Open Obsidian → "Open folder as vault" → select `~/obsidian-canon/`

### 3. Sync script

Installed to `~/bin/canon-sync.sh` by the bootstrap. Run manually to push changes immediately:

```bash
~/bin/canon-sync.sh
```

### 4. Auto-sync

The bootstrap installs and loads a launchd agent (`com.prismo.canon-sync`) that runs the sync script every 5 minutes. Check the log with:

```bash
tail -f /tmp/canon-sync.log
```

---

## Server Side

The server runs a cron job every 2 minutes to pull and re-index:

```
*/2 * * * * cd /home/ethan/canon/homelab && git pull --ff-only && curl -s -X POST http://localhost:8000/index >> /tmp/canon-pull.log 2>&1
*/2 * * * * cd /home/ethan/canon/context-server && git pull --ff-only && curl -s -X POST http://localhost:8000/index >> /tmp/canon-pull.log 2>&1
```

This is already installed. To verify: `crontab -l`

---

## Conflict Avoidance

- Don't edit the same file in Obsidian and on the server simultaneously
- The server-side workflow (Claude Code sessions) always does `git pull` before committing — that's the existing parallel session protocol
- If a conflict occurs: resolve it on the Mac, commit, push; the server will pull the resolution on the next cron tick

---

## Notes

- `exam-prep/` has no git repo — copy it into the vault manually if you want it in Obsidian, but changes won't sync
- Obsidian's graph view, backlinks, and search work across both repos from day one
- Wikilinks between homelab and context-server docs work within the vault (Obsidian resolves them by filename)
