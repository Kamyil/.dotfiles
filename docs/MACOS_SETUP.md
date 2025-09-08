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

### If you have Nix store but `darwin-rebuild` not found

This usually means nix-darwin was partially installed or broken. Run diagnostics first:

```bash
# Download and run diagnostic script
curl -L https://raw.githubusercontent.com/Kamyil/.dotfiles/main/scripts/diagnose-nix.sh | bash
```

Then run the repair script:

```bash
# Download and run repair script  
curl -L https://raw.githubusercontent.com/Kamyil/.dotfiles/main/scripts/repair-nix-darwin.sh | bash
```

### Manual repair steps

1. **Source Nix environment**:
```bash
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

2. **Check nix command works**:
```bash
nix --version
```

3. **Bootstrap nix-darwin if missing**:
```bash
cd ~/.dotfiles
nix run nix-darwin -- switch --flake "./nixos#MacBook-Pro-Kamil"
```

4. **Restart terminal** and verify:
```bash
which darwin-rebuild
```

### Common Issues

- **Commands disappear after reboot**: nix-darwin bootstrap wasn't successful
- **`nix` command not found**: Need to source environment or restart terminal  
- **Permission denied**: Use `sudo` with `darwin-rebuild`
- **Flake not found**: Make sure you're in the correct directory or use full path