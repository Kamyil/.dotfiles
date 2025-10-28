# Complete Nix Reinstallation Guide for macOS

## When Nix is Completely Broken

If you have a Nix store volume but nothing else works (nix-daemon missing, no profiles, no commands), your Nix installation is completely broken and needs full reinstallation.

## ⚠️ Complete Reinstallation (Nuclear Option)

**Automated Script:**
```bash
curl -L https://raw.githubusercontent.com/Kamyil/.dotfiles/main/scripts/reinstall-nix-complete.sh | bash
```

This script will:
1. **Completely remove** all Nix components (daemon, users, volumes, configs)
2. **Fresh install** Nix using Determinate Systems installer
3. **Bootstrap** nix-darwin with your configuration
4. **Restore** all your tools and settings

## Manual Steps (if you prefer)

### 1. Complete Cleanup
```bash
# Stop nix services
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true

# Remove nix users
for i in $(seq 1 32); do
    sudo dscl . -delete /Users/_nixbld$i 2>/dev/null || true
done
sudo dscl . -delete /Groups/nixbld 2>/dev/null || true

# Remove nix volume
sudo diskutil unmount force /nix 2>/dev/null || true
sudo diskutil apfs deleteVolume /nix 2>/dev/null || true

# Clean up remaining files
sudo rm -rf /nix /etc/nix ~/.nix-*
```

### 2. Fresh Installation
```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Source environment
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

### 3. Install nix-darwin
```bash
# Clone dotfiles
git clone https://github.com/Kamyil/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Bootstrap nix-darwin
nix run nix-darwin -- switch --flake "./nix#MacBook-Pro-Kamil"
```

### 4. Restart Terminal
**IMPORTANT:** Restart your terminal (or reboot) after installation.

### 5. Verify Installation
```bash
which nix                    # Should show /run/current-system/sw/bin/nix
which darwin-rebuild         # Should show /run/current-system/sw/bin/darwin-rebuild
sudo darwin-rebuild switch --flake ~/.dotfiles/nix
```

## Why This Happens

- Incomplete uninstallation leaving broken remnants
- macOS updates breaking Nix components
- Manual tampering with Nix files
- Failed previous installations

## Prevention

After successful installation, your environment will persist properly across reboots thanks to the nix-darwin configuration fixes.