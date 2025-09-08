#!/bin/bash

echo "Complete Nix Removal Script for macOS"
echo "This will remove ALL Nix components from your system"
echo ""
echo "Type 'DELETE' to continue:"
read answer

if [ "$answer" != "DELETE" ]; then
    echo "Cancelled"
    exit 1
fi

echo "Starting complete Nix removal..."

# Stop all nix services
echo "Stopping nix services..."
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
sudo launchctl remove org.nixos.nix-daemon 2>/dev/null || true

# Remove daemon plist
echo "Removing daemon configuration..."
sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist

# Remove all nix users
echo "Removing nix users..."
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32; do
    sudo dscl . -delete /Users/_nixbld$i 2>/dev/null || true
done

# Remove nix group
sudo dscl . -delete /Groups/nixbld 2>/dev/null || true

# Unmount and remove ALL nix volumes
echo "Removing Nix volumes..."
sudo diskutil unmount force /nix 2>/dev/null || true

# Find and remove all APFS volumes with "nix" in the name
diskutil list | grep -i nix | awk '{print $NF}' | while read volume; do
    if [ ! -z "$volume" ]; then
        echo "Removing volume: $volume"
        sudo diskutil apfs deleteVolume "$volume" 2>/dev/null || true
    fi
done

# Remove nix directories
echo "Removing nix directories..."
sudo rm -rf /nix
sudo rm -rf /etc/nix
sudo rm -rf /var/root/.nix-*
rm -rf ~/.nix-*

# Clean up shell profiles
echo "Cleaning shell configurations..."
if [ -f ~/.zshrc ]; then
    # Remove nix-related lines
    sed -i '' '/# Nix/d' ~/.zshrc 2>/dev/null || true
    sed -i '' '/nix-daemon/d' ~/.zshrc 2>/dev/null || true
    sed -i '' '/\/nix\/var\/nix/d' ~/.zshrc 2>/dev/null || true
    sed -i '' '/export NIX_/d' ~/.zshrc 2>/dev/null || true
fi

if [ -f ~/.bash_profile ]; then
    sed -i '' '/# Nix/d' ~/.bash_profile 2>/dev/null || true
    sed -i '' '/nix-daemon/d' ~/.bash_profile 2>/dev/null || true
    sed -i '' '/\/nix\/var\/nix/d' ~/.bash_profile 2>/dev/null || true
    sed -i '' '/export NIX_/d' ~/.bash_profile 2>/dev/null || true
fi

if [ -f ~/.bashrc ]; then
    sed -i '' '/# Nix/d' ~/.bashrc 2>/dev/null || true
    sed -i '' '/nix-daemon/d' ~/.bashrc 2>/dev/null || true
    sed -i '' '/\/nix\/var\/nix/d' ~/.bashrc 2>/dev/null || true
    sed -i '' '/export NIX_/d' ~/.bashrc 2>/dev/null || true
fi

# Remove system shell backups
sudo rm -f /etc/zshrc.backup-before-nix
sudo rm -f /etc/bashrc.backup-before-nix
sudo rm -f /etc/bash.bashrc.backup-before-nix

# Remove synthetic.conf entries
echo "Cleaning synthetic.conf..."
if [ -f /etc/synthetic.conf ]; then
    sudo sed -i '' '/^nix/d' /etc/synthetic.conf 2>/dev/null || true
fi

# Remove fstab entries
echo "Cleaning fstab..."
if [ -f /etc/fstab ]; then
    sudo sed -i '' '/nix/d' /etc/fstab 2>/dev/null || true
fi

# Check for any remaining nix references
echo ""
echo "Checking for remaining nix references..."
echo "Volumes:"
diskutil list | grep -i nix || echo "No nix volumes found"

echo ""
echo "Processes:"
ps aux | grep nix | grep -v grep || echo "No nix processes found"

echo ""
echo "Files in /nix:"
ls -la /nix 2>/dev/null || echo "No /nix directory found"

echo ""
echo "=== Nix removal complete! ==="
echo ""
echo "You should now:"
echo "1. Restart your terminal"
echo "2. Reboot your Mac (recommended)"
echo "3. Verify removal with: ls /nix"
echo "4. Then install fresh with Determinate Nix installer"