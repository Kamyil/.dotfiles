// Switch a space's branch. Dropped from the threads layout's spaces list when
// its branch badge is pressed (scripts/herdr-app-setup), as a popup at the
// pointer, with props { cwd, on, branch }: the space's folder, its machine
// (null: this computer) and the branch it is on.
// Local branches come first, newest commit first, then remote branches with no
// local one of the same name (picking one makes a local branch tracking it).
// A branch checked out in another worktree can't be switched to here; it says
// where it is instead. Type to filter, ↑/↓ and Enter to switch, Esc to leave.
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { exec, theme, notify, props, closeOverlay, home } from "herdr";

const UI = "mods/workspace-chrome";
const LIST_MAX = 320;
const FORMAT ="%(HEAD)%09%(refname)%09%(committerdate:unix)%09%(worktreepath)";

function ago(s) {
  const m = Math.floor((Date.now() / 1000 - s) / 60);
  if (m < 1) return "now";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h`;
  const d = Math.floor(h / 24);
  return d < 60 ? `${d}d` : `${Math.floor(d / 30)}mo`;
}

const tidy = (folder) => (folder.startsWith(home()) ? "~" + folder.slice(home().length) : folder);

// for-each-ref lines -> [{ name, remote, current, when, worktree }].
function parse(stdout) {
  const local = [];
  const remote = [];
  for (const line of stdout.split("\n")) {
    if (!line) continue;
    const [head, ref, when, worktree] = line.split("\t");
    if (ref.startsWith("refs/heads/")) {
      local.push({ name: ref.slice(11), remote: null, current: head === "*", when: Number(when), worktree: worktree || null });
    } else if (ref.startsWith("refs/remotes/")) {
      const [r, ...rest] = ref.slice(13).split("/");
      const name = rest.join("/");
      if (name && name !== "HEAD") remote.push({ name, remote: r, current: false, when: Number(when), worktree: null });
    }
  }
  const mine = new Set(local.map((b) => b.name));
  const seen = new Set();
  const others = remote.filter((b) => !mine.has(b.name) && !seen.has(b.name) && seen.add(b.name));
  return [...local, ...others];
}

export default class Branches extends View {
  init(_props, cx) {
    const p = props() ?? {};
    this.cwd = p.cwd;
    this.on = p.on ?? null;
    this.branches = null;
    this.error = null;
    this.query = "";
    this.at = 0;
    this.busy = false;
    this.handle = cx.focus_handle();
    this.search = InputState.new({ placeholder: "Switch branch…" });
    this.search.on("change", (_e, cx) => {
      this.query = this.search.value();
      this.at = 0;
      cx.notify();
    });
    this.search.on("submit", (_e, cx) => this.pick(this.shown()[this.at], cx));
    this.search.focus();
    cx.timer.after(300, () => this.search.focus());
    cx.spawn(async (cx) => {
      try {
        const r = await exec("git", ["for-each-ref", "--sort=-committerdate", `--format=${FORMAT}`, "refs/heads", "refs/remotes"], { cwd: this.cwd, on: this.on });
        if (r.code === 0) this.branches = parse(r.stdout);
        else this.error = r.stderr.trim().split("\n").pop() || `exit ${r.code}`;
      } catch (e) {
        this.error = String(e);
      }
      cx.notify();
    });
  }

  close() {
    closeOverlay(props().overlay);
  }

  shown() {
    const words = this.query.toLowerCase().split(/\s+/).filter(Boolean);
    return (this.branches ?? []).filter((b) => words.every((w) => `${b.remote ?? ""}/${b.name}`.toLowerCase().includes(w)));
  }

  pick(b, cx) {
    if (!b || this.busy) return;
    if (b.current) return this.close();
    if (b.worktree) {
      notify({ title: `${b.name} is in another worktree`, body: tidy(b.worktree), level: "warning", timeout: 5000 });
      return;
    }
    this.busy = true;
    cx.notify();
    const args = b.remote ? ["switch", "--track", `${b.remote}/${b.name}`] : ["switch", b.name];
    cx.spawn(async (cx) => {
      try {
        const r = await exec("git", args, { cwd: this.cwd, on: this.on });
        if (r.code === 0) return this.close();
        notify({ title: `Couldn't switch to ${b.name}`, body: r.stderr.trim().split("\n").pop() || `exit ${r.code}`, level: "warning", timeout: 6000 });
      } catch (e) {
        notify({ title: `Couldn't switch to ${b.name}`, body: String(e), level: "warning", timeout: 6000 });
      }
      this.busy = false;
      cx.notify();
    });
  }

  row(b, i, t) {
    const on = i === this.at;
    return h_flex()
      .id(`br-${b.remote ?? ""}-${b.name}`)
      .h(28)
      .px(8)
      .gap(7)
      .flex_none()
      .items_center()
      .rounded(5)
      .cursor_pointer()
      .when(on, (el) => el.bg(t.selected))
      .when(!on, (el) => el.hover((s) => s.bg(t.hover)))
      .on_hover((over, cx) => {
        if (over && this.at !== i) {
          this.at = i;
          cx.notify();
        }
      })
      .on_click((_e, cx) => this.pick(b, cx))
      .child(
        b.current
          ? svg(`${UI}/check.svg`).size(12).flex_none().text_color(t.accent)
          : svg(`${UI}/git-branch.svg`).size(12).flex_none().text_color(b.remote ? t.dim : t.accent),
      )
      .when(Boolean(b.remote), (el) => el.child(div().flex_none().text_color(t.dim).child(`${b.remote}/`)))
      .child(
        div()
          .flex_1()
          .min_w(0)
          .truncate()
          .when(b.current, (el) => el.font_semibold())
          .text_color(b.worktree && !b.current ? t.dim : t.foreground)
          .child(b.name),
      )
      .when(Boolean(b.worktree) && !b.current, (el) =>
        el.child(div().flex_none().px(4).rounded(3).border(1).border_color(t.border).text_size(10).text_color(t.dim).child("worktree")),
      )
      .child(div().flex_none().text_size(10.5).text_color(t.dim).child(ago(b.when)));
  }

  render(cx) {
    const t = theme();
    const list = this.shown();
    if (this.at >= list.length) this.at = Math.max(0, list.length - 1);
    const note = this.error ?? (this.branches === null ? "Loading branches…" : list.length ? null : "No matching branches.");
    return v_flex()
      .id("branches")
      .track_focus(this.handle)
      .w_full()
      .p(8)
      .gap(6)
      .bg(t.popover)
      .text_size(12)
      .on_key_down((e, cx) => {
        const k = e.key;
        if (k === "escape") return this.close();
        if (!list.length) return;
        if (k === "down") this.at = (this.at + 1) % list.length;
        else if (k === "up") this.at = (this.at + list.length - 1) % list.length;
        else return;
        cx.stop_propagation();
        cx.notify();
      })
      .child(
        h_flex()
          .h(30)
          .flex_none()
          .px(8)
          .gap(6)
          .items_center()
          .rounded(5)
          .border(1)
          .border_color(this.query ? t.accent : t.input)
          .bg(t.background)
          .child(svg(`${UI}/search.svg`).size(13).flex_none().text_color(t.dim))
          .child(div().flex_1().min_w(0).child(Input.new(this.search).h_full().text_size(12).text_color(t.foreground)))
          .when(this.busy, (el) => el.child(svg(`${UI}/spinner.svg`).size(12).flex_none().text_color(t.dim).spin(900))),
      )
      .when(Boolean(note), (el) => el.child(div().px(8).py(4).text_color(this.error ? t.blocked : t.dim).child(note)))
      // A popup is as tall as what it holds, so the list sets its own height:
      // a flex_1 list there gets none and shows nothing.
      .child(v_flex().id("br-list").max_h(LIST_MAX).overflow_y_scrollbar().children(list.map((b, i) => this.row(b, i, t))));
  }
}
