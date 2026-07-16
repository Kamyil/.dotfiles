#!/usr/bin/env python3
"""Refresh Herdr workspace metadata with local Git and GitHub PR status."""

from __future__ import annotations

import argparse
import fcntl
import json
import shutil
import subprocess
import time
from pathlib import Path

SOURCE = "dotfiles:git-pr"
TOKENS = ("icon", "pr", "diff")


def run(command: list[str], cwd: Path) -> str:
    result = subprocess.run(
        command,
        cwd=cwd,
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        return ""
    return result.stdout.strip()
PROJECT_ICONS = (
    (("flake.nix",), ""),
    (("Cargo.toml",), ""),
    (("package.json", "bun.lock", "bun.lockb"), ""),
    (("pyproject.toml", "requirements.txt", "uv.lock"), ""),
    (("go.mod",), ""),
    (("mix.exs",), ""),
)


def project_icon(repo: Path) -> str:
    for markers, icon in PROJECT_ICONS:
        if any((repo / marker).exists() for marker in markers):
            return icon
    return ""


def token_values(repo: Path) -> dict[str, str]:
    branch = run(["git", "branch", "--show-current"], repo)
    diff = run(["git", "diff", "--shortstat"], repo)
    staged = run(["git", "diff", "--cached", "--shortstat"], repo)
    if staged:
        diff = f"{diff}; staged {staged}" if diff else f"staged {staged}"

    values: dict[str, str] = {}
    icon = project_icon(repo)
    if icon:
        values["icon"] = icon
    if diff:
        values["diff"] = diff

    if branch and shutil.which("gh"):
        raw_pr = run(
            [
                "gh",
                "pr",
                "view",
                "--json",
                "number,state,title",
                "--jq",
                r'"#\(.number) \(.state) \(.title)"',
            ],
            repo,
        )
        if raw_pr:
            values["pr"] = raw_pr


    return values


def report(workspace_id: str, values: dict[str, str]) -> bool:
    command = [
        "herdr",
        "workspace",
        "report-metadata",
        workspace_id,
        "--source",
        SOURCE,
        "--ttl-ms",
        "90000",
    ]
    for token in TOKENS:
        if token in values:
            command.extend(["--token", f"{token}={values[token]}"])
        else:
            command.extend(["--clear-token", token])
    result = subprocess.run(command, text=True, capture_output=True, check=False)
    return result.returncode == 0


def workspace_exists(workspace_id: str) -> bool:
    result = subprocess.run(
        ["herdr", "workspace", "get", workspace_id],
        text=True,
        capture_output=True,
        check=False,
    )
    return result.returncode == 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--workspace-id", required=True)
    parser.add_argument("--path", type=Path, required=True)
    parser.add_argument("--interval", type=float, default=30.0)
    parser.add_argument("--once", action="store_true")
    args = parser.parse_args()
    lock_path = Path(f"/tmp/herdr-status-{args.workspace_id}.lock")
    lock_file = lock_path.open("w")
    try:
        fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        return 0


    repo = args.path.expanduser().resolve()
    if not (repo / ".git").exists():
        raise SystemExit(f"Not a Git repository: {repo}")

    while True:
        if not workspace_exists(args.workspace_id):
            return 0
        values = token_values(repo)
        if not report(args.workspace_id, values):
            return 1
        print(json.dumps({"workspace_id": args.workspace_id, **values}), flush=True)
        if args.once:
            return 0
        time.sleep(max(args.interval, 5.0))


if __name__ == "__main__":
    raise SystemExit(main())
