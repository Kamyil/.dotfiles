#!/usr/bin/env python3

import os
import subprocess

from kitty.fast_data_types import Screen, get_boss
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from kitty.utils import color_as_int

ICON_GIT = ""

LEFT_SEP = "▌"
RIGHT_SEP = "▐"

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

    if index == 1 and active_session:
        session_color = as_rgb(_get_session_color(active_session))
        screen.cursor.bg = default_bg
        screen.cursor.fg = session_color
        screen.draw(f" {active_session} │")

    if tab.is_active:
        if session_name:
            tab_bg = as_rgb(_get_session_color(session_name))
        else:
            tab_bg = as_rgb(color_as_int(draw_data.active_bg))
        tab_fg = as_rgb(color_as_int(draw_data.active_fg))
    else:
        tab_bg = as_rgb(color_as_int(draw_data.inactive_bg))
        tab_fg = as_rgb(color_as_int(draw_data.inactive_fg))

    if screen.cursor.x > 0:
        screen.cursor.bg = default_bg
        screen.cursor.fg = default_bg
        screen.draw("  ")

    screen.cursor.bg = default_bg
    screen.cursor.fg = tab_bg
    screen.draw(LEFT_SEP)

    screen.cursor.bg = tab_bg
    screen.cursor.fg = tab_fg

    panes_info = _get_all_panes_info(tab.tab_id)
    content = f"  {index}: {panes_info}  "
    screen.draw(content)

    extra = screen.cursor.x - before - max_tab_length
    if extra > 0:
        screen.cursor.x -= extra + 1
        screen.draw("…")

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

    if is_last and end < screen.columns:
        screen.cursor.bg = default_bg
        screen.cursor.fg = 0
        screen.draw(" ")

    return end
