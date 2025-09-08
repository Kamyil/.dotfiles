#!/usr/bin/env bash
set -euo pipefail

main() {
    echo "=== Nix Complete Reinstallation ==="
    echo "This will remove and reinstall Nix completely"
    echo ""
    
    confirm_installation
    cleanup_nix
    install_fresh_nix
    setup_darwin
    
    echo ""
    echo "=== Installation Complete ==="
    echo "RESTART YOUR TERMINAL NOW"
}

confirm_installation() {
    echo "Continue with reinstallation? (y/N): "
    read response
    if [ "$response" = "y" ] || [ "$response" = "Y" ] || [ "$response" = "yes" ] || [ "$response" = "YES" ]; then
        echo "Proceeding with installation..."
    else
        echo "Installation cancelled"
        exit 1
    fi
}

cleanup_nix() {
    echo "Cleaning up existing Nix installation..."
    
    # Stop services
    sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist 2>/dev/null || true
    sudo launchctl remove org.nixos.nix-daemon 2>/dev/null || true
    
    # Remove daemon plist
    sudo rm -f /Library/LaunchDaemons/org.nixos.nix-daemon.plist
    
    # Remove users
    for i in $(seq 1 32); do
        sudo dscl . -delete /Users/_nixbld$i 2>/dev/null || true
    done
    sudo dscl . -delete /Groups/nixbld 2>/dev/null || true
    
    # Remove volume
    sudo diskutil unmount force /nix 2>/dev/null || true
    sudo diskutil apfs deleteVolume /nix 2>/dev/null || true
    
    # Remove directories
    sudo rm -rf /nix /etc/nix ~/.nix-* 2>/dev/null || true
    
    # Clean shell profiles
    if [ -f ~/.zshrc ]; then
        sed -i '' '/# Nix/d' ~/.zshrc 2>/dev/null || true
        sed -i '' '/nix-daemon/d' ~/.zshrc 2>/dev/null || true
    fi
    
    echo "Cleanup completed"
}

install_fresh_nix() {
    echo "Installing fresh Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Source environment
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    else
        echo "ERROR: Nix installation failed"
        exit 1
    fi
    
    # Verify
    if ! command -v nix >/dev/null 2>&1; then
        echo "ERROR: nix command not available"
        exit 1
    fi
    
    echo "Nix installation completed"
}

setup_darwin() {
    echo "Setting up nix-darwin..."
    
    # Get dotfiles
    if [ ! -d "$HOME/.dotfiles" ]; then
        git clone https://github.com/Kamyil/.dotfiles.git "$HOME/.dotfiles"
    else
        cd "$HOME/.dotfiles" && git pull
    fi
    
    # Bootstrap
    cd "$HOME/.dotfiles"
    nix run nix-darwin -- switch --flake "./nixos#MacBook-Pro-Kamil"
    
    echo "nix-darwin setup completed"
}

main "$@"