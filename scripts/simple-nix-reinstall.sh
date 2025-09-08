#!/bin/bash

echo "Nix Complete Reinstallation Script"
echo "This will remove and reinstall Nix completely"
echo ""
echo "Type 'yes' to continue or anything else to cancel:"
read answer

if [ "$answer" != "yes" ]; then
    echo "Cancelled"
    exit 1
fi

echo "Starting cleanup..."

# Stop nix services
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
sudo launchctl remove org.nixos.nix-daemon 2>/dev/null || true

# Remove nix daemon plist
sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist

# Remove nix users
echo "Removing nix users..."
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32; do
    sudo dscl . -delete /Users/_nixbld$i 2>/dev/null || true
done
sudo dscl . -delete /Groups/nixbld 2>/dev/null || true

# Remove nix volume
echo "Removing Nix volume..."
sudo diskutil unmount force /nix 2>/dev/null || true
sudo diskutil apfs deleteVolume /nix 2>/dev/null || true

# Remove directories
echo "Removing directories..."
sudo rm -rf /nix 2>/dev/null || true
sudo rm -rf /etc/nix 2>/dev/null || true
rm -rf ~/.nix-* 2>/dev/null || true

echo "Cleanup complete. Installing fresh Nix..."

# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

echo "Sourcing Nix environment..."
source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Verify nix works
if ! command -v nix; then
    echo "ERROR: nix command not available after installation"
    exit 1
fi

echo "Setting up dotfiles..."
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone https://github.com/Kamyil/.dotfiles.git "$HOME/.dotfiles"
else
    cd "$HOME/.dotfiles"
    git pull
fi

echo "Bootstrapping nix-darwin..."
cd "$HOME/.dotfiles"
nix run nix-darwin -- switch --flake "./nixos#MacBook-Pro-Kamil"

echo ""
echo "Installation complete!"
echo "RESTART YOUR TERMINAL NOW"
echo ""
echo "After restart, test with:"
echo "  which nix"
echo "  which darwin-rebuild"