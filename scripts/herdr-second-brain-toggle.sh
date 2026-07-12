#!/usr/bin/env python3
"""Toggle between the current herdr workspace and the second-brain workspace.

- If already in second-brain → focus the workspace saved in the state file.
- Otherwise → save current workspace, focus second-brain (create + launch nvim if absent).
"""
import json
import os
import pathlib
import subprocess

LABEL = "second-brain"
DIR = os.path.expanduser("~/second-brain")
STATE = pathlib.Path(
    os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state"))
) / "herdr" / "second-brain-prev"
STATE.parent.mkdir(parents=True, exist_ok=True)
STATE_PREV = 0  # line index for previous workspace ID
STATE_SB = 1    # line index for cached sb workspace ID


def herdr(*args: str) -> dict:
    raw = subprocess.check_output(["herdr", *args]).decode()
    return json.loads(raw)


def run(*args: str) -> None:
    subprocess.run(["herdr", *args], check=True)


def main() -> None:
    data = herdr("workspace", "list")
    workspaces = data["result"]["workspaces"]

    cur_id = cur_label = sb_id = ""
    for ws in workspaces:
        label = ws.get("label", "")
        if ws.get("focused"):
            cur_id = ws["workspace_id"]
            cur_label = label
        if label == LABEL:
            sb_id = ws["workspace_id"]

    state = STATE.read_text().splitlines() if STATE.exists() else ["", ""]

    # Already in second-brain → go back to previous workspace
    if cur_label == LABEL:
        prev = state[STATE_PREV] if len(state) > STATE_PREV else ""
        if prev:
            run("workspace", "focus", prev)
        return

    # Save current workspace and cached sb_id, then focus second-brain
    STATE.write_text(f"{cur_id}\n{sb_id}\n")

    if sb_id:
        run("workspace", "focus", sb_id)
        return

    # Create workspace and launch nvim
    created = herdr("workspace", "create", "--cwd", DIR, "--label", LABEL, "--no-focus")
    new_id = created["result"]["workspace"]["workspace_id"]
    root_pane = created["result"]["root_pane"]["pane_id"]
    STATE.write_text(f"{cur_id}\n{new_id}\n")
    run("pane", "run", root_pane, "nvim .")
    run("workspace", "focus", new_id)


if __name__ == "__main__":
    main()
