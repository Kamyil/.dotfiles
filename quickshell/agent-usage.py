#!/usr/bin/env python3
import json
import select
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone


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


GO_WINDOW_ALLOWANCE = {"5h": 12.0, "7d": 30.0, "monthly": 60.0}


def omp_usage_report(provider, timeout=30):
    binary = shutil.which("omp")
    if not binary:
        raise RuntimeError("omp not found")
    process = subprocess.run(
        [binary, "usage", "--json", "--provider", provider],
        capture_output=True,
        text=True,
        timeout=timeout,
    )
    if process.returncode != 0:
        raise RuntimeError(process.stderr.strip() or f"omp usage exited {process.returncode}")
    reports = (json.loads(process.stdout) or {}).get("reports") or []
    return reports[0] if reports else None


def opencode_go_usage():
    result = {"id": "opencode-go", "name": "OpenCode Go", "plan": "Go", "limits": [], "status": ""}
    try:
        report = omp_usage_report("opencode-go")
    except (OSError, subprocess.SubprocessError, json.JSONDecodeError, RuntimeError) as error:
        result["status"] = f"Usage unavailable: {error}"
        return result
    if not report:
        result["status"] = "No OpenCode Go account configured"
        return result
    for limit in report.get("limits") or []:
        amount = limit.get("amount") or {}
        fraction = amount.get("usedFraction")
        if fraction is None:
            continue
        window = limit.get("window") or {}
        entry = {
            "label": window.get("label") or limit.get("label") or "Limit",
            "percent": round(max(0.0, min(1.0, float(fraction))) * 100.0, 1),
        }
        resets = window.get("resetsAt")
        if resets:
            entry["resetsAt"] = datetime.fromtimestamp(resets / 1000, timezone.utc).isoformat()
        allowance = GO_WINDOW_ALLOWANCE.get(window.get("id"))
        if allowance:
            used = float(fraction) * allowance
            entry["detail"] = f"{entry['percent']:.1f}% · ${used:.2f} / ${allowance:.0f}"
        result["limits"].append(entry)
    if not result["limits"]:
        result["status"] = "No usage reported"
    return result


def main():
    print(json.dumps({"updatedAt": datetime.now(timezone.utc).isoformat(), "providers": [codex_usage(), opencode_go_usage()]}))


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        sys.exit(0)
