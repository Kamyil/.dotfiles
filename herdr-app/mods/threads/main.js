// Coding-agent threads (Claude Code, OpenCode, omp) from scripts/agent-threads,
// newest first. Clicking one opens a tab in its folder with the thread resumed.
// Search filters by title, folder and tool. Pinned threads lead the list.
// Settling a thread moves it to the Settled archive, where it can be unsettled;
// a settled thread that sees new activity comes back by itself.
// Shown by the threads layout (scripts/herdr-app-setup).
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { exec, focused, spaces, home, run, theme, notify } from "herdr";

const TOOLS = [
  { id: "claude", label: "Claude", icon: "icons/claude.svg", color: "#d97757" },
  { id: "opencode", label: "OpenCode", icon: "icons/opencode.svg" },
  { id: "omp", label: "omp", icon: "icons/pi.svg" },
];
const UI = "mods/workspace-chrome";
const REFRESH_MS = 20000;
const LIMIT = 200;

function ago(ms) {
  const m = Math.floor(ms / 60000);
  if (m < 1) return "now";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h`;
  const d = Math.floor(h / 24);
  return d < 60 ? `${d}d` : `${Math.floor(d / 30)}mo`;
}

const tidy = (folder) => (folder.startsWith(home()) ? "~" + folder.slice(home().length) : folder);
const project = (folder) => tidy(folder).split("/").filter(Boolean).pop() ?? "~";
const inside = (folder, root) => root && (folder === root || folder.startsWith(root.replace(/\/$/, "") + "/"));
const keyOf = (th) => `${th.tool}:${th.id}`;
const load = (name, empty) => JSON.parse(localStorage.getItem(name) ?? "null") ?? empty;

export default class Threads extends View {
  init(_props, cx) {
    this.threads = [];
    this.error = null;
    this.here = localStorage.getItem("here") === "true";
    this.hidden = new Set(load("hidden", []));
    this.pins = new Set(load("pins", []));
    this.settled = load("settled", {}); // key -> settled at (ms)
    this.archive = false;
    this.hovered = null;
    this.query = "";
    this.search = InputState.new({ placeholder: "Search threads" });
    this.search.on("change", (_e, cx) => {
      this.query = this.search.value();
      cx.notify();
    });
    cx.spawn(async (cx) => {
      for (;;) {
        try {
          const r = await exec(`${home()}/.dotfiles/scripts/agent-threads`);
          if (r.code === 0) {
            this.threads = JSON.parse(r.stdout);
            this.error = null;
            this.wake();
          } else this.error = r.stderr.trim().split("\n").pop() || `exit ${r.code}`;
        } catch (e) {
          this.error = String(e);
        }
        cx.notify();
        await cx.sleep(REFRESH_MS);
      }
    });
    cx.timer.every(60000, (cx) => cx.notify());
  }

  save() {
    localStorage.setItem("here", String(this.here));
    localStorage.setItem("hidden", JSON.stringify([...this.hidden]));
    localStorage.setItem("pins", JSON.stringify([...this.pins]));
    localStorage.setItem("settled", JSON.stringify(this.settled));
  }

  // Unsettle threads that were resumed and used after settling.
  wake() {
    let changed = false;
    for (const th of this.threads) {
      const at = this.settled[keyOf(th)];
      if (at && th.updated > at + 60000) {
        delete this.settled[keyOf(th)];
        changed = true;
      }
    }
    if (changed) this.save();
  }

  open(thread) {
    if (thread.missing) {
      notify({ title: "Folder is gone", body: tidy(thread.folder), level: "warning" });
      return;
    }
    run("terminal.open", { argv: thread.argv, folder: thread.folder, place: "tab" });
  }

  togglePin(key) {
    this.pins.has(key) ? this.pins.delete(key) : this.pins.add(key);
    this.save();
  }

  toggleSettled(key) {
    if (this.settled[key]) delete this.settled[key];
    else {
      this.settled[key] = Date.now();
      this.pins.delete(key);
    }
    this.save();
  }

  chip(id, label, on, onClick, t) {
    return div()
      .id(`chip-${id}`)
      .h(22)
      .px(7)
      .flex()
      .items_center()
      .flex_none()
      .text_size(11)
      .border(1)
      .border_color(on ? t.accent : t.border)
      .bg(on ? t.selected : t.chrome)
      .text_color(on ? t.foreground : t.dim)
      .hover((s) => s.text_color(t.foreground))
      .on_click(onClick)
      .child(label);
  }

  action(id, icon, tip, onClick, t) {
    return div()
      .id(id)
      .flex_none()
      .p(2)
      .text_color(t.dim)
      .cursor_pointer()
      .hover((s) => s.bg(t.selected).text_color(t.foreground))
      .tooltip(tip)
      .on_click((_e, cx) => {
        cx.stop_propagation();
        onClick();
        // The row may move away from under the pointer, and no hover-out comes.
        this.hovered = null;
        cx.notify();
      })
      .child(svg(`${UI}/${icon}.svg`).size(13));
  }

  row(th, now, t) {
    const tool = TOOLS.find((x) => x.id === th.tool) ?? TOOLS[0];
    const key = keyOf(th);
    const pinned = this.pins.has(key);
    const hovered = this.hovered === key;
    return h_flex()
      .id(`th-${key}`)
      .px(10)
      .py(7)
      .gap(9)
      .items_start()
      .border_b(1)
      .border_color(t.border)
      .cursor_pointer()
      .hover((s) => s.bg(t.hover))
      .on_hover((on, cx) => {
        if (on) this.hovered = key;
        else if (this.hovered === key) this.hovered = null;
        cx.notify();
      })
      .on_click(() => this.open(th))
      .tooltip(`${tool.label} · ${tidy(th.folder)}${th.missing ? " (gone)" : ""}`)
      .child(svg(tool.icon).size(14).mt(2).flex_none().text_color(tool.color ?? t.foreground))
      .child(
        v_flex()
          .flex_1()
          .min_w(0)
          .gap(2)
          .child(div().text_size(12.5).truncate().text_color(th.missing ? t.dim : t.foreground).child(th.title))
          .child(
            h_flex()
              .gap(6)
              .text_size(11)
              .text_color(t.dim)
              .child(div().flex_1().min_w(0).truncate().child(project(th.folder)))
              .when(pinned && !hovered, (el) => el.child(svg(`${UI}/pin.svg`).size(11).flex_none().text_color(t.accent)))
              .child(div().flex_none().child(ago(now - th.updated))),
          ),
      )
      .when(hovered, (el) =>
        el.child(
          h_flex()
            .flex_none()
            .gap(2)
            .when(!this.archive, (el) => el.child(this.action(`pin-${key}`, pinned ? "pin-off" : "pin", pinned ? "Unpin" : "Pin to the top", () => this.togglePin(key), t)))
            .child(
              this.archive
                ? this.action(`settle-${key}`, "archive", "Unsettle", () => this.toggleSettled(key), t)
                : this.action(`settle-${key}`, "circle-check", "Settle", () => this.toggleSettled(key), t),
            ),
        ),
      );
  }

  render(cx) {
    const t = theme();
    const now = Date.now();
    const root = focused()?.cwd ?? spaces().find((s) => s.active)?.folder;
    const words = this.query.toLowerCase().split(/\s+/).filter(Boolean);
    const matches = (th) => {
      const hay = `${th.title} ${tidy(th.folder)} ${th.tool}`.toLowerCase();
      return words.every((w) => hay.includes(w));
    };
    const settledCount = this.threads.filter((th) => this.settled[keyOf(th)]).length;
    const shown = this.threads.filter(
      (th) =>
        !this.hidden.has(th.tool) &&
        (!this.here || inside(th.folder, root)) &&
        Boolean(this.settled[keyOf(th)]) === this.archive &&
        matches(th),
    );
    const ordered = [...shown.filter((th) => this.pins.has(keyOf(th))), ...shown.filter((th) => !this.pins.has(keyOf(th)))].slice(0, LIMIT);

    const toggleTool = (id) => () => {
      this.hidden.has(id) ? this.hidden.delete(id) : this.hidden.add(id);
      this.save();
      cx.notify();
    };
    const set = (fn) => () => {
      fn();
      this.save();
      cx.notify();
    };
    const empty = words.length
      ? "No matching threads."
      : this.archive
        ? "Nothing settled yet."
        : this.here
          ? `No threads in ${tidy(root ?? "~")}.`
          : "No threads yet.";

    return v_flex()
      .size_full()
      .min_h(0)
      .bg(t.chrome)
      .border(1)
      .border_color(t.border)
      .child(
        v_flex()
          .flex_none()
          .px(10)
          .pt(10)
          .pb(8)
          .gap(8)
          .border_b(1)
          .border_color(t.border)
          .child(
            h_flex()
              .id("th-search")
              .h(28)
              .px(8)
              .gap(6)
              .items_center()
              .border(1)
              .border_color(this.query ? t.accent : t.input)
              .bg(t.background)
              .cursor_text()
              .on_mouse_down("left", (_e, cx) => {
                cx.stop_propagation();
                this.search.focus();
              })
              .child(svg(`${UI}/search.svg`).size(13).flex_none().text_color(t.dim))
              .child(div().flex_1().min_w(0).child(Input.new(this.search).h_full().text_size(12).text_color(t.foreground)))
              .when(Boolean(this.query), (el) =>
                el.child(
                  div()
                    .id("th-search-clear")
                    .flex_none()
                    .text_color(t.dim)
                    .hover((s) => s.text_color(t.foreground))
                    .on_click((_e, cx) => {
                      this.search.set_value("");
                      this.query = "";
                      cx.notify();
                    })
                    .child(svg(`${UI}/x.svg`).size(12)),
                ),
              ),
          )
          .child(
            h_flex()
              .justify_between()
              .items_center()
              .child(
                h_flex()
                  .gap(4)
                  .child(this.chip("all", "All", !this.here, set(() => (this.here = false)), t))
                  .child(this.chip("here", "Here", this.here, set(() => (this.here = true)), t)),
              )
              .child(this.chip("settled", `Settled ${settledCount}`, this.archive, set(() => (this.archive = !this.archive)), t)),
          )
          .child(h_flex().gap(4).children(TOOLS.map((x) => this.chip(x.id, x.label, !this.hidden.has(x.id), toggleTool(x.id), t)))),
      )
      .when(Boolean(this.error), (el) => el.child(div().px(10).py(8).text_size(11.5).text_color(t.blocked).child(this.error)))
      .when(ordered.length === 0 && !this.error, (el) => el.child(div().px(10).py(8).text_size(12).text_color(t.dim).child(empty)))
      .child(v_flex().id("th-list").flex_1().min_h(0).overflow_y_scrollbar().children(ordered.map((th) => this.row(th, now, t))));
  }
}
