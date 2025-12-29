#!/usr/bin/env python3
"""
Custom Kitty Tab Bar
- Rounded pill-style tabs
- Folder name (not full path)
- Git branch with icon
- Session-based colors
"""

import os
import subprocess

from kitty.fast_data_types import Screen, get_options
from kitty.tab_bar import DrawData, ExtraData, TabBarData, TabAccessor, as_rgb
from kitty.utils import color_as_int

# Nerd Font Icons
ICON_GIT = ""  # git branch

# Tab separators - boxy style (half blocks)
LEFT_SEP = "▌"   # left half block U+258C
RIGHT_SEP = "▐"  # right half block U+2590

# Session color palette (MHFU warm wood/earth tones only)
SESSION_COLORS = [
    0x9a7050,  # wood brown (default)
    0xb89060,  # wood highlight
    0x8a6a4a,  # dark wood
    0xc4a860,  # stamina yellow
    0xa85a5a,  # steak red
    0x7a9a6a,  # health green
    0x6a5a4a,  # deep wood
    0xd4a870,  # light wood
]


def _get_session_color(session_name: str) -> int:
    if not session_name:
        return SESSION_COLORS[0]
    return SESSION_COLORS[hash(session_name) % len(SESSION_COLORS)]


# Git paths to try (nix-darwin path first, then common locations)
GIT_PATHS = [
    "/etc/profiles/per-user/kamil/bin/git",
    "/usr/local/bin/git",
    "/usr/bin/git",
    "/opt/homebrew/bin/git",
]


def _find_git() -> str:
    for path in GIT_PATHS:
        if os.path.isfile(path):
            return path
    return "git"  # fallback to PATH


GIT_CMD = _find_git()


def _get_git_branch(cwd: str) -> str:
    """Get git branch - no caching for debugging."""
    if not cwd or not os.path.isdir(cwd):
        return ""
    try:
        result = subprocess.run(
            [GIT_CMD, "rev-parse", "--abbrev-ref", "HEAD"],
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=0.5,
        )
        if result.returncode == 0:
            branch = result.stdout.strip()
            if len(branch) > 18:
                return branch[:15] + "..."
            return branch
    except Exception:
        pass
    return ""


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """Custom tab drawing function."""

    # Get working directory and extract folder name
    ta = TabAccessor(tab.tab_id)
    cwd = ta.active_wd or ""
    folder_name = os.path.basename(cwd) if cwd else ""

    # Get git branch
    git_branch = _get_git_branch(cwd)

    # Determine colors
    default_bg = as_rgb(color_as_int(draw_data.default_bg))
    session_name = getattr(tab, 'session_name', '') or ''

    if tab.is_active:
        if session_name:
            tab_bg = as_rgb(_get_session_color(session_name))
        else:
            tab_bg = as_rgb(color_as_int(draw_data.active_bg))
        tab_fg = as_rgb(color_as_int(draw_data.active_fg))
    else:
        tab_bg = as_rgb(color_as_int(draw_data.inactive_bg))
        tab_fg = as_rgb(color_as_int(draw_data.inactive_fg))

    # === Draw left separator ===
    # Gap between tabs (or before first tab)
    if screen.cursor.x > 0:
        screen.cursor.bg = default_bg
        screen.cursor.fg = default_bg
        screen.draw("  ")
    # Left edge of tab
    screen.cursor.bg = default_bg
    screen.cursor.fg = tab_bg
    screen.draw(LEFT_SEP)

    # === Draw tab content ===
    screen.cursor.bg = tab_bg
    screen.cursor.fg = tab_fg

    # Build content: " 1: folder_name  branch "
    # Use folder name, fall back to session name or "shell"
    display_name = folder_name or session_name or "shell"
    if len(display_name) > 12:
        display_name = display_name[:9] + "..."

    content = f"  {index}: {display_name}"

    # Add git branch if present
    if git_branch:
        content += f" {ICON_GIT} {git_branch}"

    content += "  "
    screen.draw(content)

    # Handle overflow
    extra = screen.cursor.x - before - max_tab_length
    if extra > 0:
        screen.cursor.x -= extra + 1
        screen.draw("…")

    # === Draw right separator ===
    # Determine next tab's background
    next_tab = extra_data.next_tab
    if is_last or not next_tab:
        next_bg = default_bg
    else:
        if next_tab.is_active:
            next_session = getattr(next_tab, 'session_name', '') or ''
            if next_session:
                next_bg = as_rgb(_get_session_color(next_session))
            else:
                next_bg = as_rgb(color_as_int(draw_data.active_bg))
        else:
            next_bg = as_rgb(color_as_int(draw_data.inactive_bg))

    screen.cursor.fg = tab_bg
    screen.cursor.bg = next_bg
    screen.draw(RIGHT_SEP)

    end = screen.cursor.x

    # Add space after last tab
    if is_last and end < screen.columns:
        screen.cursor.bg = default_bg
        screen.cursor.fg = 0
        screen.draw(" ")

    return end
