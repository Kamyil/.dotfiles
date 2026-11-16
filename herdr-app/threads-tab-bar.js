// The portrait treatment is exclusive to threads. TabDrag above remains the
// original shared implementation, with only its lifted tab height adapted.
export default class TerminalsBar extends TabDrag {
  init() { this.artScroll = ScrollHandle.new(); }
  close() { this.artScroll?.release(); }

  render() {
    const t = theme();
    const space = spaces().find((p) => p.active);
    if (!space) return div();
    const activeIndex = space.tabs.findIndex((c) => c.active);
    const selected = space.tabs[activeIndex]?.id;
    if (selected !== this.artSelected || activeIndex !== this.artSelectedIndex) {
      this.artSelected = selected;
      this.artSelectedIndex = activeIndex;
      if (activeIndex >= 0) this.artScroll.scroll_to_item(activeIndex);
    }
    const all = panes();
    const tabHeight = Math.max(24, Math.min(TAB_HEIGHT, this.artBarHeight ?? TAB_HEIGHT));
    this.artTabHeight = tabHeight;
    const w = win() ?? {};
    const tab = (c, ghost = false) => {
      const p = lead(all, c.id);
      const where = folder(p?.cwd);
      const name = /^\d+$/.test(c.name) && p?.program?.name ? `${c.name} · ${p.program.name}` : c.name;
      return div()
        .id(ghost ? `tm-ghost-${this.gen ?? 0}` : `tm-${c.id}-${this.gen ?? 0}`)
        .relative().flex_none().w(TAB_WIDTH).min_w(TAB_WIDTH).max_w(TAB_WIDTH).h(tabHeight)
        .rounded(5).border_1().cursor_pointer()
        .bg("#10151e")
        .border_color("#333d4c")
        .hover((s) => s.border_color("#586273"))
        .on_mouse_down("right", () => openOverlay({ mod: "menu", kind: "popup", width: 200,
          props: { tab: "tab", target: { id: c.id, space: space.id } } }))
        .tooltip(`${c.name}${where ? ` — ${where}` : ""}`)
        .child(tabScenery(p, c.active, tabHeight))
        .child(h_flex().absolute().top(1).left(1).w(TAB_WIDTH - 2).h(tabHeight - 2).px(8).gap(7).items_center()
          .child(tabIllustration(t, p, c.active))
          .child(div().flex_1().min_w(0).truncate().text_size(13).line_height("16px")
            .font_weight(600).text_color(c.active ? "#f2f4f8" : "#979eac").child(name))
          .child(div().flex_none().w(16).h(20)
          .id(`threads-close-${c.id}`)
          .flex().items_center().justify_center().rounded(3)
          .text_color("#d8d4c6").hover((s) => s.bg("#ffffff20").text_color("#ffffff"))
          .tooltip("Close tab")
          .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
          .on_click((_e, cx) => { cx.stop_propagation(); run("tab.close", { id: c.id }); })
          .child(svg("mods/pane/close.svg").size(12))))
        .when(true, (el) => this.placed(el, c, ghost, space.tabs));
    };

    const overflow = space.tabs.length * (TAB_WIDTH + DRAG_GAP) + DRAG_PAD * 2 > (this.artViewportWidth ?? Infinity);
    const edge = (side) => div().absolute().top(0).bottom(0).w(18)
      .when(side === "left", (el) => el.left(0))
      .when(side === "right", (el) => el.right(0))
      .child(image(TAB_EFFECTS[side]).absolute().inset_0().w(18).h(TAB_HEIGHT));

    return h_flex().size_full().min_w(0).gap(8).items_center()
      .on_size_change((size, cx) => {
        if (this.artBarHeight === size.height) return;
        this.artBarHeight = size.height;
        cx.notify();
      })
      .on_mouse_move((e, cx) => this.follow(e, cx, space.tabs))
      .on_mouse_up("left", (_e, cx) => this.drop(cx, space.tabs))
      .on_mouse_down_out((_e, cx) => this.drop(cx, space.tabs, false))
      .child(div().flex_1().min_w(0).h_full().min_h(0).relative()
        .child(h_flex().id("threads-art-scroll").size_full().min_w(0).relative()
          .overflow_x_scroll().track_scroll(this.artScroll)
          .on_size_change((size, cx) => {
            if (this.artViewportWidth === size.width) return;
            this.artViewportWidth = size.width;
            if (activeIndex >= 0) this.artScroll.scroll_to_item(activeIndex);
            cx.notify();
          })
          .gap(3).bg("#00000000")
          .children(space.tabs.map((c) => tab(c)))
          .when(Boolean(this.drag?.moved), (el) => {
            const lifted = space.tabs.find((c) => c.id === this.drag.id);
            return lifted ? el.child(tab(lifted, true)) : el;
          }))
        .when(overflow, (el) => el.child(edge("left")).child(edge("right"))))
      .child(iconButton("tm-keys", "command", () => run("app.palette")))
      .child(iconButton("tm-new", "plus", () => run("tab.new", { space: space.id })))
      .when(Boolean(w.buttons), (el) => el.child(h_flex().flex_none().gap(8)
        .child(windowButton("tm-min", "win-min", "window.minimize"))
        .child(windowButton("tm-max", w.maximized ? "win-restore" : "win-max", "window.maximize"))
        .child(windowButton("tm-close", "win-close", "window.close"))));
  }
}
