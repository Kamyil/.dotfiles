// The header over a pinned terminal (props { role: "pin-head", which:
// "space" | "global" }): its program and title, where it's pinned, and
// buttons that send it back to a tab or hide it. The nav layouts put one at
// the top of each pin (scripts/herdr-app-setup); the commands go to the nav
// mod's key loop (main.js, pins.js).
import { View, div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { props, run, spaces, terminals, theme } from "herdr";
import { pinRecord } from "./pins.js";

export default class PinHead extends View {
  button(id, icon, tip, command) {
    const c = theme();
    return div()
      .id(id)
      .p(4)
      .rounded(5)
      .text_color(c.dim)
      .cursor_pointer()
      .hover((s) => s.bg(c.hover).text_color(c.foreground))
      .tooltip(tip)
      .on_click((_e, cx) => {
        cx.stop_propagation();
        run(command);
      })
      .child(svg(icon).size(14));
  }

  render() {
    const which = props()?.which === "global" ? "global" : "space";
    const rec = pinRecord(which);
    const t = rec ? terminals().find((x) => x.address === rec.address) : null;
    if (!t) return div();
    const c = theme();
    const g = t.program;
    const title = t.title || g?.name || "shell";
    const where = which === "global" ? "every space" : spaces().find((s) => s.active)?.name ?? "this space";
    const global = which === "global";
    return h_flex()
      .id(`pin-head-${which}`)
      .size_full()
      .pl(10)
      .pr(6)
      .gap(8)
      .items_center()
      .text_size(13)
      .child(svg("mods/workspace-chrome/pin.svg").size(13).flex_none().text_color(c.accent ?? c.muted))
      .when(Boolean(g?.icon), (el) =>
        el.child(g.tint ? svg(g.icon).size(14).flex_none().text_color(c.foreground) : image(g.icon).w(14).h(14).flex_none()),
      )
      .child(div().flex_none().max_w(320).truncate().font_semibold().text_color(c.foreground).child(title))
      .child(div().flex_1().truncate().text_color(c.dim).child(`pinned to ${where}`))
      .child(this.button(`pin-tab-${which}`, "mods/workspace-chrome/pin-off.svg", "Back to a tab", global ? "nav.unpin-global" : "nav.unpin"))
      .child(this.button(`pin-hide-${which}`, "mods/workspace-chrome/chevron-down.svg", global ? "Hide (Ctrl+Shift+O)" : "Hide (Ctrl+Shift+P)", global ? "nav.pin-global" : "nav.pin"));
  }
}
