// The threads layout's title strip (props { role: "title-strip" }): a band
// across the window's top holding macOS's window buttons (the layout's
// traffic_lights), the shown space's name, the usage meters (the usage mod's
// strip place) and the command palette and new-tab buttons. Two copies:
// props { side: "left" } draws the window buttons' room and the space,
// { side: "right" } the buttons; scripts/herdr-app-setup puts them either side
// of the usage block, all window_drag blocks, over the sidebar and the tab row.
//
// macOS moves the window on any drag that starts in a hidden title bar's top
// ~28pt, whatever Herdr draws there; clicks still get through. So the strip
// covers that band with buttons and empty space, and the tabs sit in their own
// row below it, where dragging one reorders it (herdr-app/tab-drag.js).
import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { openOverlay, props, run, spaces, theme, window as win } from "herdr";

// Room for macOS's three window buttons at traffic_lights' x.
const BUTTONS_INSET = 76;

// A press of a control in the strip is the control's, not the window's.
function own(el) {
  return el.on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_mouse_down("right", (_e, cx) => cx.stop_propagation());
}

export default class TitleStrip extends View {
  button(id, icon, tip, onClick) {
    const c = theme();
    return own(div())
      .id(id)
      .flex_none()
      .p(4)
      .rounded(5)
      .text_color(c.dim)
      .cursor_pointer()
      .hover((s) => s.bg(c.hover).text_color(c.foreground))
      .tooltip(tip)
      .on_click(onClick)
      .child(svg(`mods/terminals-bar/${icon}.svg`).size(14));
  }

  render() {
    const c = theme();
    const w = win() ?? {};
    const space = spaces().find((s) => s.active);
    if (props()?.side === "right") {
      return h_flex()
        .size_full()
        .pr(4)
        .gap(6)
        .items_center()
        .justify_end()
        .child(this.button("ts-keys", "command", "Command palette", () => run("app.palette")))
        .when(Boolean(space), (el) => el.child(this.button("ts-new", "plus", "New tab", () => run("tab.new", { space: space.id }))));
    }
    const inset = w.platform === "macos" && !w.fullscreen ? BUTTONS_INSET : 6;
    return h_flex()
      .size_full()
      .pl(inset)
      .gap(6)
      .items_center()
      .text_size(12.5)
      .when(Boolean(space), (el) =>
        el.child(
          own(h_flex())
            .id("ts-space")
            .flex_none()
            .max_w(260)
            .px(6)
            .py(2)
            .gap(6)
            .items_center()
            .rounded(5)
            .cursor_pointer()
            .text_color(c.muted)
            .hover((s) => s.bg(c.hover).text_color(c.foreground))
            .tooltip("Switch space")
            .on_click(() => openOverlay({ mod: "picker", kind: "popup", at: "top", offset: 40, width: 640, height: 0.8 }))
            .child(svg("mods/terminals-bar/stack.svg").size(13).flex_none())
            .child(div().min_w(0).truncate().font_medium().child(space.name)),
        ),
      );
  }
}
