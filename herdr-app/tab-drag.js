// Dragging a tab in the bar moves it (tab.move), Rex style. The tab's slot
// stays, emptied, while a lifted copy follows the pointer; the tabs it passes
// spring aside to open a gap, and on release the copy springs into that gap
// before the move is made. Each tab's element id carries a generation bumped at
// every move, so the reordered bar is drawn fresh instead of springing back
// from the offsets it had during the drag.
//
// The bar is a window_drag block: a tab swallows its press, and the bar
// swallows the moves while a tab is held, or the window would move instead.
// scripts/herdr-app-setup splices this in before the bar's class.
const DRAG_GAP = 3;
const DRAG_PAD = 3;
const DRAG_START = 4;
const DRAG_SLIDE = { response: 200, damping: 0.86 };
const DRAG_FOLLOW = { response: 60, damping: 1 };
const DRAG_SETTLE_MS = 170;

class TabDrag extends View {
  width(c) {
    return this.widths?.[c.id] ?? 0;
  }

  // Each tab's left edge in the tray, from the widths they last drew at.
  slots(tabs) {
    let at = 0;
    return tabs.map((c) => {
      const x = at;
      at += this.width(c) + DRAG_GAP;
      return x;
    });
  }

  // The slot the lifted tab would take: past every tab whose middle it crossed.
  target(tabs) {
    const d = this.drag;
    const x = this.slots(tabs);
    const center = x[d.from] + this.width(tabs[d.from]) / 2 + d.dx;
    let to = d.from;
    tabs.forEach((c, j) => {
      const middle = x[j] + this.width(c) / 2;
      if (j > d.from && middle < center) to++;
      if (j < d.from && middle > center) to--;
    });
    return to;
  }

  // A tab's place in the tray: its slot, shifted aside while another is dragged
  // past it, or (ghost) the lifted copy over the tray.
  placed(el, c, ghost, tabs) {
    const d = this.drag;
    if (ghost) {
      const x = this.slots(tabs);
      const land = d.to > d.from ? x[d.to] + this.width(tabs[d.to]) - this.width(c) : x[d.to];
      return el
        .absolute()
        .top(DRAG_PAD)
        .h(30)
        .w(this.width(c))
        .left(DRAG_PAD + (d.settling ? land : x[d.from] + d.dx))
        .spring("left", DRAG_FOLLOW)
        .bg(C.tab)
        .border_color(C.tabEdge)
        .shadow_md()
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation());
    }
    const i = tabs.findIndex((t) => t.id === c.id);
    let offset = 0;
    if (d?.moved && c.id !== d.id) {
      const shift = this.width(tabs[d.from]) + DRAG_GAP;
      if (d.from < i && i <= d.to) offset = -shift;
      if (d.to <= i && i < d.from) offset = shift;
    }
    return el
      .on_size_change((size) => {
        (this.widths ??= {})[c.id] = size.width;
      })
      .relative()
      .left(offset)
      .spring("left", DRAG_SLIDE)
      .when(Boolean(d?.moved) && c.id === d.id, (s) => s.opacity(0))
      .on_mouse_down("left", (e, cx) => {
        cx.stop_propagation();
        if (this.drag?.settling) return;
        this.drag = { id: c.id, from: i, to: i, x: e.position.x, dx: 0, moved: false };
      })
      .on_mouse_down("right", (_e, cx) => cx.stop_propagation());
  }

  follow(e, cx, tabs) {
    const d = this.drag;
    if (!d || d.settling) return;
    cx.stop_propagation();
    if (tabs[d.from]?.id !== d.id) {
      this.drag = null;
      cx.notify();
      return;
    }
    const pulled = e.position.x - d.x;
    if (!d.moved && Math.abs(pulled) < DRAG_START) return;
    const x = this.slots(tabs);
    const last = tabs.length - 1;
    const room = x[last] + this.width(tabs[last]) - this.width(tabs[d.from]);
    d.moved = true;
    d.dx = Math.max(-x[d.from], Math.min(room - x[d.from], pulled));
    d.to = this.target(tabs);
    cx.notify();
  }

  // A release: a press that never moved is a click. A press elsewhere (click
  // false) ends a drag whose release happened off the bar.
  drop(cx, tabs, click = true) {
    const d = this.drag;
    if (!d || d.settling) return;
    if (!d.moved) {
      this.drag = null;
      if (click) run("tab.select", { id: d.id });
      return;
    }
    d.settling = true;
    cx.notify();
    cx.timer.after(DRAG_SETTLE_MS, (later) => {
      if (this.drag !== d) return;
      this.drag = null;
      this.gen = (this.gen ?? 0) + 1;
      if (d.to !== d.from && tabs[d.from]?.id === d.id) run("tab.move", { id: d.id, index: d.to + 1 });
      later.notify();
    });
  }
}

