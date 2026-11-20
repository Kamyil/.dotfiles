#!/usr/bin/env python3
"""Integration checks against this machine's generated Herdr threads bar."""
import json
import runpy
import subprocess
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image

REPO = Path(__file__).resolve().parent.parent
INSTALL = REPO / "scripts/herdr-tab-art-setup"
MODULE = runpy.run_path(str(INSTALL))
SOURCE = Path.home() / ".config/herdr-app/mods/terminals-bar-square-threads/main.js"
ROOT = REPO / "herdr-app/artwork"


def original_source():
    text = SOURCE.read_text()
    if MODULE["MARKER"] in text:
        text = SOURCE.with_name("main.before-tab-art.js").read_text()
    return text


class ArtworkTests(unittest.TestCase):
    def test_catalog_and_decoding(self):
        entries = json.loads((ROOT / "catalog.json").read_text())["programs"]
        custom = json.loads((REPO / "herdr-app/programs.json").read_text())["programs"]
        expected = {p.stem for p in (ROOT / "glyphs").glob("*.svg")} - {"program", "agent"}
        self.assertEqual({e["key"] for e in entries}, expected)
        self.assertTrue(set(custom).issubset(expected))
        self.assertEqual(len(entries), len(expected))
        for entry in entries:
            if entry.get("multicolor"):
                with Image.open(ROOT / entry["icon"]) as icon:
                    icon.load()
                    self.assertEqual(icon.size, (128, 128))
            else:
                self.assertEqual(ET.parse(ROOT / entry["icon"]).getroot().tag, "{http://www.w3.org/2000/svg}svg")
            for role, size in [("background", (720, 336))]:
                with Image.open(ROOT / entry[role]) as image:
                    image.load()
                    self.assertEqual(image.size, size)
                    self.assertEqual(image.format, "PNG")

    def test_install_repeat_restore_and_preserve(self):
        with tempfile.TemporaryDirectory(dir=ROOT / ".check") as directory:
            home = Path(directory)
            mod = home / "mods/terminals-bar-square-threads"
            mod.mkdir(parents=True)
            target = mod / "main.js"
            before = original_source()
            target.write_text(before)
            layout = home / "layouts/threads.json"
            layout.parent.mkdir()
            layout.write_text(json.dumps({"content": {"mod": "terminals-bar-square-threads"}, "size": {"px": 38}}))
            untouched = home / "programs.json"
            untouched.write_text('{"programs":{"custom":{"match":["my-tool"]}}}\n')
            elsewhere = home / "mods/terminals-bar-square/main.js"
            elsewhere.parent.mkdir()
            elsewhere.write_text("other layout untouched")
            spaces = home / "mods/spaces-square-threads"
            spaces.mkdir()
            (spaces / "agents.js").write_text("old agent marks")

            def install(*args):
                return subprocess.run([str(INSTALL), "--home", str(home), *args], check=True, capture_output=True)

            install("--check")
            self.assertEqual(target.read_text(), before)
            self.assertFalse((home / "cards").exists())
            install()
            after = target.read_text()
            self.assertEqual(json.loads(layout.read_text())["size"], {"px": 52})
            self.assertIn(".overflow_x_scroll()", after)
            self.assertNotIn(".overflow_x_scrollbar()", after)
            self.assertIn('el.child(edge("left")).child(edge("right"))', after)
            self.assertIn("this.artScroll.scroll_to_item(activeIndex)", after)
            self.assertIn(".min_w(TAB_WIDTH)", after)
            self.assertIn("if (!art) return tile(t, p)", after)
            self.assertIn("this.placed(el, c, ghost, space.tabs)", after)
            # Both drag-drop decisions and the native context menu survive verbatim.
            start = before.index("class TabDrag extends View {")
            end = before.index("export default class TerminalsBar")
            self.assertIn(before[start:end].replace(".h(30)\n        .w(this.width(c))", ".h(this.artTabHeight ?? TAB_HEIGHT)\n        .w(this.width(c))"), after)
            self.assertEqual(untouched.read_text(), '{"programs":{"custom":{"match":["my-tool"]}}}\n')
            self.assertEqual(elsewhere.read_text(), "other layout untouched")
            self.assertEqual((spaces / "agents.js").read_text(), (REPO / "herdr-app/space-agents.js").read_text())
            self.assertEqual((spaces / "program-icons.js").read_text(), (REPO / "herdr-app/mods/threads/program-icons.js").read_text())
            entries = json.loads((ROOT / "catalog.json").read_text())["programs"]
            paths = {ROOT / e[role] for e in entries for role in ("icon", "background")}
            paths.update((ROOT / "effects").glob("*.png"))
            paths.update((ROOT / "effects").glob("*.svg"))
            expected = {(p.suffix, p.read_bytes()) for p in paths}
            installed = list((home / "cards/illustrated").iterdir())
            self.assertEqual({(p.suffix, p.read_bytes()) for p in installed}, expected)
            self.assertEqual(len(installed), len(expected))
            install()
            self.assertEqual(target.read_text(), after)
            install("--restore")
            self.assertEqual(target.read_text(), before)
            self.assertEqual(json.loads(layout.read_text())["size"], {"px": 38})

    def test_upstream_change_fails_before_writes(self):
        with tempfile.TemporaryDirectory(dir=ROOT / ".check") as directory:
            home = Path(directory)
            mod = home / "mods/terminals-bar-square-threads"
            mod.mkdir(parents=True)
            target = mod / "main.js"
            target.write_text("// Unexpected upstream code")
            result = subprocess.run([str(INSTALL), "--home", str(home)], capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(target.read_text(), "// Unexpected upstream code")
            self.assertFalse((home / "cards").exists())


if __name__ == "__main__":
    (ROOT / ".check").mkdir(exist_ok=True)
    unittest.main()
