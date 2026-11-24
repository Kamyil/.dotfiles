const THREADS_BAR = "terminals-bar-square-threads";
const POSITION = "threads.tab_bar_position";

function tabBarPosition() {
  return shared(POSITION) === "bottom" ? "bottom" : "top";
}

function positionTabBar(position) {
  const tree = layout();
  const column = tree?.children?.find((child) => child.id === "body")
    ?.children?.find((child) => child.id === "workspace");
  const children = column?.children;
  const index = children?.findIndex((child) => child.content?.mod === THREADS_BAR) ?? -1;
  if (index < 0 || index === (position === "top" ? 0 : children.length - 1)) return;
  const [bar] = children.splice(index, 1);
  if (position === "top") children.unshift(bar);
  else children.push(bar);
  run("layout.set", { layout: tree });
}

function openThreadsSettings() {
  openOverlay({ mod: THREADS_BAR, kind: "popup", width: 172, props: { threadsSettings: true } });
}

function threadsSettings() {
  const t = theme();
  const selected = tabBarPosition();
  return v_flex().w_full().p(5).bg(t.popover).text_size(13)
    .child(div().px(8).py(5).text_color(t.muted).child("Tab bar position"))
    .children(["top", "bottom"].map((position) => h_flex()
      .id(`threads-position-${position}`).h(30).px(8).rounded(6)
      .items_center().justify_between().cursor_pointer().text_color(t.foreground)
      .when(position === selected, (el) => el.bg(t.selected))
      .hover((s) => s.bg(t.hover))
      .on_click(() => {
        closeOverlay(props().overlay);
        setShared(POSITION, position);
      })
      .child(position === "top" ? "Top" : "Bottom")
      .child(position === selected ? "✓" : "")));
}

// The portrait treatment is exclusive to threads. TabDrag above remains the
// original shared implementation, with only its lifted tab height adapted.
export default class TerminalsBar extends TabDrag {
  init(_props, cx) {
    if (props()?.threadsSettings) return;
    this.artScroll = ScrollHandle.new();
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand();
        if (command === "toggle-tab-bar-position") {
          setShared(POSITION, tabBarPosition() === "top" ? "bottom" : "top");
        } else if (command === "settings") {
          openThreadsSettings();
        }
      }
    });
  }
  close() { this.artScroll?.release(); }

  render() {
    if (props()?.threadsSettings) return threadsSettings();
    positionTabBar(tabBarPosition());
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
    const tabHeight = TAB_HEIGHT;
    const w = win() ?? {};
    const tab = (c, index, ghost = false) => {
      const p = lead(all, c.id);
      const nvimPath = p?.program?.key === "nvim"
        ? p.title?.match(/^nvim: ((?:~)?\/.*)$/)?.[1] || p.cwd
        : null;
      const parts = nvimPath?.split("/").filter(Boolean);
      const leaf = parts?.pop();
      const parent = parts?.pop();
      const pathLabel = leaf && parent ? `${leaf} · ${parent}` : leaf ?? nvimPath;
      // Remote prompts can replace the local SSH title after login.
      const sshAlias = p?.title?.match(/^ssh: ([a-zA-Z0-9_.-]+)$/)?.[1]
        || (p?.program?.key === "ssh" ? p.title?.match(/^[a-zA-Z0-9_.-]+@([a-zA-Z0-9_.-]+):/)?.[1] : null);
      const detail = sshAlias || nvimPath || folder(p?.cwd);
      const title = c.named ? c.name : sshAlias || pathLabel || p?.program?.name;
      const label = title ? `${index + 1} · ${title}` : `${index + 1}`;
      return div()
        .id(ghost ? `tm-ghost-${this.gen ?? 0}` : `tm-${c.id}-${this.gen ?? 0}`)
        .relative().flex_none().w(TAB_WIDTH).min_w(TAB_WIDTH).max_w(TAB_WIDTH).h(tabHeight)
        .rounded(5).border_1().cursor_pointer()
        .bg("#10151e")
        .border_color("#333d4c")
        .hover((s) => s.border_color("#586273"))
        .on_mouse_down("right", () => openOverlay({ mod: "menu", kind: "popup", width: 200,
          props: { tab: "tab", target: { id: c.id, space: space.id } } }))
        .tooltip(detail ? `${c.name} — ${detail}` : c.name)
        .child(tabScenery(p, c.active, tabHeight))
        .child(h_flex().absolute().top(1).left(1).w(TAB_WIDTH - 2).h(tabHeight - 2).px(8).gap(7).items_center()
          .child(tabIllustration(t, p, c.active))
          .child(div().flex_1().min_w(0).truncate().text_size(13).line_height("16px")
            .font_weight(600).text_color(c.active ? "#f2f4f8" : "#979eac").child(label))
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
      .on_mouse_move((e, cx) => this.follow(e, cx, space.tabs))
      .on_mouse_up("left", (_e, cx) => this.drop(cx, space.tabs))
      .on_mouse_down_out((_e, cx) => this.drop(cx, space.tabs, false))
      .child(div().flex_1().min_w(0).h(tabHeight).relative()
        .child(h_flex().id("threads-art-scroll").size_full().min_w(0).relative()
          .overflow_x_scroll().track_scroll(this.artScroll)
          .on_size_change((size, cx) => {
            if (this.artViewportWidth === size.width) return;
            this.artViewportWidth = size.width;
            if (activeIndex >= 0) this.artScroll.scroll_to_item(activeIndex);
            cx.notify();
          })
          .gap(DRAG_GAP).bg("#00000000")
          .children(space.tabs.map((c, index) => tab(c, index)))
          .when(Boolean(this.drag?.moved), (el) => {
            const index = space.tabs.findIndex((c) => c.id === this.drag.id);
            return index >= 0 ? el.child(tab(space.tabs[index], index, true)) : el;
          }))
        .when(overflow, (el) => el.child(edge("left")).child(edge("right"))))
      .child(iconButton("tm-threads-settings", null, openThreadsSettings,
        "mods/workspace-chrome/settings.svg").tooltip("Threads layout settings"))
      .child(iconButton("tm-keys", "command", () => run("app.palette")))
      .child(iconButton("tm-new", "plus", () => run("tab.new", { space: space.id })))
      .when(Boolean(w.buttons), (el) => el.child(h_flex().flex_none().gap(8)
        .child(windowButton("tm-min", "win-min", "window.minimize"))
        .child(windowButton("tm-max", w.maximized ? "win-restore" : "win-max", "window.maximize"))
        .child(windowButton("tm-close", "win-close", "window.close"))));
  }
}
