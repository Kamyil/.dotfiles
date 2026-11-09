// Ctrl+h/j/k/l: nvim gets the key over its RPC socket (it moves between its
// splits and calls `herdr-app do pane.go` at the edge); every other pane moves
// focus directly.
// Bound in keys.json as "nav.left" etc.; lives in an empty floating block of
// the main-nav and terminals-nav layouts (scripts/herdr-app-setup) because
// key commands reach shown mods only.
// Ctrl+f ("nav.scrollback"): the GUI has no copy mode, so open the focused
// terminal's screen and history read-only in nvim, zoomed over its tab.
// Ctrl+Shift+G/F/S ("nav.git", "nav.shell", "nav.brain"): floating lazygit,
// a floating shell and the second-brain space (floats.js).
// Ctrl+Shift+N ("nav.transcript"): the experimental transcript mod beside the
// focused pane, rendering that agent's session as Markdown.
import { View, div } from "gpui-kit";
import { focused, panes, run, exec, home, nextCommand, notify } from "herdr";
import { toggleBrain, toggleFloat } from "./floats.js";
import * as fs from "fs/promises";

const VIM = /^(n?vim?|neovim|gvim|view)$/i;
// A login shell so hc and nvim are on PATH on macOS too.
const SCROLLBACK = 'f=$(mktemp) && hc read "$1" --lines 1000000 > "$f"; nvim -R + "$f"; rm -f "$f"';

function openScrollback() {
  const terminal = focused()?.terminal;
  if (!terminal) return;
  run("pane.split", { direction: "right", argv: ["zsh", "-lc", SCROLLBACK, "zsh", terminal] });
  run("pane.zoom");
}

// nvim (nvim/lua/config/keymaps.lua) writes its RPC socket to this file, and the
// key goes over it: `hc keys` holds a key back until the screen settles, which
// takes seconds while nvim's LSP servers start. False without a live socket (an
// nvim without that config, or one that just quit while the pane still names
// it), so focus moves directly. Capped so a stuck nvim can't stall navigation.
const VIM_KEYS = { left: "<C-h>", down: "<C-j>", up: "<C-k>", right: "<C-l>" };

async function sendToVim(terminal, dir, cx) {
  const socket = await fs
    .readFile(`${home()}/.local/state/nvim/herdr/${terminal}`, "utf8")
    .then((text) => text.trim())
    .catch(() => "");
  if (!socket) return false;
  const sent = exec("nvim", ["--headless", "--clean", "--server", socket, "--remote-send", VIM_KEYS[dir]])
    .then((r) => r.code === 0)
    .catch(() => false);
  return Promise.race([sent, cx.sleep(1000).then(() => true)]);
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
        if (dir === "transcript") {
          run("pane.split", { direction: "right", mod: "transcript" });
          continue;
        }
        if (dir === "scrollback") {
          openScrollback();
          continue;
        }
        if (dir === "git" || dir === "shell" || dir === "brain") {
          try {
            if (dir === "brain") toggleBrain();
            else await toggleFloat(dir);
          } catch (error) {
            notify({ title: `nav.${dir} failed`, body: String(error?.message ?? error), level: "error" });
          }
          continue;
        }
        if (!VIM_KEYS[dir]) continue;
        const f = focused();
        const pane = f && panes().find((p) => p.pane === f.pane);
        const terminal = f && (f.terminal ?? pane?.terminal);
        if (!(terminal && wantsKey(pane) && (await sendToVim(terminal, dir, cx)))) {
          run("pane.go", { direction: dir });
        }
      }
    });
  }

  render() {
    return div();
  }
}
