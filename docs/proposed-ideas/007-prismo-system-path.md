---
id: "007"
title: prismo Available System-Wide
status: Proposed — straightforward, do when convenient
---

# 007 — prismo Available System-Wide

## Problem

`prismo` lives at `~/canon/homelab/scripts/prismo` and is not on any user's PATH by default.
Running it requires the full path or a personal `~/.bashrc` entry, neither of which works
cleanly for multiple users on the same server.

## Proposed Direction

Create a symlink in `/usr/local/bin`:

```bash
sudo ln -s /home/ethan/canon/homelab/scripts/prismo /usr/local/bin/prismo
```

This makes `prismo` available to every user on the machine with no per-user config.

Add this as a step in `new-machine-setup.md` and in `prismo new-machine` (the script
currently runs as the invoking user, so the `sudo` step would need to be explicit or
prompted separately).

## Notes

- The symlink points to the live script in the homelab repo — updates to the script
  are picked up immediately without re-linking
- Only needs to be done once per machine, not per user
- `/usr/local/bin` is on the default PATH for all users on Ubuntu
