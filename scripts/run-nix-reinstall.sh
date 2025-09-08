#!/bin/bash

# Download and run script with proper stdin
echo "Downloading Nix reinstallation script..."

# Download the script
curl -L https://raw.githubusercontent.com/Kamyil/.dotfiles/main/scripts/simple-nix-reinstall.sh -o /tmp/nix-reinstall.sh

# Make it executable
chmod +x /tmp/nix-reinstall.sh

# Run it with proper stdin
echo "Running installation script..."
/tmp/nix-reinstall.sh

# Clean up
rm -f /tmp/nix-reinstall.sh