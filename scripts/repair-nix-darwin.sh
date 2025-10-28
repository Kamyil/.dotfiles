#!/usr/bin/env bash

# Repair script for broken nix-darwin installation on macOS
set -euo pipefail

echo "🔧 Repairing nix-darwin installation..."

# First, try to source nix environment
echo "🌍 Sourcing Nix environment..."
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    echo "✅ Nix environment sourced"
else
    echo "❌ Cannot source nix environment - nix-daemon.sh missing"
    exit 1
fi

# Verify nix command works
if ! command -v nix &> /dev/null; then
    echo "❌ nix command still not available after sourcing"
    echo "You may need to reinstall Nix completely"
    exit 1
fi

echo "✅ nix command is available"

# Check if we need to start nix-daemon
if ! launchctl list | grep -q nix-daemon; then
    echo "🔄 Starting nix-daemon..."
    sudo launchctl kickstart -k system/org.nixos.nix-daemon
fi

# Update dotfiles
DOTFILES_DIR="$HOME/.dotfiles"
if [ -d "$DOTFILES_DIR" ]; then
    echo "📁 Updating dotfiles..."
    cd "$DOTFILES_DIR"
    git pull
else
    echo "📁 Cloning dotfiles..."
    git clone https://github.com/Kamyil/.dotfiles.git "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# Try to repair/rebuild nix-darwin configuration
echo "🚀 Attempting to rebuild darwin configuration..."

# Method 1: Try existing darwin-rebuild if it exists somewhere
if command -v darwin-rebuild &> /dev/null; then
    echo "📋 Found existing darwin-rebuild, attempting switch..."
    sudo darwin-rebuild switch --flake "./nix#MacBook-Pro-Kamil"
    
# Method 2: Bootstrap from scratch if darwin-rebuild missing
else
    echo "🔄 darwin-rebuild missing, bootstrapping from scratch..."
    nix run nix-darwin -- switch --flake "./nix#MacBook-Pro-Kamil"
fi

echo ""
echo "✅ Repair attempt complete!"
echo ""
echo "🔄 Please restart your terminal and test:"
echo "   which darwin-rebuild"
echo "   sudo darwin-rebuild switch --flake ~/.dotfiles/nix"
echo ""
echo "If issues persist, check /etc/zshrc contains nix configuration"