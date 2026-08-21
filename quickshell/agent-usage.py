#!/usr/bin/env python3
import json
import os
import select
import shutil
import sqlite3
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


def rpc_request(process, request_id, method, params=None, timeout=8):
    process.stdin.write(json.dumps({"id": request_id, "method": method, "params": params or {}}) + "\n")
    process.stdin.flush()
    deadline = time.time() + timeout
    while time.time() < deadline:
        ready, _, _ = select.select([process.stdout], [], [], 0.25)
        if not ready:
            continue
        line = process.stdout.readline()
        if not line:
            break
        try:
            message = json.loads(line)
        except json.JSONDecodeError:
            continue
        if message.get("id") == request_id:
            return message
    raise TimeoutError(method)


def window_label(minutes):
    if minutes == 10080:
        return "Weekly"
    if minutes and minutes % 60 == 0:
        return f"{minutes // 60} hour"
    return "Limit"


def codex_usage():
    result = {"id": "codex", "name": "Codex", "plan": "", "limits": [], "status": ""}
    binary = shutil.which("codex")
    if not binary:
        result["status"] = "Codex CLI not found"
        return result
    process = subprocess.Popen(
        [binary, "-s", "read-only", "-a", "untrusted", "app-server"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    )
    try:
        rpc_request(process, 1, "initialize", {"clientInfo": {"name": "quickshell-agent-usage", "version": "1"}})
        process.stdin.write(json.dumps({"method": "initialized", "params": {}}) + "\n")
        process.stdin.flush()
        account_message = rpc_request(process, 2, "account/read", timeout=4)
        limits_message = rpc_request(process, 3, "account/rateLimits/read", timeout=4)
        account = (account_message.get("result") or {}).get("account") or {}
        limits = (limits_message.get("result") or {}).get("rateLimits") or {}
        result["plan"] = str(limits.get("planType") or account.get("planType") or account.get("type") or "")
        for value in (limits.get("primary"), limits.get("secondary")):
            if not isinstance(value, dict) or value.get("usedPercent") is None:
                continue
            reset = value.get("resetsAt")
            result["limits"].append({
                "label": window_label(value.get("windowDurationMins")),
                "percent": float(value["usedPercent"]),
                "resetsAt": datetime.fromtimestamp(float(reset), timezone.utc).isoformat() if reset else "",
            })
    except Exception as error:
        result["status"] = f"Limits unavailable: {error}"
    finally:
        process.terminate()
        try:
            process.wait(timeout=1)
        except subprocess.TimeoutExpired:
            process.kill()
    return result


def opencode_db():
    data_home = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
    return data_home / "opencode/opencode.db"


def local_go_cost(db, start_ms):
    if not db.exists():
        return 0.0
    connection = sqlite3.connect(f"file:{db}?mode=ro", uri=True)
    try:
        query = """
            SELECT COALESCE(SUM(CAST(json_extract(data, '$.cost') AS REAL)), 0)
            FROM part
            WHERE time_created >= ?
              AND json_extract(data, '$.type') = 'step-finish'
              AND COALESCE(json_extract(data, '$.providerID'), json_extract(data, '$.providerId'), '') IN ('opencode', 'opencode-go')
        """
        return float(connection.execute(query, (start_ms,)).fetchone()[0] or 0)
    except sqlite3.Error:
        return 0.0
    finally:
        connection.close()


def opencode_go_usage():
    now = time.time()
    windows = [
        ("5 hour", 5 * 3600, 12.0),
        ("Weekly", 7 * 86400, 30.0),
        ("Monthly", 30 * 86400, 60.0),
    ]
    db = opencode_db()
    limits = []
    for label, seconds, allowance in windows:
        spent = local_go_cost(db, int((now - seconds) * 1000))
        limits.append({
            "label": label,
            "percent": min(100.0, spent / allowance * 100.0),
            "detail": f"${spent:.2f} / ${allowance:.0f}",
            "estimated": True,
        })
    status = "Local estimate from OpenCode history"
    if not db.exists():
        status = "No local OpenCode usage history"
    return {"id": "opencode-go", "name": "OpenCode Go", "plan": "Go", "limits": limits, "status": status}


def main():
    print(json.dumps({"updatedAt": datetime.now(timezone.utc).isoformat(), "providers": [codex_usage(), opencode_go_usage()]}))


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        sys.exit(0)
