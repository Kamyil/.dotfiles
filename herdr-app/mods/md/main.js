// Rendered, read-only Markdown beside the editor: real heading sizes, tables
// and links. Open it with
//   herdr-app do pane.split '{"direction":"right","mod":"md","props":{"file":"/abs/file.md"}}'
// (nvim: <leader>mp). It re-reads the file whenever it is saved.
//
// Keys once the pane has the keyboard (click it, or Ctrl+h/l onto it):
//   j/k ↓/↑ a line · d/u Ctrl+d/u half a page · Space/Shift+Space f/b a page
//   gg/Home top · G/End bottom
// A ScrollHandle can only reveal a child, not scroll by an amount, so the pane
// keeps its own offset and moves the content under a clipped viewport.
import { View, div } from "gpui-kit";
import { v_flex, h_flex, TextView } from "gpui-base";
import { exec, nextCommand, props, readTextFile, theme, watchFolder, window as appWindow } from "herdr";

const PAD_X = 36; // side margin around the text column
const MAX_W = 920; // readable line length; wider panes centre the column
const BASE_TEXT = 15;
const LINE = 52; // j/k and one wheel line, in px
const GG_MS = 600; // how long the first g of gg waits for the second
// Key jumps glide: the offset eases toward its goal, closing the gap with this
// time constant (about 3×TAU to settle), and held keys move the goal mid-glide.
// GPUI's native .spring("top") never animated this element, so the mod steps it
// itself, and only while a glide runs. Wheel and trackpad stay direct: macOS
// already smooths them, and easing on top would only add lag.
const TAU = 45; // ms
const FRAME = 8; // ms slept between steps; with render time a step lands ~every 18 ms

const dirName = (path) => path.slice(0, path.lastIndexOf("/")) || "/";
const baseName = (path) => path.slice(path.lastIndexOf("/") + 1);

// Resolves `target` against `dir`, collapsing "." and "..".
function resolve(dir, target) {
  const parts = (target.startsWith("/") ? target : `${dir}/${target}`).split("/");
  const out = [];
  for (const part of parts) {
    if (part === "" || part === ".") continue;
    if (part === "..") out.pop();
    else out.push(part);
  }
  return `/${out.join("/")}`;
}

export default class Markdown extends View {
  init(_props, cx) {
    this.file = props()?.file ?? null;
    this.text = null;
    this.error = null;
    this.generation = 0; // bumps when a link points the pane at another file
    this.y = 0; // scroll offset, px
    this.viewH = 0;
    this.contentH = 0;
    this.lastG = 0;
    this.goal = 0; // where a glide is heading; equals y when still
    this.gliding = false;
    this.handle = cx.focus_handle();
    // pane.go onto this pane (mod.json "focusable") arrives as "focus".
    cx.spawn(async (cx) => {
      for (;;) {
        const command = await nextCommand();
        if (command === "focus") {
          this.handle.focus();
          cx.notify();
          continue;
        }
        // md.down / md.up / md.half-down / md.half-up / md.top / md.bottom:
        // the same moves as the keys, for keys.json or `herdr-app do`.
        const half = Math.max(LINE, this.viewH / 2);
        const moves = { down: this.goal + LINE, up: this.goal - LINE, "half-down": this.goal + half, "half-up": this.goal - half, top: 0, bottom: this.maxY() };
        if (command in moves) this.glideTo(moves[command], cx);
      }
    });
    if (!this.file) {
      this.error = "No file: open this pane with props { file: \"/abs/path.md\" }.";
      return;
    }
    this.watch(cx);
  }

  // Only call with a cx from cx.spawn: it is used after an await.
  async load(cx) {
    const file = this.file;
    try {
      const text = await readTextFile(file);
      if (file !== this.file) return; // a link moved on meanwhile
      this.text = text;
      this.error = text === null ? `Not found: ${file}` : null;
    } catch (err) {
      this.error = `Can't read ${file}: ${err?.message ?? err}`;
    }
    cx.notify();
  }

  // Editors save in place or by renaming a temp file over it, so any batch
  // naming the file, or the whole folder (a refresh-everything batch), reloads.
  watch(cx) {
    const generation = this.generation;
    const file = this.file;
    const dir = dirName(file);
    cx.spawn(async (cx) => {
      await this.load(cx);
      while (generation === this.generation) {
        const paths = await watchFolder(dir);
        if (generation !== this.generation) return;
        if (paths.some((p) => p === file || p === dir)) await this.load(cx);
      }
    });
  }

  open(file, cx) {
    this.file = file;
    this.text = null;
    this.y = 0;
    this.goal = 0; // a new file starts at its top, no glide
    this.generation += 1;
    this.watch(cx);
    cx.notify();
  }

  external(target) {
    exec(appWindow().platform === "macos" ? "open" : "xdg-open", [target]);
  }

  link(url, cx) {
    if (/^[a-z][a-z0-9+.-]*:/i.test(url)) {
      this.external(url);
      return;
    }
    if (url.startsWith("#")) return; // same-page anchors: nothing to jump to
    const target = resolve(dirName(this.file), url.split("#")[0]);
    if (/\.(md|markdown|mdx)$/i.test(target)) this.open(target, cx);
    else this.external(target);
  }

  maxY() {
    return Math.max(0, this.contentH - this.viewH);
  }

  clamp(y) {
    return Math.min(this.maxY(), Math.max(0, y));
  }

  // Wheel and trackpad: straight there, cancelling any glide.
  scrollTo(y, cx) {
    const next = this.clamp(y);
    this.goal = next;
    if (next === this.y) return;
    this.y = next;
    cx.notify();
  }

