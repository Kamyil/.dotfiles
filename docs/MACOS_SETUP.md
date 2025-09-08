# macOS Setup with nix-darwin

## Bootstrap Installation

If `darwin-rebuild` command is not found, you need to bootstrap nix-darwin first:

### Option 1: Automated Script
```bash
# Download and run the bootstrap script
curl -L https://raw.githubusercontent.com/Kamyil/.dotfiles/main/scripts/install-nix-darwin.sh | bash
```

### Option 2: Manual Installation

1. **Install Nix** (if not already installed):
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. **Source Nix environment**:
```bash
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

3. **Clone dotfiles** (if not already done):
```bash
git clone https://github.com/Kamyil/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

4. **Bootstrap nix-darwin**:
```bash
nix run nix-darwin -- switch --flake "./nixos#MacBook-Pro-Kamil"
```

5. **Restart terminal** and verify:
```bash
which darwin-rebuild
# Should show: /run/current-system/sw/bin/darwin-rebuild
```

## Regular Usage

After bootstrap, use this command for updates:
```bash
sudo darwin-rebuild switch --flake ~/.dotfiles/nixos
```

## Troubleshooting

- If commands disappear after reboot, the bootstrap wasn't successful
- Make sure to restart terminal after initial installation
- Check that `/etc/zshrc` sources nix environment properly