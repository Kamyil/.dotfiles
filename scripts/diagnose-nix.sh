#!/usr/bin/env bash

# Diagnostic script for existing Nix installation on macOS
set -euo pipefail

echo "🔍 Diagnosing existing Nix installation..."

# Check for Nix store volume
echo "📦 Checking Nix store volume..."
if mount | grep -q "/nix"; then
    echo "✅ Nix store volume is mounted:"
    mount | grep "/nix"
else
    echo "❌ Nix store volume not mounted"
fi

# Check if nix command works
echo ""
echo "🔧 Checking Nix command availability..."
if command -v nix &> /dev/null; then
    echo "✅ nix command found at: $(which nix)"
    echo "   Version: $(nix --version)"
else
    echo "❌ nix command not found in PATH"
    echo "   Current PATH: $PATH"
fi

# Check for nix-daemon
echo ""
echo "🔄 Checking nix-daemon..."
if launchctl list | grep -q nix-daemon; then
    echo "✅ nix-daemon is running"
else
    echo "❌ nix-daemon is not running"
fi

# Check for environment sourcing
echo ""
echo "🌍 Checking environment setup..."
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    echo "✅ nix-daemon.sh exists"
else
    echo "❌ nix-daemon.sh missing"
fi

# Check current user's nix profile
echo ""
echo "👤 Checking user Nix profile..."
if [ -e "/nix/var/nix/profiles/per-user/$USER/profile" ]; then
    echo "✅ User profile exists: /nix/var/nix/profiles/per-user/$USER/profile"
else
    echo "❌ User profile missing: /nix/var/nix/profiles/per-user/$USER/profile"
fi

# Check for darwin-rebuild specifically
echo ""
echo "🍎 Checking darwin-rebuild..."
if [ -e "/run/current-system/sw/bin/darwin-rebuild" ]; then
    echo "✅ darwin-rebuild found at: /run/current-system/sw/bin/darwin-rebuild"
elif find /nix -name "darwin-rebuild" 2>/dev/null | head -1; then
    echo "⚠️  darwin-rebuild found in nix store but not symlinked:"
    find /nix -name "darwin-rebuild" 2>/dev/null | head -3
else
    echo "❌ darwin-rebuild not found anywhere"
fi

# Check for nix-darwin system profile
echo ""
echo "🔗 Checking nix-darwin system profile..."
if [ -e "/run/current-system" ]; then
    echo "✅ Current system profile exists: /run/current-system"
    if [ -L "/run/current-system" ]; then
        echo "   Points to: $(readlink /run/current-system)"
    fi
else
    echo "❌ No current system profile (/run/current-system)"
fi

# Check shell configuration
echo ""
echo "🐚 Checking shell configuration..."
if [ -e "/etc/zshrc" ]; then
    echo "✅ System zshrc exists"
    if grep -q "nix" /etc/zshrc; then
        echo "   Contains nix configuration"
    else
        echo "   ⚠️  Does not contain nix configuration"
    fi
else
    echo "❌ No system zshrc"
fi

echo ""
echo "🎯 Diagnosis complete. Next steps:"
echo "   - If nix command not found: source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
echo "   - If darwin-rebuild missing: run repair script"
echo "   - If environment broken: restart terminal after sourcing"