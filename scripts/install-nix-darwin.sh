#!/usr/bin/env bash

# Bootstrap script for nix-darwin installation on macOS
set -euo pipefail

echo "🍎 Setting up nix-darwin on macOS..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is only for macOS"
    exit 1
fi

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo "📦 Installing Nix package manager..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Source nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
else
    echo "✅ Nix is already installed"
fi

# Verify nix works
if ! command -v nix &> /dev/null; then
    echo "❌ Nix installation failed or not in PATH"
    echo "Please restart your terminal and run: source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    exit 1
fi

echo "🔧 Installing nix-darwin..."

# Clone or update dotfiles
DOTFILES_DIR="$HOME/.dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📁 Cloning dotfiles..."
    git clone https://github.com/Kamyil/.dotfiles.git "$DOTFILES_DIR"
else
    echo "📁 Updating dotfiles..."
    cd "$DOTFILES_DIR"
    git pull
fi

cd "$DOTFILES_DIR"

# Build and activate the darwin configuration
echo "🚀 Building darwin configuration..."
nix run nix-darwin -- switch --flake "./nix#MacBook-Pro-Kamil"

echo "✅ nix-darwin installation complete!"
echo ""
echo "🔄 Please restart your terminal or run:"
echo "   source ~/.zshrc"
echo ""
echo "🔧 Future updates can be done with:"
echo "   sudo darwin-rebuild switch --flake ~/.dotfiles/nix"