// Experimental, read-only transcript beside a Claude Code or omp terminal.
// It tails the agent's own JSONL; no input or agent bridge lives here.
import { View, div } from "gpui-kit";
import { v_flex, h_flex, TextView, v_virtual_list, Scrollbar, VirtualListScrollHandle } from "gpui-base";
import { exec, focused, home, panes, props, theme } from "herdr";

const POLL_MS = 1500;
const MAX_SUMMARY = 100;
const REDISCOVER_MS = 10000;

const baseName = (path) => path?.split("/").pop() ?? "";
const short = (value) => {
  const text = typeof value === "string" ? value : JSON.stringify(value ?? "");
  return text.replace(/\s+/g, " ").trim().slice(0, MAX_SUMMARY) + (text.length > MAX_SUMMARY ? "…" : "");
};

function toolOf(pane) {
  const key = `${pane?.app ?? ""} ${pane?.program?.key ?? ""}`.toLowerCase();
  if (key.includes("claude")) return "claude";
  if (key.includes("omp") || key.includes("oh-my-pi") || /(^|\W)pi(\W|$)/.test(key)) return "omp";
  return null;
}

function blocks(entry, source) {
  const role = source === "omp" ? entry.message?.role : entry.type;
  if (!(["user", "assistant"].includes(role)) || entry.isMeta || entry.isSidechain) return null;
  const content = entry.message?.content;
  const raw = typeof content === "string" ? [{ type: "text", text: content }] : Array.isArray(content) ? content : [];
  const items = raw.flatMap((block) => {
    if (typeof block === "string") return [{ kind: "text", text: block }];
    if (block.type === "text") return [{ kind: "text", text: block.text ?? "" }];
    if (block.type === "thinking") return [{ kind: "thinking" }];
    if (block.type === "tool_use" || block.type === "toolCall") {
      const input = block.input ?? block.arguments ?? {};
      const detail = typeof input === "string" ? input : input.file_path ?? input.path ?? input.command ?? input.pattern ?? input.i ?? input.intent ?? "";
      return [{ kind: "tool", text: `${block.name ?? "tool"}${detail ? `  ${short(detail)}` : ""}` }];
    }
    return []; // tool_result and provider metadata stay hidden.
  });
  if (items.length === 0) return null;
  return { id: entry.uuid ?? entry.id ?? `${role}-${entry.timestamp ?? "entry"}`, role, items };
}

// Rows the pane draws: one per text block, and one per run of tool calls and
// thinking in between (they would otherwise be a wall of one-liners).
function toRows(messages) {
  const rows = [];
  for (const message of messages) {
    message.items.forEach((item, index) => {
      if (item.kind === "text") {
        if (item.text.trim()) rows.push({ id: `${message.id}-${index}`, kind: message.role, text: item.text });
        return;
      }
      let run = rows.at(-1);
      if (run?.kind !== "activity") rows.push((run = { id: `${message.id}-${index}`, kind: "activity", tools: [], thinking: 0 }));
      if (item.kind === "thinking") run.thinking += 1;
      else run.tools.push(item.text);
    });
  }
  return rows;
}

const PAD_X = 28; // the pane's side margin
const MAX_TOOLS = 4; // tool lines an activity row shows before "+N more"

// A first guess until the hidden copy has been measured (a frame or two).
function estimate(row, width) {
  if (row.kind === "activity") return 20 + 20 * (Math.min(row.tools.length, MAX_TOOLS + 1) + (row.thinking && !row.tools.length ? 1 : 0));
  const perLine = Math.max(20, Math.floor((width - 2 * PAD_X - 32) / 8));
  const lines = row.text.split("\n").reduce((n, line) => n + Math.max(1, Math.ceil(line.length / perLine)), 0);
  return lines * 26 + (row.kind === "user" ? 56 : 28);
}

export default class Transcript extends View {
  init(_props, cx) {
    this.file = null;
    this.source = null;
    this.agent = null;
    this.raw = null;
    this.messages = [];
    this.rows = [];
    this.width = 0; // the list's width, from on_size_change
    this.heights = new Map(); // row id -> measured height at this.width
    this.error = null;
    this.changedAt = 0;
    this.scroll = VirtualListScrollHandle.new();
    this.following = true;
    this.hasNew = false;
    cx.spawn(async (cx) => {
      for (;;) {
        await this.poll(cx);
        await cx.sleep(POLL_MS);
      }
    });
    cx.timer.every(5000, (cx) => cx.notify());
  }

