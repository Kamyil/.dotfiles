// Ctrl+h/j/k/l: nvim gets the key (it moves between its splits and calls
// `herdr-app do pane.go` at the edge); every other pane moves focus directly.
// Bound in keys.json as "nav.left" etc.; lives in an empty floating block of
// the main-nav and terminals-nav layouts (scripts/herdr-app-setup) because
// key commands reach shown mods only.
import { View, div } from "gpui-kit";
import { focused, panes, run, hc, nextCommand } from "herdr";

const KEYS = { left: "ctrl+h", down: "ctrl+j", up: "ctrl+k", right: "ctrl+l" };
const VIM = /^(n?vim?|neovim|gvim|view)$/i;

function wantsKey(pane) {
  if (!pane || !pane.terminal) return false;
  return VIM.test(pane.program.key) || VIM.test(pane.program.name);
}

export default class Nav extends View {
  init(_props, cx) {
    cx.spawn(async (cx) => {
      for (;;) {
        const dir = await nextCommand();
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
