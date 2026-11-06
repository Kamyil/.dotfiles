// The hotbar over the panes: tabs as numbered ability slots, then Play/Stop
// for the Godot project in focus, a new-tab slot and the command palette.
// Owns the hud key commands: play, stop, toggle, mute.
import { div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { spaces, panes, run, theme, openOverlay, nextCommand, shared, setShared } from "herdr";
import { C, ASSETS, play, stop, checkRun, isRunning, runState, findProject, baseName, clock, tidy } from "./game.js";

// A control in the draggable bar: the press is its own, not the window's.
function own(el) {
  return el.on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_mouse_down("right", (_e, cx) => cx.stop_propagation());
}

// The pane a tab speaks for: the focused one, else its agent, else the first.
function lead(all, id) {
  const mine = all.filter((p) => p.tab === id);
  return mine.find((p) => p.focused) ?? mine.find((p) => p.program?.agent) ?? mine[0];
}

function glyph(p) {
  const g = p?.program;
  if (!g?.icon) return div().w(15).h(15).flex_none();
  return g.tint ? svg(g.icon).size(15).flex_none().text_color(g.color ?? C.text) : image(g.icon).w(15).h(15).flex_none();
}

export default class Bar {
  init(_props, cx) {
    this.project = null;
    cx.spawn(async (cx) => {
      for (;;) {
        const c = await nextCommand();
        if (c === "play") await play();
        else if (c === "stop") await stop();
        else if (c === "toggle") await (isRunning() ? stop() : play());
        else if (c === "mute") setShared("hud.mute", shared("hud.mute") !== true);
        if (c === "play" || c === "toggle") run("layout.show", { id: "run-log" });
        cx.notify();
      }
    });
    // Notice a game that quit by itself, and which project Play would start.
    cx.timer.every(1500, async (cx) => {
      await checkRun();
      const project = await findProject();
      if (project !== this.project) this.project = project;
      cx.notify();
    });
  }

  slot(c, all, t, space) {
    const p = lead(all, c.id);
    const dot = p?.status && p.status !== "idle" ? t[p.status] : null;
    const key = c.index <= 9 ? String(c.index) : "·";
    return own(h_flex())
      .id(`hud-tab-${c.id}`)
      .relative()
      .flex_shrink(1)
      .w(210)
      .min_w(0)
      .h(32)
      .pl(4)
      .pr(10)
      .gap(8)
      .items_center()
      .border_1()
      .cursor_pointer()
      .text_size(12.5)
      .when(c.active, (el) => el.bg(C.raised).border_color(C.gold))
      .when(!c.active, (el) => el.bg(C.sunk).border_color(C.edge).hover((s) => s.border_color(C.edgeHi).bg(C.panel)))
      .on_click(() => run("tab.select", { id: c.id }))
      .on_mouse_down("right", () =>
        openOverlay({ mod: "menu", kind: "popup", width: 200, props: { tab: "tab", target: { id: c.id, space: space.id } } }),
      )
      .tooltip(p?.cwd ? tidy(p.cwd) : c.name)
      .child(
        div()
          .flex_none()
          .w(20)
          .h(22)
          .flex()
          .items_center()
          .justify_center()
          .border_1()
          .border_color(c.active ? C.goldDim : C.edge)
          .bg(C.bg)
          .text_size(11)
          .font_bold()
          .text_color(c.active ? C.gold : C.dim)
          .child(key),
      )
      .child(glyph(p))
      .child(div().min_w(0).truncate().text_color(c.active ? C.text : C.muted).child(c.name))
      .when(Boolean(dot), (el) => el.child(div().absolute().top(-4).right(-4).w(9).h(9).border_1().border_color(C.bg).bg(dot)));
  }

  playButton() {
    const running = isRunning();
    const st = runState();
    const label = running ? `STOP  ${clock(Date.now() - st.started)}` : "PLAY";
    const tip = running ? `Stop ${baseName(st.project)} (F8)` : this.project ? `Run ${baseName(this.project)} (F5)` : "No Godot project in focus";
    const color = running ? C.hp : this.project ? C.ok : C.dim;
    return own(h_flex())
      .id("hud-play")
      .flex_none()
      .h(32)
      .px(12)
      .gap(7)
      .items_center()
      .border_1()
      .border_color(color)
      .bg(C.sunk)
      .cursor_pointer()
      .text_size(12)
      .font_bold()
      .text_color(color)
      .hover((s) => s.bg(C.raised))
      .tooltip(tip)
      .on_click(async (_e, cx) => {
        if (running) await stop();
        else {
          await play();
          run("layout.show", { id: "run-log" });
        }
        cx.notify();
      })
      .child(svg(`${ASSETS}/icons/${running ? "stop" : "play"}.svg`).size(13).flex_none().text_color(color))
      .child(label)
      .when(!running && Boolean(this.project), (el) => el.child(div().font_weight(400).text_color(C.dim).child(baseName(this.project))));
  }

  iconButton(id, icon, tip, onClick) {
    return own(div())
      .id(id)
      .flex_none()
      .w(32)
      .h(32)
      .flex()
      .items_center()
      .justify_center()
      .border_1()
      .border_color(C.edge)
      .bg(C.sunk)
      .text_color(C.dim)
      .cursor_pointer()
      .hover((s) => s.border_color(C.goldDim).text_color(C.gold))
      .tooltip(tip)
      .on_click(onClick)
      .child(svg(icon).size(15));
  }

  render() {
    const t = theme();
    const space = spaces().find((s) => s.active);
    if (!space) return div();
    const all = panes();
    return h_flex()
      .size_full()
      .gap(6)
      .items_center()
      .child(h_flex().flex_shrink(1).min_w(0).gap(4).children(space.tabs.map((c) => this.slot(c, all, t, space))))
      .child(this.iconButton("hud-new", "mods/terminals-bar/plus.svg", "New tab", () => run("tab.new", { space: space.id })))
      .child(div().flex_1())
      .child(this.playButton())
      .child(this.iconButton("hud-log", `${ASSETS}/icons/scroll.svg`, "Run log (Ctrl+Shift+G)", () => run("layout.toggle", { id: "run-log" })))
      .child(this.iconButton("hud-keys", "mods/terminals-bar/command.svg", "Command palette", () => run("app.palette")));
  }
}
