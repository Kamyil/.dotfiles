#!/usr/bin/env python3

import os
import subprocess

from kitty.fast_data_types import Screen, get_boss
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from kitty.utils import color_as_int

ICON_GIT = ""

# MHFU-style hexagonal/diamond tab separators
# Inspired by Monster Hunter Freedom Unite item selection UI
#
# Active tab design:   ◆━━━━━━━━━━◆
#                      ┃  content  ┃
#                      ◆━━━━━━━━━━◆
#
# Using diamond shapes to evoke the carved item slots

# Diamond/hex separators for the ornate look
LEFT_CAP_ACTIVE = "◆┃"
RIGHT_CAP_ACTIVE = "┃◆"
LEFT_CAP_INACTIVE = "◇│"
RIGHT_CAP_INACTIVE = "│◇"

# Decorative rivets for the bar edges
RIVET = "•"
BORDER_H = "━"
BORDER_V = "┃"

# Legacy separators (kept for reference)
LEFT_SEP = "◀"
RIGHT_SEP = "▶"

SESSION_COLORS = [
    0x9a7050,
    0xb89060,
    0x8a6a4a,
    0xc4a860,
    0xa85a5a,
    0x7a9a6a,
    0x6a5a4a,
    0xd4a870,
]

GIT_PATHS = [
    "/etc/profiles/per-user/kamil/bin/git",
    "/usr/local/bin/git",
    "/usr/bin/git",
    "/opt/homebrew/bin/git",
]


def _get_session_color(session_name: str) -> int:
    if not session_name:
        return SESSION_COLORS[0]
    return SESSION_COLORS[hash(session_name) % len(SESSION_COLORS)]


def _find_git() -> str:
    for path in GIT_PATHS:
        if os.path.isfile(path):
            return path
    return "git"


GIT_CMD = _find_git()


def _get_git_branch(cwd: str) -> str:
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


def _get_pane_info(cwd: str) -> str:
    folder_name = os.path.basename(cwd) if cwd else "shell"
    if len(folder_name) > 12:
        folder_name = folder_name[:9] + "..."
    
    git_branch = _get_git_branch(cwd)
    if git_branch:
        return f"{folder_name} {ICON_GIT} {git_branch}"
    return folder_name


def _get_all_panes_info(tab_id: int) -> str:
    boss = get_boss()
    tab = boss.tab_for_id(tab_id)
    if not tab:
        return "shell"
    
    windows = list(tab)
    if len(windows) == 0:
        return "shell"
    
    pane_infos = []
    for window in windows:
        cwd = window.get_cwd_of_child() or ""
        pane_infos.append(_get_pane_info(cwd))
    
    if len(pane_infos) == 1:
        return pane_infos[0]
    
    return " | ".join(pane_infos)


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
    default_bg = as_rgb(color_as_int(draw_data.default_bg))
    session_name = getattr(tab, 'session_name', '') or ''
    active_session = getattr(tab, 'active_session_name', '') or session_name
    
    # MHFU color palette additions
    border_color = as_rgb(0x6a5040)  # wood_dark - ornate border
    rivet_color = as_rgb(0xc4a860)   # stamina_bar - golden rivets
    diamond_active = as_rgb(0xb89060)  # wood_light - glowing diamond
    diamond_inactive = as_rgb(0x4a4038)  # dimmed diamond

    # Draw session indicator with decorative border on first tab
    if index == 1:
        screen.cursor.bg = default_bg
        screen.cursor.fg = rivet_color
        screen.draw(f"{RIVET}")
        if active_session:
            session_color = as_rgb(_get_session_color(active_session))
            screen.cursor.fg = session_color
            screen.draw(f" {active_session} ")
        screen.cursor.fg = rivet_color
        screen.draw(f"{RIVET} ")

    if tab.is_active:
        if session_name:
            tab_bg = as_rgb(_get_session_color(session_name))
        else:
            tab_bg = as_rgb(color_as_int(draw_data.active_bg))
        tab_fg = as_rgb(color_as_int(draw_data.active_fg))
        left_cap = LEFT_CAP_ACTIVE
        right_cap = RIGHT_CAP_ACTIVE
        diamond_color = diamond_active
    else:
        tab_bg = as_rgb(color_as_int(draw_data.inactive_bg))
        tab_fg = as_rgb(color_as_int(draw_data.inactive_fg))
        left_cap = LEFT_CAP_INACTIVE
        right_cap = RIGHT_CAP_INACTIVE
        diamond_color = diamond_inactive

    # Spacing between tabs
    if screen.cursor.x > 0:
        screen.cursor.bg = default_bg
        screen.cursor.fg = border_color
        screen.draw(" ")

    # Draw left diamond cap ◆┃ or ◇│
    screen.cursor.bg = default_bg
    screen.cursor.fg = diamond_color
    screen.draw(left_cap[0])  # Diamond
    screen.cursor.fg = border_color
    screen.cursor.bg = tab_bg
    screen.draw(left_cap[1])  # Border line

    # Tab content
    screen.cursor.bg = tab_bg
    screen.cursor.fg = tab_fg

    panes_info = _get_all_panes_info(tab.tab_id)
    content = f" {index}: {panes_info} "
    screen.draw(content)

    # Truncate if needed
    extra = screen.cursor.x - before - max_tab_length
    if extra > 0:
        screen.cursor.x -= extra + 1
        screen.draw("…")

    # Draw right diamond cap ┃◆ or │◇
    screen.cursor.fg = border_color
    screen.cursor.bg = default_bg
    screen.draw(right_cap[0])  # Border line
    screen.cursor.fg = diamond_color
    screen.draw(right_cap[1])  # Diamond

    end = screen.cursor.x

    # Fill remaining space on last tab
    if is_last and end < screen.columns:
        screen.cursor.bg = default_bg
        screen.cursor.fg = rivet_color
        # Add trailing rivet decoration
        screen.draw(f" {RIVET}")

    return end
