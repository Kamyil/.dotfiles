#!/usr/bin/env python3
"""
Live markdown preview using Kitty's text sizing protocol (OSC 66).
Watches a file for changes and re-renders on each modification.

Usage:
    kitty-markdown-live.py <file.md>
"""

import sys
import os
import re
import time


HEADING_RE = re.compile(r'^(#{1,6})\s+(.*)')


def heading_scale(level: int) -> int:
    """Map markdown heading level (1-6) to Kitty text sizing scale (2-6)."""
    return max(2, 7 - level)


def render(text: str) -> str:
    """Render markdown text with Kitty OSC 66 text-sized headings."""
    parts = []
    for line in text.split('\n'):
        m = HEADING_RE.match(line)
        if m:
            level = len(m.group(1))
            heading = m.group(2)
            scale = heading_scale(level)
            parts.append(f'\033]66;s={scale};{heading}\a')
            # Fill remaining rows of the multicell block
            parts.extend([''] * (scale - 1))
        else:
            parts.append(line)
    return '\n'.join(parts)


def main() -> None:
    if len(sys.argv) < 2:
        print(f'Usage: {sys.argv[0]} <file.md>', file=sys.stderr)
        sys.exit(1)

    path = sys.argv[1]
    last_mtime: float = 0

    while True:
        try:
            mtime = os.path.getmtime(path)
        except OSError:
            time.sleep(0.5)
            continue

        if mtime != last_mtime:
            last_mtime = mtime
            try:
                with open(path, encoding='utf-8') as f:
                    text = f.read()
            except OSError:
                time.sleep(0.5)
                continue

            # Clear terminal and re-render from top
            sys.stdout.write('\033[2J\033[H')
            sys.stdout.write(render(text))
            sys.stdout.flush()

        time.sleep(0.3)


if __name__ == '__main__':
    main()
