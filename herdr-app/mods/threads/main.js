// Coding-agent threads (Claude Code, OpenCode, omp) from scripts/agent-threads,
// newest first. Clicking one opens a tab in its folder with the thread resumed.
// Search filters by title, folder and tool. Pinned threads lead the list.
// Settling a thread moves it to the Settled archive, where it can be unsettled;
// a settled thread that sees new activity comes back by itself. Pins and settled
// threads live with the thread's machine (the script's --mark), so every window
// showing that machine agrees.
// A thread running in a Herdr terminal shows that agent's live status (working,
// needs you, done while you weren't looking, idle), and clicking it focuses the
// terminal instead of resuming the thread again.
// The machine chips switch between this computer's threads and each connected
// machine's: the script runs there through Herdr's connection (exec's `on`),
// and a thread opens in a space on its machine. A machine whose script fails
// (no dotfiles there) gets no chip.
// Shown by the threads layout (scripts/herdr-app-setup), and by the quest
// layout with props { skin: "hud" }: a Quest log title, same list.
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { exec, spaces, machines, agents, home, run, theme, notify, props } from "herdr";

const TOOLS = [
  { id: "claude", label: "Claude", icon: "icons/claude.svg", color: "#d97757" },
  { id: "opencode", label: "OpenCode", icon: "icons/opencode.svg" },
  { id: "omp", label: "omp", icon: "icons/pi.svg" },
];
const UI = "mods/workspace-chrome";
const REFRESH_MS = 20000;
const STATUS_LABEL = { working: "Working", blocked: "Needs you", done: "Done", idle: "Idle" };
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

// Any machine's home (/Users/x, /home/x) shows as ~.
const tidy = (folder) => (folder.startsWith(home()) ? "~" + folder.slice(home().length) : folder.replace(/^\/(?:Users|home)\/[^/]+(?=\/|$)/, "~"));
const project = (folder) => tidy(folder).split("/").filter(Boolean).pop() ?? "~";
const inside = (folder, root) => root && (folder === root || folder.startsWith(root.replace(/\/$/, "") + "/"));
// Machines are named as `hc machine ls` does; null (this computer) as "" in storage.
const machineKey = (m) => m ?? "";
const machineLabel = (m) => (m ? m[0].toUpperCase() + m.slice(1) : home().startsWith("/Users/") ? "Mac" : "Local");
const keyOf = (th) => `${th.tool}:${th.id}`;
const SCRIPT = '"$HOME/.dotfiles/scripts/agent-threads"';
const load = (name, empty) => JSON.parse(localStorage.getItem(name) ?? "null") ?? empty;

export default class Threads extends View {
  init(_props, cx) {
    this.byMachine = {}; // machine key -> its threads, once its script answered
    this.errors = {}; // machine key -> last failure
    this.machine = localStorage.getItem("machine") || null;
    this.hidden = new Set(load("hidden", []));
    this.gen = {}; // machine key -> marks made, so a list fetched before one is dropped
    this.archive = false;
    this.hovered = null;
    this.query = "";
    // Agent terminals a refresh has already tried to match; a new one refreshes early.
    this.tried = new Set();
    this.stale = false;
    this.hud = props()?.skin === "hud";
    this.search = InputState.new({ placeholder: this.hud ? "Search quests" : "Search threads" });
    this.search.on("change", (_e, cx) => {
      this.query = this.search.value();
      cx.notify();
    });
    cx.spawn(async (cx) => {
      for (;;) {
        this.stale = false;
        const seen = agents().map((a) => a.address);
        const names = [null, ...machines().filter((m) => m.name && m.layout !== "unavailable").map((m) => m.name)];
        await Promise.all(names.map((m) => this.fetch(m, cx)));
        this.tried = new Set(seen);
        for (let waited = 0; waited < REFRESH_MS && !this.stale; waited += 2000) await cx.sleep(2000);
      }
    });
    cx.timer.every(60000, (cx) => cx.notify());
  }

  // One machine's threads; its terminals' addresses get the machine/ prefix agents() uses.
  async fetch(m, cx) {
    const key = machineKey(m);
    const gen = this.gen[key];
    try {
      if (!m) await this.importLocal();
      const r = await exec("sh", ["-c", SCRIPT], { on: m });
      if (gen !== this.gen[key]) return;
      if (r.code === 0) {
        const list = JSON.parse(r.stdout);
        for (const th of list) {
          th.machine = m;
          if (m && th.terminal) th.terminal = `${m}/${th.terminal}`;
        }
        this.byMachine[key] = list;
        delete this.errors[key];
      } else this.errors[key] = r.stderr.trim().split("\n").pop() || `exit ${r.code}`;
    } catch (e) {
      this.errors[key] = String(e);
    }
    cx.notify();
  }

