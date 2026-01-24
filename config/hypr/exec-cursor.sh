#!/usr/bin/env bash
# Set cursor theme explicitly for all Wayland apps

# GTK cursor theme
export XCURSOR_THEME=capitaine-cursors
export XCURSOR_SIZE=24

# Hyprland-specific
hyprctl setcursor capitaine-cursors 24 2>/dev/null || true

# Qt applications
export QT_QPA_PLATFORMTHEME=gtk3

# Ensure GTK settings are applied
gsettings set org.gnome.desktop.interface cursor-theme "capitaine-cursors" 2>/dev/null || true
gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
