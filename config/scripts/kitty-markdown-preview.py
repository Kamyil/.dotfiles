#!/usr/bin/env python3
"""
Markdown preview using Kitty's text sizing protocol (OSC 66, kitty >= 0.40.0).
Reads markdown from stdin, renders headings at proportionally larger font sizes.

Usage:
    cat README.md | kitty-markdown-preview.py
    nvim --headless -c '%print' -c 'qa!' file.md 2>/dev/null | kitty-markdown-preview.py

Heading scale map:
    h1 (#)   -> s=6  (6x base font size)
    h2 (##)  -> s=5
    h3 (###) -> s=4
    h4 (####)-> s=3
    h5 (#####)-> s=2
    h6 (######)-> s=2
"""

import sys
import re


HEADING_RE = re.compile(r'^(#{1,6})\s+(.*)')


def heading_scale(level: int) -> int:
    """Map markdown heading level (1-6) to Kitty text sizing scale (2-6)."""
    return max(2, 7 - level)


def emit_heading(text: str, scale: int) -> None:
    """Emit a heading using Kitty OSC 66 text sizing protocol.

    The text occupies `scale` rows of terminal cells. We follow with `scale`
    newlines to clear the multicell block so subsequent output starts clean.
    """
    # OSC 66 ; s=<scale> ; <text> <BEL>
    sys.stdout.write(f'\033]66;s={scale};{text}\a')
    # Advance past the multicell block (s rows total)
    sys.stdout.write('\n' * scale)


def main() -> None:
    for line in sys.stdin:
        m = HEADING_RE.match(line.rstrip('\n'))
        if m:
            level = len(m.group(1))
            text = m.group(2)
            emit_heading(text, heading_scale(level))
        else:
            sys.stdout.write(line)


if __name__ == '__main__':
    main()