  // Pins and settled threads this window kept itself before they moved to the
  // script: this computer's own threads then, so they go to this computer's marks.
  async importLocal() {
    const pins = load("pins", []);
    const settled = load("settled", {});
    if (!pins.length && !Object.keys(settled).length) return;
    const r = await exec("sh", ["-c", `${SCRIPT} --import "$1"`, "sh", JSON.stringify({ pins, settled })]);
    if (r.code !== 0) return;
    localStorage.removeItem("pins");
    localStorage.removeItem("settled");
  }

  save() {
    localStorage.setItem("machine", machineKey(this.machine));
    localStorage.setItem("hidden", JSON.stringify([...this.hidden]));
  }

  // Shown at once, written on the thread's machine, then that machine re-read.
  mark(th, action, cx) {
    const m = th.machine ?? null;
    const key = machineKey(m);
    this.gen[key] = (this.gen[key] ?? 0) + 1;
    cx.spawn(async (cx) => {
      try {
        const r = await exec("sh", ["-c", `${SCRIPT} --mark "$1" "$2"`, "sh", action, keyOf(th)], { on: m });
        if (r.code !== 0) notify({ title: "Couldn't save that", body: r.stderr.trim().split("\n").pop() || `exit ${r.code}`, level: "warning", timeout: 5000 });
      } catch (e) {
        notify({ title: "Couldn't save that", body: String(e), level: "warning", timeout: 5000 });
      }
      await this.fetch(m, cx);
    });
  }

  open(thread, live) {
    if (live) {
      run("agent.focus", { terminal: live.address });
      return;
    }
    if (thread.missing) {
      notify({ title: "Folder is gone", body: tidy(thread.folder), level: "warning", timeout: 5000 });
      return;
    }
    // A tab in a space on its machine: the shown one, else one whose folder holds
    // the thread's, else its first; with none, a new space there.
    const m = thread.machine ?? null;
    const all = spaces();
    const theirs = all.filter((s) => (s.machine ?? null) === m);
    const shown = theirs.find((s) => s.active);
    if (shown) {
      run("terminal.open", { argv: thread.argv, folder: thread.folder, place: "tab" });
      return;
    }
    const space = theirs.find((s) => s.folder && inside(thread.folder, s.folder)) ?? theirs[0];
    if (!space) {
      run("space.new", { machine: m ?? "", folder: thread.folder, argv: thread.argv });
      return;
    }
    run("space.select", { id: space.id });
    run("tab.new", { space: space.id, folder: thread.folder, argv: thread.argv });
  }

  togglePin(th, cx) {
    th.pinned = !th.pinned;
    this.mark(th, th.pinned ? "pin" : "unpin", cx);
  }

