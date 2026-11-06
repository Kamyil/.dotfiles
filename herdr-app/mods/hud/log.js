// The run log under the panes: the game's output (shared("hud.run").log),
// tailed while it runs, errors red and warnings amber, newest at the bottom.
// Ctrl+Shift+G (keys.json) or the hotbar's scroll button shows and hides it.
import { div, svg } from "gpui-kit";
import { v_flex, h_flex, v_virtual_list, Scrollbar, VirtualListScrollHandle } from "gpui-base";
import { run, settings } from "herdr";
import * as fs from "fs/promises";
import { C, ASSETS, runState, isRunning, baseName, clock } from "./game.js";

const ROW = 18;
const KEEP = 3000;

function kind(line) {
  if (/^\s*(SCRIPT |USER |SHADER )?ERROR\b|^\s*(E \d|Parse Error|Invalid call)|\bFATAL\b|^\s*\[\s*ERROR/.test(line)) return "error";
  if (/^\s*(USER )?WARNING\b|^\s*W \d/.test(line)) return "warn";
  if (/^\s+(at|GDScript backtrace|\[\d+\])\b|^\s+at:/.test(line)) return "trace";
  if (/^Godot Engine v/.test(line)) return "banner";
  return "plain";
}

const COLOR = { error: C.hp, warn: C.warn, trace: C.dim, banner: C.gold, plain: C.muted };

export default class Log {
  init(_props, cx) {
    this.lines = [];
    this.skip = 0; // lines hidden by Clear
    this.size = -1;
    this.file = null;
    this.follow = true;
    this.scroll = VirtualListScrollHandle.new();
    cx.timer.every(700, async (cx) => {
      if (await this.read()) {
        if (this.follow) this.scroll.scroll_to_bottom();
        cx.notify();
      } else if (isRunning()) cx.notify(); // the clock
    });
  }

  async read() {
    const st = runState();
    if (!st?.log) return false;
    if (st.log !== this.file || st.started !== this.started) {
      this.file = st.log;
      this.started = st.started;
      this.size = -1;
      this.skip = 0;
    }
    // Once the game has ended, one last read picks up its final words.
    if (!isRunning() && this.size >= 0 && st.ended && Date.now() - st.ended > 3000) return false;
    const text = await fs.readFile(st.log, "utf8").catch(() => null);
    if (text === null || text.length === this.size) return false;
    this.size = text.length;
    const lines = text.replace(/\x1b\[[0-9;]*m/g, "").split("\n");
    if (lines[lines.length - 1] === "") lines.pop();
    this.lines = lines.slice(-KEEP).map((text) => ({ text, kind: kind(text) }));
    this.skip = Math.min(this.skip, this.lines.length);
    return true;
  }

  button(id, icon, tip, onClick) {
    return div()
      .id(id)
      .flex_none()
      .p(3)
      .text_color(C.dim)
      .cursor_pointer()
      .hover((s) => s.text_color(C.gold))
      .tooltip(tip)
      .on_click(onClick)
      .child(svg(icon).size(13));
  }

  render() {
    const st = runState();
    const shown = this.lines.slice(this.skip);
    const errors = shown.filter((l) => l.kind === "error").length;
    const warns = shown.filter((l) => l.kind === "warn").length;
    const running = isRunning();
    const status = !st ? "no runs yet" : running ? `running ${clock(Date.now() - st.started)}` : st.stopped ? "stopped" : "ended";
    const font = settings()?.font_family ?? "JetBrains Mono";

    return v_flex()
      .size_full()
      .min_h(0)
      .bg(C.panel)
      .border_1()
      .border_color(C.edge)
      .child(
        h_flex()
          .flex_none()
          .h(28)
          .px(10)
          .gap(8)
          .items_center()
          .border_b(1)
          .border_color(C.edge)
          .text_size(11.5)
          .child(svg(`${ASSETS}/icons/scroll.svg`).size(13).flex_none().text_color(C.gold))
          .child(div().font_bold().text_color(C.gold).child("RUN LOG"))
          .when(Boolean(st), (el) => el.child(div().text_color(C.muted).child(baseName(st.project))))
          .child(div().text_color(running ? C.ok : C.dim).child(status))
          .child(div().flex_1())
          .when(errors > 0, (el) => el.child(div().text_color(C.hp).child(`${errors} error${errors === 1 ? "" : "s"}`)))
          .when(warns > 0, (el) => el.child(div().text_color(C.warn).child(`${warns} warning${warns === 1 ? "" : "s"}`)))
          .child(
            this.button("hud-log-follow", `${ASSETS}/icons/${this.follow ? "follow" : "pause"}.svg`, this.follow ? "Following new output" : "Paused: click to follow", (_e, cx) => {
              this.follow = !this.follow;
              if (this.follow) this.scroll.scroll_to_bottom();
              cx.notify();
            }),
          )
          .child(
            this.button("hud-log-clear", "mods/workspace-chrome/archive.svg", "Clear", (_e, cx) => {
              this.skip = this.lines.length;
              cx.notify();
            }),
          )
          .child(this.button("hud-log-close", "mods/workspace-chrome/x.svg", "Hide (Ctrl+Shift+G)", () => run("layout.hide", { id: "run-log" }))),
      )
      .when(shown.length === 0, (el) =>
        el.child(div().px(10).py(8).text_size(12).text_color(C.dim).child(st ? "Nothing printed yet." : "Press F5 or PLAY to run the Godot project in focus.")),
      )
      .child(
        div()
          .flex_1()
          .min_h(0)
          .relative()
          .font_family(font)
          .text_size(11.5)
          .child(
            v_virtual_list("hud-log-lines", shown.length, ROW, (i) => String(i + this.skip), (range) =>
              shown.slice(range.start, range.end).map((l) =>
                div()
                  .h(ROW)
                  .px(10)
                  .truncate()
                  .when(l.kind === "error", (el) => el.bg("#c2413a1a"))
                  .text_color(COLOR[l.kind])
                  .child(l.text || " "),
              ),
            )
              .track_scroll(this.scroll)
              .size_full(),
          )
          .child(Scrollbar.vertical("hud-log-lines").viewport_from_layout().absolute().inset_0()),
      );
  }
}
