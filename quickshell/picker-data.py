#!/usr/bin/env python3
import base64
import mimetypes
import os
import pathlib
import subprocess
import sys
import unicodedata

MODE = sys.argv[1] if len(sys.argv) > 1 else ""
ACTION = sys.argv[2] if len(sys.argv) > 2 else "list"
VALUE = sys.argv[3] if len(sys.argv) > 3 else ""

def emit(value: str, label: str) -> None:
    print(value.replace("\t", " ").replace("\n", " ") + "\t" + label.replace("\t", " ").replace("\n", " "))

if ACTION == "list":
    if MODE == "clipboard":
        try:
            result = subprocess.run(["cliphist", "list"], text=True, capture_output=True, check=True)
            for line in result.stdout.splitlines()[:500]:
                ident, _, preview = line.partition("\t")
                if ident:
                    emit(base64.urlsafe_b64encode(line.encode()).decode(), preview or "Clipboard entry")
        except (OSError, subprocess.CalledProcessError):
            pass
    elif MODE == "emoji":
        for start, end in ((0x2600, 0x27BF), (0x1F300, 0x1FAFF)):
            for codepoint in range(start, end + 1):
                char = chr(codepoint)
                try:
                    name = unicodedata.name(char)
                except ValueError:
                    continue
                emit(char, name.title())
    elif MODE == "image":
        root = pathlib.Path.home() / "Pictures"
        suffixes = {".png", ".jpg", ".jpeg", ".webp", ".gif"}
        files = [path for path in root.rglob("*") if path.is_file() and path.suffix.lower() in suffixes] if root.exists() else []
        for path in sorted(files, key=lambda item: item.stat().st_mtime, reverse=True)[:500]:
            emit(str(path), path.name)
elif ACTION == "select":
    if MODE == "clipboard":
        decoded = subprocess.run(["cliphist", "decode"], input=base64.urlsafe_b64decode(VALUE), capture_output=True, check=True)
        subprocess.run(["wl-copy"], input=decoded.stdout, check=True)
    elif MODE == "emoji":
        subprocess.run(["wl-copy"], input=VALUE.encode(), check=True)
    elif MODE == "image":
        mime = mimetypes.guess_type(VALUE)[0] or "application/octet-stream"
        with open(VALUE, "rb") as image:
            subprocess.run(["wl-copy", "--type", mime], stdin=image, check=True)
