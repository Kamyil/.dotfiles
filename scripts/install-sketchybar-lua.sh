#!/bin/bash

# Script to build and install SketchyBar Lua module
set -e

INSTALL_DIR="$HOME/.local/share/sketchybar_lua"
BUILD_DIR="$HOME/.cache/sketchybar-lua-build"

echo "Building SketchyBar Lua module..."

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$BUILD_DIR"

# Clone the repository if it doesn't exist
if [ ! -d "$BUILD_DIR/SketchyBar" ]; then
    echo "Cloning SketchyBar repository..."
    git clone https://github.com/FelixKratz/SketchyBar.git "$BUILD_DIR/SketchyBar"
fi

cd "$BUILD_DIR/SketchyBar"

# Check if there's a Lua module to build
if [ -f "src/sketchybar.c" ] && [ -d "src" ]; then
    echo "Building Lua module..."
    
    # Try to build the Lua module
    # This might need adjustment based on the actual build process
    if command -v make >/dev/null; then
        if [ -f "Makefile" ]; then
            # Check if there's a lua target
            if grep -q "lua" Makefile; then
                make lua && cp *.so "$INSTALL_DIR/"
            else
                echo "No Lua target found in Makefile"
                echo "Attempting manual build..."
                # Manual build attempt (this is speculative)
                gcc -shared -fPIC -I/opt/homebrew/include/lua5.2 src/sketchybar.c -o "$INSTALL_DIR/sketchybar.so" -llua 2>/dev/null || echo "Manual build failed"
            fi
        fi
    fi
fi

if [ -f "$INSTALL_DIR/sketchybar.so" ]; then
    echo "✅ SketchyBar Lua module installed successfully!"
    echo "Location: $INSTALL_DIR/sketchybar.so"
else
    echo "❌ Failed to build SketchyBar Lua module"
    echo "You may need to build it manually or use the shell-based configuration"
fi