  async discover() {
    const pinned = props()?.file;
    if (pinned) {
      this.file = pinned;
      this.source = pinned.includes("/.omp/") ? "omp" : "claude";
      this.agent = this.source === "omp" ? "omp" : "Claude";
      return;
    }
    // Look again now and then, so a fresh session (/clear, new thread) takes over.
    if (this.file && Date.now() - (this.discoveredAt ?? 0) < REDISCOVER_MS) return;
    this.discoveredAt = Date.now();
    // A mod pane may not get its own pane id in props; fall back to the focused tab.
    const own = panes().find((pane) => pane.pane === props()?.pane);
    const tab = own?.tab ?? focused()?.tab;
    const sameTab = panes().filter((pane) => pane.tab === tab && pane.terminal);
    const terminal = sameTab.find((pane) => toolOf(pane)) ?? sameTab[0];
    if (!terminal?.cwd) return;
    const preferred = toolOf(terminal);
    const claudeKey = terminal.cwd.replace(/[^A-Za-z0-9]/g, "-"); // Claude Code dashes every non-alphanumeric
    const ompKey = terminal.cwd.startsWith(home()) ? terminal.cwd.slice(home().length).replace(/\//g, "-") : terminal.cwd.replace(/\//g, "-");
    const script = preferred === "omp"
      ? 'ls -t "$HOME/.omp/agent/sessions/$2"/*.jsonl 2>/dev/null | head -n 1'
      : preferred === "claude"
        ? 'ls -t "$HOME/.claude/projects/$1"/*.jsonl 2>/dev/null | head -n 1'
        : 'ls -t "$HOME/.claude/projects/$1"/*.jsonl "$HOME/.omp/agent/sessions/$2"/*.jsonl 2>/dev/null | head -n 1';
    const result = await exec("sh", ["-c", script, "transcript", claudeKey, ompKey]);
    const file = result.stdout.trim().split("\n")[0];
    if (!file) return;
    this.file = file;
    this.source = file.includes("/.omp/") ? "omp" : "claude";
    this.agent = this.source === "omp" ? "omp" : "Claude";
  }

  async poll(cx) {
    try {
      const previousFile = this.file;
      const previousLast = this.rows.at(-1)?.id;
      await this.discover();
      if (!this.file) {
        this.error = null;
        cx.notify();
        return;
      }
      const result = await exec("tail", ["-n", "300", this.file]);
      if (result.code !== 0) throw new Error(result.stderr.trim() || `tail exited ${result.code}`);
      if (result.stdout === this.raw) return;
      this.raw = result.stdout;
      this.messages = result.stdout.split("\n").flatMap((line) => {
        if (!line) return [];
        try {
          const message = blocks(JSON.parse(line), this.source);
          return message ? [message] : [];
        } catch (_) {
          return []; // The final line may still be in flight.
        }
      });
      this.rows = toRows(this.messages);
      const fileChanged = previousFile !== this.file;
      const lastChanged = previousLast !== this.rows.at(-1)?.id;
      if (fileChanged) this.following = true;
      if (this.following) {
        this.hasNew = false;
        this.scroll.scroll_to_bottom();
      } else if (previousLast && lastChanged) {
        this.hasNew = true;
      }
      this.changedAt = Date.now();
      this.error = null;
      cx.notify();
    } catch (error) {
      this.error = String(error.message ?? error);
      cx.notify();
    }
  }

  // One row, at the list's width so Markdown wraps instead of running off.
  row(row, t, prefix = "") {
    const id = `${prefix}${row.id}`;
    const base = div().id(`row-${id}`).w(this.width).px(PAD_X);
    if (row.kind === "activity") {
      const shown = row.tools.slice(0, MAX_TOOLS);
      const more = row.tools.length - shown.length;
      const note = [more > 0 && `+${more} more`, row.thinking && `thought ${row.thinking}×`].filter(Boolean).join(" · ");
      return base.py(10).child(
        v_flex()
          .gap(2)
          .pl(12)
          .border_l(2)
          .border_color(t.border)
          .text_size(12)
          .text_color(t.dim)
          .children(shown.map((tool, index) => div().id(`${id}-tool-${index}`).h(20).overflow_hidden().text_ellipsis().whitespace_nowrap().child(`› ${tool}`)))
          .when(Boolean(note), (el) => el.child(div().h(20).child(note))),
      );
    }
    const text = TextView.markdown(`${id}-md`, row.text).selectable().w_full().text_color(t.foreground);
    if (row.kind === "user") {
      return base.pt(18).pb(10).child(div().w_full().px(16).py(12).bg(t.hover).border(1).border_color(t.border).rounded(10).child(text));
    }
    return base.py(10).child(text);
  }

  height(row) {
    return this.heights.get(row.id) ?? estimate(row, this.width);
  }

  render(_cx) {
    const t = theme();
    const idle = !this.changedAt || Date.now() - this.changedAt > 10000;
    const state = this.file ? (idle ? "idle" : "live") : "waiting";
    const empty = this.error ?? (this.file ? "No user or assistant messages in the last 300 lines." : "No Claude or omp session found beside this pane.");
    const rows = this.rows;
    // v_virtual_list places rows at the heights it is given, and Markdown
    // heights can't be known up front, so each new row is first drawn hidden
    // (outside the list, where handlers are allowed) and its size is kept.
    const unmeasured = this.width ? rows.filter((row) => !this.heights.has(row.id)) : [];

    const body = v_flex()
      .id("transcript-body")
      .relative()
      .flex_1()
      .min_h(0)
      .overflow_hidden()
      .on_size_change((size, cx) => {
        if (Math.round(size.width) === this.width) return;
        this.width = Math.round(size.width);
        this.heights.clear(); // rewrapped: measure again
        cx.notify();
      })
      .on_scroll_wheel((event, cx) => {
        const y = event.delta_lines?.y ?? event.delta.y;
        if (y < 0 && this.following) {
          this.following = false;
          cx.notify();
        }
      });

    if (!this.width) return this.frame(t, state, empty, body);

    return this.frame(t, state, empty, body
      .child(
        v_virtual_list(
          "transcript-scroll",
          rows.length,
          rows.map((row) => this.height(row)),
          (index) => rows[index].id,
          (range) => rows.slice(range.start, range.end).map((row) => this.row(row, t)),
        ).size_full().track_scroll(this.scroll),
      )
      .child(Scrollbar.vertical("transcript-scroll").absolute().inset_0())
      .when(unmeasured.length > 0, (el) => el.child(
        div().absolute().top(0).left(0).w(this.width).invisible().children(unmeasured.map((row) =>
          div().id(`measure-${row.id}`).w(this.width).on_size_change((size, cx) => {
            this.heights.set(row.id, Math.ceil(size.height));
            if (this.following) this.scroll.scroll_to_bottom();
            cx.notify();
          }).child(this.row(row, t, "measure-")),
        )),
      ))
      .when(this.hasNew, (el) => el.child(
        div()
          .id("transcript-new")
          .absolute()
          .right(18)
          .bottom(14)
          .px(12)
          .py(6)
          .rounded(14)
          .bg(t.selected)
          .border(1)
          .border_color(t.border)
          .text_size(11)
          .text_color(t.foreground)
          .cursor_pointer()
          .hover((s) => s.bg(t.hover))
          .on_click((_event, cx) => {
            this.following = true;
            this.hasNew = false;
            this.scroll.scroll_to_bottom();
            cx.notify();
          })
          .child("↓ New messages"),
      )));
  }

  frame(t, state, empty, body) {
    return v_flex()
      .size_full()
      .min_h(0)
      .bg(t.chrome)
      .child(
        h_flex()
          .h(40)
          .flex_none()
          .items_center()
          .gap(10)
          .px(PAD_X - 8)
          .border_b(1)
          .border_color(t.border)
          .child(div().w(3).h(18).rounded(2).bg(this.source === "claude" ? "#d97757" : t.accent))
          .child(div().font_medium().text_color(t.foreground).child(this.agent ?? "Transcript"))
          .child(div().flex_1().min_w(0).text_size(11).text_color(t.dim).overflow_hidden().text_ellipsis().whitespace_nowrap().child(baseName(this.file)))
          .child(div().text_size(10.5).text_color(state === "live" ? t.accent : t.dim).child(state)),
      )
      .when(Boolean(this.error) || this.rows.length === 0, (el) => el.child(div().px(PAD_X).py(18).text_size(12).text_color(this.error ? t.blocked : t.dim).child(empty)))
      .child(body);
  }
}

// TODO: image() only loads from appHome(); base64 blocks need a cache file first.
