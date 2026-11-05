// Ctrl+h/j/k/l: nvim gets the key (it moves between its splits and calls
// `herdr-app do pane.go` at the edge); every other pane moves focus directly.
// Bound in keys.json as "nav.left" etc.; lives in an empty floating block of
// the main-nav and terminals-nav layouts (scripts/herdr-app-setup) because
// key commands reach shown mods only.
// Ctrl+f ("nav.scrollback"): the GUI has no copy mode, so open the focused
// terminal's screen and history read-only in nvim, zoomed over its tab.
import { View, div } from "gpui-kit";
import { focused, panes, run, hc, nextCommand } from "herdr";

const KEYS = { left: "ctrl+h", down: "ctrl+j", up: "ctrl+k", right: "ctrl+l" };
const VIM = /^(n?vim?|neovim|gvim|view)$/i;
// A login shell so hc and nvim are on PATH on macOS too.
const SCROLLBACK = 'f=$(mktemp) && hc read "$1" --lines 1000000 > "$f"; nvim -R + "$f"; rm -f "$f"';

function openScrollback() {
  const terminal = focused()?.terminal;
  if (!terminal) return;
  run("pane.split", { direction: "right", argv: ["zsh", "-lc", SCROLLBACK, "zsh", terminal] });
  run("pane.zoom");
}

function wantsKey(pane) {
  if (!pane || !pane.terminal) return false;
  return VIM.test(pane.program.key) || VIM.test(pane.program.name);
}

export default class Nav extends View {
  init(_props, cx) {
    cx.spawn(async (cx) => {
      for (;;) {
        const dir = await nextCommand();
        if (dir === "scrollback") {
          openScrollback();
          continue;
        }
        const key = KEYS[dir];
        if (!key) continue;
        const f = focused();
        const pane = f && panes().find((p) => p.pane === f.pane);
        const terminal = f && (f.terminal ?? pane?.terminal);
        if (terminal && wantsKey(pane)) {
          await hc(["keys", terminal, key]).catch(() => null);
        } else {
          run("pane.go", { direction: dir });
        }
      }
    });
  }

  render() {
    return div();
  }
}
