# Runbook — Add VM User

Steps to give a collaborator access to work directly on the Ubuntu Server VM.

Use this when someone needs to work on Prismo infrastructure, services, or projects
directly on the VM. This is the primary onboarding path — everyone works on the VM
via SSH. For setting up a new local machine to connect remotely, see
new-machine-setup.md (that use case is rare and largely superseded by this one).

---

## Prerequisites

- SSH access to the VM as ethan (or another sudo user)
- New user's SSH public key (optional — password auth also works)

---

## Steps

### 1. Create the account (as ethan)

SSH into the VM as ethan, then:

```bash
sudo useradd -m -s /bin/bash <username>
sudo passwd <username>
```

### 2. Add SSH key (if provided)

```bash
sudo mkdir -p /home/<username>/.ssh
echo "<public-key>" | sudo tee /home/<username>/.ssh/authorized_keys
sudo chmod 700 /home/<username>/.ssh
sudo chmod 600 /home/<username>/.ssh/authorized_keys
sudo chown -R <username>:<username> /home/<username>/.ssh
```

If the user doesn't have an SSH key, have them generate one first:

```bash
ssh-keygen -t ed25519 -C "<username>@prismo"
cat ~/.ssh/id_ed25519.pub
```

### 3. Add to docker and sudo groups

```bash
sudo usermod -aG docker <username>
sudo usermod -aG sudo <username>
```

User must log out and back in for group membership to take effect.

---

## Steps (as the new user)

SSH in as the new user:

```bash
ssh <username>@ubuntu-server.tail58b10c.ts.net
```

### 4. Clone homelab and install hooks

```bash
git clone https://github.com/EthanPlusPlus/homelab.git ~/canon/homelab
cd ~/canon/homelab && bash scripts/install-hooks.sh
```

### 5. Set up memory and MCP

`prismo new-machine` is designed for local machines and cannot run on the VM as-is
(`VM_HOST` is hardcoded — env var override has no effect). Run these steps manually:

```bash
# Create dirs
mkdir -p ~/projects ~/canon

# Memory symlinks
KEY=$(echo "$HOME/canon/homelab" | sed 's|^/||; s|/|-|g')
MEM_DIR="$HOME/.claude/projects/$KEY/memory"
mkdir -p "$MEM_DIR"
for f in system.md workflow.md mcp.md shorthands.md; do
  ln -sf "$HOME/canon/homelab/docs/memory/$f" "$MEM_DIR/$f"
done

# Register MCP
cd ~/canon/homelab && claude mcp add context-server --transport http http://localhost:8001/mcp
```

### 6. Clone project repos (as needed)

```bash
# context-server (code only, sparse checkout)
git clone https://github.com/EthanPlusPlus/context-server.git ~/projects/context-server
git -C ~/projects/context-server sparse-checkout init --cone
git -C ~/projects/context-server sparse-checkout set api chroma_store context_mcp indexers

# devcamp
git clone https://github.com/EthanPlusPlus/devcamp.git ~/projects/devcamp
```

### 7. Verify

```bash
prismo status
```

---

## Known Issue — prismo script

`VM_HOST` is hardcoded at the top of `scripts/prismo`. Running `VM_HOST=localhost prismo new-machine`
does not override it — the script reassigns the variable internally. Until this is fixed,
use the manual memory/MCP steps above (step 5) instead of `prismo new-machine`.
