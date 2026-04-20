# Obsidian Setup

View and edit all of Prismo's canon from a single Obsidian vault on your Mac (or any desktop machine). Changes made in Obsidian sync to GitHub and the server auto-pulls them, keeping the context-server index current.

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

## Mac Setup

### 1. Clone the repos into the vault root

```bash
mkdir -p ~/obsidian-canon
cd ~/obsidian-canon

git clone git@github.com:EthanPlusPlus/homelab.git
git clone git@github.com:EthanPlusPlus/context-server.git
cd context-server && git checkout context-server && cd ..
```

> The context-server docs live on the `context-server` branch — not master.

### 2. Open as an Obsidian vault

- Open Obsidian → "Open folder as vault" → select `~/obsidian-canon/`
- All docs from both repos are now visible and cross-searchable

### 3. Install the sync script

```bash
mkdir -p ~/bin
cat > ~/bin/canon-sync.sh << 'EOF'
#!/bin/bash
set -e

VAULT=~/obsidian-canon

for dir in homelab context-server; do
  cd "$VAULT/$dir"
  git pull --ff-only
  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "obsidian: auto-save $(date '+%Y-%m-%d %H:%M')"
    git push
  fi
done

echo "canon synced at $(date '+%H:%M')"
EOF

chmod +x ~/bin/canon-sync.sh
```

Run manually with `~/bin/canon-sync.sh` whenever you want to push changes.

### 4. (Optional) Auto-sync via launchd

To sync automatically every 5 minutes in the background:

```bash
cat > ~/Library/LaunchAgents/com.prismo.canon-sync.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.prismo.canon-sync</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>/Users/YOUR_USERNAME/bin/canon-sync.sh</string>
  </array>
  <key>StartInterval</key>
  <integer>300</integer>
  <key>RunAtLoad</key>
  <false/>
  <key>StandardOutPath</key>
  <string>/tmp/canon-sync.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/canon-sync.log</string>
</dict>
</plist>
EOF
```

Replace `YOUR_USERNAME` with your Mac username, then load it:

```bash
launchctl load ~/Library/LaunchAgents/com.prismo.canon-sync.plist
```

---

## Server Side

The server runs a cron job every 2 minutes to pull and re-index:

```
*/2 * * * * cd /home/ethan/canon/homelab && git pull --ff-only >> /tmp/canon-pull.log 2>&1
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
