// Coding-agent threads (Claude Code, OpenCode, omp) from scripts/agent-threads,
// newest first. Clicking one opens a tab in its folder with the thread resumed.
// Shown by the threads layout (scripts/herdr-app-setup).
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, focused, spaces, home, run, theme, notify } from "herdr";

const TOOLS = [
  { id: "claude", label: "Claude", icon: "icons/claude.svg", color: "#d97757" },
  { id: "opencode", label: "OpenCode", icon: "icons/opencode.svg" },
  { id: "omp", label: "omp", icon: "icons/pi.svg" },
];
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

export default class Threads extends View {
  init(_props, cx) {
    this.threads = [];
    this.error = null;
    this.here = localStorage.getItem("here") === "true";
    this.hidden = new Set(JSON.parse(localStorage.getItem("hidden") ?? "[]"));
    cx.spawn(async (cx) => {
      for (;;) {
        try {
          const r = await exec(`${home()}/.dotfiles/scripts/agent-threads`);
          if (r.code === 0) {
            this.threads = JSON.parse(r.stdout);
            this.error = null;
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

  open(thread) {
    if (thread.missing) {
      notify({ title: "Folder is gone", body: tidy(thread.folder), level: "warning" });
      return;
    }
    run("terminal.open", { argv: thread.argv, folder: thread.folder, place: "tab" });
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

  render(cx) {
    const t = theme();
    const now = Date.now();
    const root = focused()?.cwd ?? spaces().find((s) => s.active)?.folder;
    const shown = this.threads
      .filter((th) => !this.hidden.has(th.tool) && (!this.here || inside(th.folder, root)))
      .slice(0, LIMIT);

    const save = () => {
      localStorage.setItem("here", String(this.here));
      localStorage.setItem("hidden", JSON.stringify([...this.hidden]));
      cx.notify();
    };
    const toggleTool = (id) => () => {
      this.hidden.has(id) ? this.hidden.delete(id) : this.hidden.add(id);
      save();
    };

    const rows = shown.map((th) => {
      const tool = TOOLS.find((x) => x.id === th.tool) ?? TOOLS[0];
      return h_flex()
        .id(`th-${th.tool}-${th.id}`)
        .px(10)
        .py(7)
        .gap(9)
        .items_start()
        .border_b(1)
        .border_color(t.border)
        .hover((s) => s.bg(t.hover))
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
                .child(div().flex_none().child(ago(now - th.updated))),
            ),
        );
    });

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
              .justify_between()
              .items_center()
              .child(div().text_size(11.5).font_medium().text_color(t.dim).child("Threads"))
              .child(
                h_flex()
                  .gap(4)
                  .child(this.chip("all", "All", !this.here, () => ((this.here = false), save()), t))
                  .child(this.chip("here", "Here", this.here, () => ((this.here = true), save()), t)),
              ),
          )
          .child(h_flex().gap(4).children(TOOLS.map((x) => this.chip(x.id, x.label, !this.hidden.has(x.id), toggleTool(x.id), t)))),
      )
      .when(Boolean(this.error), (el) => el.child(div().px(10).py(8).text_size(11.5).text_color(t.blocked).child(this.error)))
      .when(rows.length === 0 && !this.error, (el) =>
        el.child(div().px(10).py(8).text_size(12).text_color(t.dim).child(this.here ? `No threads in ${tidy(root ?? "~")}.` : "No threads yet.")),
      )
      .child(v_flex().id("th-list").flex_1().min_h(0).overflow_y_scrollbar().children(rows));
  }
}
