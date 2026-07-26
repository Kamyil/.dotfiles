#!/usr/bin/env python3
"""Persistent focus-mode state and Helium native-messaging host."""

import json
import os
import struct
import sys
import time
from pathlib import Path

STATE_DIR = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "quickshell"
STATE_FILE = STATE_DIR / "focus.json"
DEFAULT_DOMAINS = [
    "x.com", "twitter.com", "youtube.com", "youtu.be", "reddit.com",
    "old.reddit.com", "allegro.pl", "olx.pl",
]


def inactive_state(previous_dnd=None):
    state = {"active": False, "endsAt": 0, "label": "", "domains": DEFAULT_DOMAINS}
    if previous_dnd is not None:
        state["restoreDnd"] = bool(previous_dnd)
    return state


def load_state():
    try:
        state = json.loads(STATE_FILE.read_text())
    except (FileNotFoundError, json.JSONDecodeError, OSError):
        return inactive_state()
    if state.get("active") and int(state.get("endsAt", 0)) <= int(time.time()):
        state = inactive_state(state.get("previousDnd", False))
        save_state(state)
    return state


def save_state(state):
    STATE_DIR.mkdir(parents=True, exist_ok=True)
    temporary = STATE_FILE.with_suffix(".tmp")
    temporary.write_text(json.dumps(state, separators=(",", ":")) + "\n")
    os.replace(temporary, STATE_FILE)


def emit(payload):
    print(json.dumps(payload, separators=(",", ":")))


def read_native_message():
    header = sys.stdin.buffer.read(4)
    if len(header) != 4:
        return None
    length = struct.unpack("=I", header)[0]
    if length > 1024 * 1024:
        raise ValueError("native message too large")
    body = sys.stdin.buffer.read(length)
    if len(body) != length:
        return None
    return json.loads(body)


def write_native_message(payload):
    body = json.dumps(payload, separators=(",", ":")).encode()
    sys.stdout.buffer.write(struct.pack("=I", len(body)))
    sys.stdout.buffer.write(body)
    sys.stdout.buffer.flush()


def native_host():
    last_payload = None
    while True:
        payload = json.dumps(load_state(), sort_keys=True)
        if payload != last_payload:
            write_native_message(json.loads(payload))
            last_payload = payload
        # Native hosts are allowed to send unsolicited messages. Keeping the pipe open
        # lets the extension receive timer changes without polling or a local server.
        time.sleep(1)


def main():
    if len(sys.argv) < 2:
        raise SystemExit("usage: focus-control.py {status|start|stop|ack|native}")
    command = sys.argv[1]
    if command == "native":
        native_host()
        return
    if command == "status":
        emit(load_state())
        return
    if command == "start":
        if len(sys.argv) < 5:
            raise SystemExit("start requires seconds, label, and previous DND state")
        seconds = max(60, min(int(sys.argv[2]), 12 * 60 * 60))
        state = {
            "active": True,
            "startedAt": int(time.time()),
            "endsAt": int(time.time()) + seconds,
            "label": sys.argv[3].strip()[:120],
            "previousDnd": sys.argv[4].lower() == "true",
            "domains": DEFAULT_DOMAINS,
        }
        save_state(state)
        emit(state)
        return
    if command == "stop":
        current = load_state()
        state = inactive_state(current.get("previousDnd", False))
        save_state(state)
        emit(state)
        return
    if command == "ack":
        state = load_state()
        state.pop("restoreDnd", None)
        save_state(state)
        emit(state)
        return
    raise SystemExit(f"unknown command: {command}")


if __name__ == "__main__":
    main()