  toggleSettled(th, cx) {
    if (th.settled) th.settled = null;
    else {
      th.settled = Date.now();
      th.pinned = false;
    }
    this.mark(th, th.settled ? "settle" : "unsettle", cx);
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
        onClick(cx);
        // The row may move away from under the pointer, and no hover-out comes.
        this.hovered = null;
        cx.notify();
      })
      .child(svg(`${UI}/${icon}.svg`).size(13));
  }

  // Working spins; blocked asks; done is a filled dot; idle a ring.
  status(st, t) {
    if (st === "working") return svg(`${UI}/spinner.svg`).size(12).flex_none().text_color(t.working).spin(900);
    if (st === "blocked")
      return div().flex_none().px(5).h(16).flex().items_center().bg(t.blocked + "26").text_size(10).font_semibold().text_color(t.blocked).child("Needs you");
    if (st === "done") return div().size(7).mx(2).flex_none().rounded(4).bg(t.done);
    return div().size(7).mx(2).flex_none().rounded(4).border(1.5).border_color(t.idle ?? t.dim);
  }

  row(th, live, now, t) {
    const tool = TOOLS.find((x) => x.id === th.tool) ?? TOOLS[0];
    const key = keyOf(th);
    const pinned = Boolean(th.pinned);
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
      .on_click(() => this.open(th, live))
      .tooltip(`${tool.label} · ${tidy(th.folder)}${th.missing ? " (gone)" : ""}${live ? ` · ${STATUS_LABEL[live.status] ?? live.status} in ${live.space_name} / ${live.tab_name}` : ""}`)
      .child(svg(tool.icon).size(14).mt(2).flex_none().text_color(tool.color ?? t.foreground))
      .child(
        v_flex()
          .flex_1()
          .min_w(0)
          .gap(2)
          .child(
            h_flex()
              .gap(6)
              .items_center()
              .child(div().flex_1().min_w(0).text_size(12.5).truncate().text_color(th.missing ? t.dim : t.foreground).child(th.title))
              .when(Boolean(live), (el) => el.child(this.status(live?.status, t))),
          )
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
            .when(!this.archive, (el) => el.child(this.action(`pin-${key}`, pinned ? "pin-off" : "pin", pinned ? "Unpin" : "Pin to the top", (cx) => this.togglePin(th, cx), t)))
            .child(
              this.archive
                ? this.action(`settle-${key}`, "archive", "Unsettle", (cx) => this.toggleSettled(th, cx), t)
                : this.action(`settle-${key}`, "circle-check", "Settle", (cx) => this.toggleSettled(th, cx), t),
            ),
        ),
      );
  }

  render(cx) {
    const t = theme();
    const now = Date.now();
    // Machines whose script answered; the chosen one falls back to this computer.
    const known = [null, ...Object.keys(this.byMachine).filter(Boolean).sort()];
    const machine = known.includes(this.machine) ? this.machine : null;
    const error = this.errors[machineKey(machine)];
    const running = new Map(agents().map((a) => [a.address, a]));
    if ([...running.keys()].some((address) => !this.tried.has(address))) this.stale = true;
    const words = this.query.toLowerCase().split(/\s+/).filter(Boolean);
    const matches = (th) => {
      const hay = `${th.title} ${tidy(th.folder)} ${th.tool}`.toLowerCase();
      return words.every((w) => hay.includes(w));
    };
    const mine = this.byMachine[machineKey(machine)] ?? [];
    const settledCount = mine.filter((th) => th.settled).length;
    const shown = mine.filter(
      (th) =>
        !this.hidden.has(th.tool) &&
        Boolean(th.settled) === this.archive &&
        matches(th),
    );
    const ordered = [...shown.filter((th) => th.pinned), ...shown.filter((th) => !th.pinned)].slice(0, LIMIT);

    // Handlers notify through their own cx: render's goes stale once it returns.
    const toggleTool = (id) => (_e, cx) => {
      this.hidden.has(id) ? this.hidden.delete(id) : this.hidden.add(id);
      this.save();
      cx.notify();
    };
    const set = (fn) => (_e, cx) => {
      fn();
      this.save();
      cx.notify();
    };
    const empty = words.length
      ? "No matching threads."
      : this.archive
        ? "Nothing settled yet."
        : this.byMachine[machineKey(machine)]
          ? `No threads on ${machineLabel(machine)} yet.`
          : `Loading ${machineLabel(machine)}…`;

    return v_flex()
      .size_full()
      .min_h(0)
      .bg(t.chrome)
      .border(1)
      .border_color(t.border)
      // Matches the sidebar block's island_radius (scripts/herdr-app-setup).
      .rounded(8)
      .overflow_hidden()
      .child(
        v_flex()
          .flex_none()
          .px(10)
          .pt(10)
          .pb(8)
          .gap(8)
          .border_b(1)
          .border_color(t.border)
          .when(this.hud, (el) =>
            el.child(
              h_flex()
                .gap(7)
                .items_center()
                .text_size(11.5)
                .child(svg("mods/hud/icons/sword.svg").size(13).flex_none().text_color(t.accent))
                .child(div().flex_1().font_bold().text_color(t.accent).child("QUEST LOG"))
                .child(div().text_color(t.dim).child(`${shown.length} active`)),
            ),
          )
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
                  .children(known.map((m) => this.chip(`machine-${machineKey(m) || "local"}`, machineLabel(m), m === machine, set(() => (this.machine = m)), t))),
              )
              .child(this.chip("settled", `Settled ${settledCount}`, this.archive, set(() => (this.archive = !this.archive)), t)),
          )
          .child(h_flex().gap(4).children(TOOLS.map((x) => this.chip(x.id, x.label, !this.hidden.has(x.id), toggleTool(x.id), t)))),
      )
      .when(Boolean(error), (el) => el.child(div().px(10).py(8).text_size(11.5).text_color(t.blocked).child(error)))
      .when(ordered.length === 0 && !error, (el) => el.child(div().px(10).py(8).text_size(12).text_color(t.dim).child(empty)))
      .child(v_flex().id("th-list").flex_1().min_h(0).overflow_y_scrollbar().children(ordered.map((th) => this.row(th, running.get(th.terminal), now, t))));
  }
}
