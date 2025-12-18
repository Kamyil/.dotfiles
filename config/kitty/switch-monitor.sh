#!/usr/bin/env bash
# Helper script to switch Kitty font rendering based on monitor

KITTY_CONFIG="$HOME/.config/kitty/kitty.conf"
RETINA_INCLUDE='include font-rendering-retina.conf'
EXTERNAL_INCLUDE='include font-rendering-external.conf'

case "$1" in
  retina|mac|laptop)
    echo "Switching to Retina (MacBook) font rendering..."
    sed -i.bak "s|include font-rendering-.*\.conf|$RETINA_INCLUDE|g" "$KITTY_CONFIG"
    ;;
  external|monitor|fullhd)
    echo "Switching to External Monitor (FullHD) font rendering..."
    sed -i.bak "s|include font-rendering-.*\.conf|$EXTERNAL_INCLUDE|g" "$KITTY_CONFIG"
    ;;
  *)
    echo "Usage: $0 {retina|external}"
    echo "  retina   - Use settings for MacBook built-in display"
    echo "  external - Use settings for external FullHD monitor"
    exit 1
    ;;
esac

# Reload all kitty instances
if command -v kitty &> /dev/null; then
  kitty @ --to unix:/tmp/kitty load-config 2>/dev/null || echo "Note: Restart Kitty to apply changes"
fi

echo "Font rendering switched! Reload Kitty config or restart Kitty."
