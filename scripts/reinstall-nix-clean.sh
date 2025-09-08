#!/usr/bin/env bash

# Complete Nix reinstallation script for macOS when installation is broken
set -euo pipefail

echo "Complete Nix reinstallation for macOS"
echo "WARNING: This will completely remove and reinstall Nix"
echo ""

# Ask for confirmation
read -p "Continue with complete reinstallation? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled"
    exit 1
fi

echo "Step 1: Cleaning up broken Nix installation..."

# Stop any running nix services
echo "Stopping nix services..."
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
sudo launchctl remove org.nixos.nix-daemon 2>/dev/null || true

# Remove nix daemon plist
sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist

# Remove nix users (if they exist)
echo "Removing nix users..."
for i in $(seq 1 32); do
    sudo dscl . -delete /Users/_nixbld$i 2>/dev/null || true
done
sudo dscl . -delete /Groups/nixbld 2>/dev/null || true

# Remove shell configuration
sudo rm -f /etc/zshrc.backup-before-nix
sudo rm -f /etc/bashrc.backup-before-nix

# Unmount and remove nix volume
echo "Removing Nix volume..."
sudo diskutil unmount force /nix 2>/dev/null || true
sudo diskutil apfs deleteVolume /nix 2>/dev/null || true

# Remove any remaining nix directories
sudo rm -rf /nix
sudo rm -rf /etc/nix
sudo rm -rf ~/.nix-*

# Remove from PATH in shell profiles
echo "Cleaning shell profiles..."
if [ -f ~/.zshrc ]; then
    sed -i '' '/# Nix/d' ~/.zshrc
    sed -i '' '/nix-daemon/d' ~/.zshrc
    sed -i '' '/\/nix\/var\/nix/d' ~/.zshrc
fi

if [ -f ~/.bash_profile ]; then
    sed -i '' '/# Nix/d' ~/.bash_profile
    sed -i '' '/nix-daemon/d' ~/.bash_profile
    sed -i '' '/\/nix\/var\/nix/d' ~/.bash_profile
fi

echo "Cleanup complete"
echo ""
echo "Step 2: Fresh Nix installation..."

# Install Nix using Determinate Systems installer (most reliable)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

echo "Fresh Nix installation complete"
echo ""
echo "Step 3: Installing nix-darwin..."

# Source the new nix environment
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
else
    echo "ERROR: Nix installation failed - nix-daemon.sh still missing"
    exit 1
fi

# Verify nix works
if ! command -v nix &> /dev/null; then
    echo "ERROR: nix command not available after installation"
    exit 1
fi

# Clone/update dotfiles
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/Kamyil/.dotfiles.git "$DOTFILES_DIR"
else
    echo "Updating dotfiles..."
    cd "$DOTFILES_DIR"
    git pull
fi

cd "$DOTFILES_DIR"

# Bootstrap nix-darwin
echo "Bootstrapping nix-darwin..."
nix run nix-darwin -- switch --flake "./nixos#MacBook-Pro-Kamil"

echo ""
echo "Complete reinstallation finished!"
echo ""
echo "IMPORTANT: You MUST restart your terminal (or reboot) now"
echo ""
echo "After restart, verify with:"
echo "  which nix"
echo "  which darwin-rebuild"
echo "  sudo darwin-rebuild switch --flake ~/.dotfiles/nixos"