  glideTo(goal, cx) {
    this.goal = Math.round(this.clamp(goal));
    if (this.gliding || this.goal === this.y) return;
    this.gliding = true;
    cx.spawn(async (cx) => {
      let last = Date.now();
      while (Math.abs(this.goal - this.y) > 0.5) {
        await cx.sleep(FRAME);
        const now = Date.now();
        this.y += (this.goal - this.y) * (1 - Math.exp(-(now - last) / TAU));
        last = now;
        cx.notify();
      }
      this.y = this.goal;
      this.gliding = false;
      cx.notify();
    });
  }

  // Returns the new offset for a key, or null when the key isn't ours.
  target(e) {
    const m = e.modifiers;
    if (m.alt || m.platform) return null;
    const k = e.key;
    const half = Math.max(LINE, this.viewH / 2);
    const page = Math.max(LINE, this.viewH - 2 * LINE);
    if (m.control) {
      if (k === "d") return this.goal + half;
      if (k === "u") return this.goal - half;
      if (k === "f") return this.goal + page;
      if (k === "b") return this.goal - page;
      return null;
    }
    if ((k === "g" && m.shift) || e.key_char === "G" || k === "end") return this.maxY();
    if (k === "home") return 0;
    if (k === "g") {
      const now = Date.now();
      const second = now - this.lastG < GG_MS;
      this.lastG = second ? 0 : now;
      return second ? 0 : null;
    }
    if (k === "j" || k === "down") return this.goal + LINE;
    if (k === "k" || k === "up") return this.goal - LINE;
    if (k === "d") return this.goal + half;
    if (k === "u") return this.goal - half;
    if (k === "space") return this.goal + (m.shift ? -page : page);
    if (k === "f" || k === "pagedown") return this.goal + page;
    if (k === "b" || k === "pageup") return this.goal - page;
    return null;
  }

  render(_cx) {
    const t = theme();
    const name = this.file ? baseName(this.file) : "Markdown";
    const folder = this.file ? dirName(this.file).replace(/^\/Users\/[^/]+/, "~") : "";
    const active = this.handle.is_focused();

    const header = h_flex()
      .flex_none()
      .gap(8)
      .px(PAD_X / 2)
      .py(6)
      .border_b(1)
      .border_color(active ? t.accent : t.border)
      .bg(t.chrome)
      .text_size(11)
      .child(div().text_color(t.foreground).font_weight(600).whitespace_nowrap().child(name))
      .child(div().flex_1().min_w(0).text_color(t.dim).overflow_hidden().text_ellipsis().whitespace_nowrap().child(folder))
      .when(this.maxY() > 0, (el) =>
        el.child(div().text_color(t.dim).whitespace_nowrap().child(`${Math.round((100 * this.y) / this.maxY())}%`)),
      );

    const body = this.error
      ? div().px(PAD_X).py(18).text_size(12).text_color(t.blocked).child(this.error)
      : this.text === null
        ? div().px(PAD_X).py(18).text_size(12).text_color(t.dim).child("Loading…")
        : h_flex()
            .w_full()
            .justify_center()
            .child(
              div()
                .w_full()
                .max_w(MAX_W + 2 * PAD_X)
                .px(PAD_X)
                .pt(24)
                .pb(96)
                .text_size(BASE_TEXT)
                .text_color(t.foreground)
                .child(
                  TextView.markdown(`md-${this.generation}`, this.text)
                    .selectable()
                    .w_full()
                    .on_link_click((url, cx) => this.link(url, cx)),
                ),
            );

    // A saved edit can shorten the file: keep the offset in range.
    if (this.contentH > 0 && this.goal > this.maxY()) this.goal = this.y = Math.min(this.y, this.maxY());

    const thumbH = this.contentH > this.viewH ? Math.max(24, (this.viewH * this.viewH) / this.contentH) : 0;
    const thumbTop = this.maxY() > 0 ? (this.y / this.maxY()) * (this.viewH - thumbH) : 0;

    const viewport = div()
      .id(`md-view-${this.generation}`)
      .relative()
      .flex_1()
      .min_h(0)
      .overflow_hidden()
      .on_size_change((size, cx) => {
        if (Math.round(size.height) === this.viewH) return;
        this.viewH = Math.round(size.height);
        cx.notify();
      })
      .on_scroll_wheel((e, cx) => {
        const dy = e.delta_lines ? e.delta_lines.y * LINE : e.delta.y;
        this.scrollTo(this.y - dy, cx);
      })
      .child(
        div()
          .id(`md-content-${this.generation}`)
          .absolute()
          .left(0)
          .right(0)
          .top(-this.y)
          .on_size_change((size, cx) => {
            if (Math.round(size.height) === this.contentH) return;
            this.contentH = Math.round(size.height);
            cx.notify();
          })
          .child(body),
      )
      .when(thumbH > 0, (el) =>
        el.child(
          div()
            .absolute()
            .right(2)
            .w(6)
            .rounded(3)
            .top(thumbTop)
              .h(thumbH)
            .bg(t.border)
            .opacity(active ? 0.9 : 0.6),
        ),
      );

    return v_flex()
      .id("md")
      .size_full()
      .bg(t.background)
      .track_focus(this.handle)
      .on_mouse_down("left", (_e, cx) => {
        this.handle.focus();
        cx.notify();
      })
      .on_key_down((e, cx) => {
        const y = this.target(e);
        if (y === null) return;
        cx.stop_propagation();
        this.glideTo(y, cx);
      })
      .child(header)
      .child(viewport);
  }
}
