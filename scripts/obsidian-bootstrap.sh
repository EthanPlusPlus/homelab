#!/bin/bash
# Prismo Obsidian Bootstrap
# Sets up the ~/obsidian-canon vault, sync script, and launchd auto-sync on macOS.
# Safe to re-run — skips steps already done.
#
# Usage (requires Tailscale):
#   bash <(curl -fsSL http://ubuntu-server.tail58b10c.ts.net:8000/scripts/obsidian-bootstrap.sh)

set -e

VAULT="$HOME/obsidian-canon"
SYNC_SCRIPT="$HOME/bin/canon-sync.sh"
PLIST="$HOME/Library/LaunchAgents/com.prismo.canon-sync.plist"
SYNC_INTERVAL=300  # seconds (5 minutes)

echo "==> Setting up Prismo Obsidian vault at $VAULT"

# 1. Clone repos
mkdir -p "$VAULT"

if [ -d "$VAULT/homelab/.git" ]; then
  echo "--- homelab already cloned, pulling"
  git -C "$VAULT/homelab" pull --ff-only
else
  echo "--- cloning homelab"
  git clone https://github.com/EthanPlusPlus/homelab.git "$VAULT/homelab"
fi

if [ -d "$VAULT/context-server/.git" ]; then
  echo "--- context-server already cloned, pulling"
  git -C "$VAULT/context-server" pull --ff-only
else
  echo "--- cloning context-server"
  git clone https://github.com/EthanPlusPlus/context-server.git "$VAULT/context-server"
fi

echo "--- checking out context-server docs branch"
git -C "$VAULT/context-server" checkout context-server

# 2. Install sync script
mkdir -p "$HOME/bin"
cat > "$SYNC_SCRIPT" << 'SYNCEOF'
#!/bin/bash
# canon-sync.sh — push Obsidian edits to GitHub
set -e

VAULT="$HOME/obsidian-canon"
LOG_PREFIX="[canon-sync $(date '+%H:%M:%S')]"

for dir in homelab context-server; do
  cd "$VAULT/$dir"
  git pull --ff-only
  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "obsidian: auto-save $(date '+%Y-%m-%d %H:%M')"
    git push
    echo "$LOG_PREFIX pushed $dir"
  else
    echo "$LOG_PREFIX $dir — nothing to push"
  fi
done
SYNCEOF
chmod +x "$SYNC_SCRIPT"
echo "--- sync script installed at $SYNC_SCRIPT"

# 3. Install and load launchd plist
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" << PLISTEOF
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
    <string>$SYNC_SCRIPT</string>
  </array>
  <key>StartInterval</key>
  <integer>$SYNC_INTERVAL</integer>
  <key>RunAtLoad</key>
  <false/>
  <key>StandardOutPath</key>
  <string>/tmp/canon-sync.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/canon-sync.log</string>
</dict>
</plist>
PLISTEOF

# Unload first in case it's already loaded (re-run case)
launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "--- launchd agent loaded (syncs every $((SYNC_INTERVAL / 60)) minutes)"

echo ""
echo "Done. Next steps:"
echo "  1. Open Obsidian → 'Open folder as vault' → $VAULT"
echo "  2. Edits sync automatically every $((SYNC_INTERVAL / 60)) min, or run: $SYNC_SCRIPT"
echo "  3. Check sync log: tail -f /tmp/canon-sync.log"
