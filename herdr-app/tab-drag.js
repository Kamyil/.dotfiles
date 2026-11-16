// Dragging a tab in the bar moves it (tab.move), Rex style. The tab's slot
// stays, emptied, while a lifted copy follows the pointer; the tabs it passes
// slide aside to open a gap, and on release the copy slides into that gap
// before the move is made. The slides are tweened here (slide()), redrawn by a
// 16ms timer that runs only while one is moving: gpui-kit's native spring() and
// transition() left these offsets jumping. A move bumps a generation in every
// tab's element id and drops the tweens, so the reordered bar is drawn fresh.
//
// The bar is a window_drag block: a tab swallows its press, and the bar
// swallows the moves while a tab is held, or the window would move instead.
// scripts/herdr-app-setup splices this in before the bar's class.
const DRAG_GAP = 3;
const DRAG_PAD = 3;
const DRAG_START = 4;
const DRAG_SLIDE_MS = 160;
const DRAG_FRAME_MS = 16;
// Ease-out cubic: quick to start, gentle to land.
const dragEase = (k) => 1 - (1 - k) ** 3;

class TabDrag extends View {
  // An offset (key: a tab id, or "ghost") that slides to `to` over
  // DRAG_SLIDE_MS whenever its target changes; its value now. Marks
  // this.moving while it is under way, which keeps the frame timer going.
  slide(key, to, now) {
    const tweens = (this.tweens ??= {});
    const t = tweens[key];
    if (!t) {
      tweens[key] = { from: to, to, start: 0 };
      return to;
    }
    const k = Math.min(1, (now - t.start) / DRAG_SLIDE_MS);
    const at = t.from + (t.to - t.from) * dragEase(k);
    if (t.to !== to) {
      tweens[key] = { from: at, to, start: now };
      this.moving = true;
    } else if (k < 1) this.moving = true;
    return at;
  }

  // Redraws every frame while a slide is under way: each tick clears
  // this.moving, and the draw it asks for sets it again until all have landed.
  animate(cx) {
    if (this.ticker && !this.ticker.is_done()) return;
    this.moving = true;
    this.ticker = cx.timer.every(DRAG_FRAME_MS, (later) => {
      if (!this.moving) {
        this.ticker?.cancel();
        this.ticker = null;
        return;
      }
      this.moving = false;
      later.notify();
    });
  }

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

  // The slot the lifted tab would take: past every tab whose middle its leading
  // edge crossed, so a neighbour gives way once it's half covered. (Its center
  // only crosses a same-width neighbour's middle at full overlap, which the
  // clamp at the row's ends never lets happen.)
  target(tabs) {
    const d = this.drag;
    const x = this.slots(tabs);
    const left = x[d.from] + d.dx;
    const right = left + this.width(tabs[d.from]);
    let to = d.from;
    tabs.forEach((c, j) => {
      const middle = x[j] + this.width(c) / 2;
      if (j > d.from && right > middle) to++;
      if (j < d.from && left < middle) to--;
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
      // It sits under the pointer while dragged, and slides home once dropped.
      const left = d.settling ? this.slide("ghost", land, Date.now()) : x[d.from] + d.dx;
      if (!d.settling) (this.tweens ??= {}).ghost = { from: left, to: left, start: 0 };
      return el
        .absolute()
        .top(DRAG_PAD)
        .h(30)
        .w(this.width(c))
        .left(DRAG_PAD + left)
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
      .left(this.slide(c.id, offset, Date.now()))
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
    this.animate(cx);
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
    this.animate(cx);
    cx.timer.after(DRAG_SLIDE_MS + DRAG_FRAME_MS, (later) => {
      if (this.drag !== d) return;
      this.drag = null;
      this.tweens = {};
      this.gen = (this.gen ?? 0) + 1;
      if (d.to !== d.from && tabs[d.from]?.id === d.id) run("tab.move", { id: d.id, index: d.to + 1 });
      later.notify();
    });
  }
}

