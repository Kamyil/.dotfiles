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

function itemHeight(message) {
  const content = message.items.reduce((height, item) => {
    if (item.kind !== "text") return height + 24;
    return height + item.text.split("\n").reduce((lines, line) => lines + Math.max(1, Math.ceil(line.length / 48)), 0) * 19;
  }, 0);
  return Math.max(44, content + (message.role === "user" ? 36 : 24));
}

export default class Transcript extends View {
  init(_props, cx) {
    this.file = null;
    this.source = null;
    this.agent = null;
    this.raw = null;
    this.messages = [];
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
      const previousLast = this.messages.at(-1)?.id;
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
      const fileChanged = previousFile !== this.file;
      const lastChanged = previousLast !== this.messages.at(-1)?.id;
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

  item(message, t) {
    const user = message.role === "user";
    return v_flex()
      .id(`message-${message.id}`)
      .mx(user ? 12 : 20)
      .my(7)
      .px(user ? 14 : 0)
      .py(user ? 11 : 5)
      .gap(7)
      .when(user, (el) => el.bg(t.hover).border(1).border_color(t.border).rounded(8))
      .children(message.items.map((item, index) => {
        const id = `${message.id}-${index}`;
        if (item.kind === "text") return TextView.markdown(id, item.text).selectable().text_color(t.foreground);
        if (item.kind === "thinking") return div().id(id).text_size(11).text_color(t.dim).child("thinking…");
        return h_flex().id(id).gap(7).text_size(11).text_color(t.dim).child("›").child(item.text);
      }));
  }

  render(_cx) {
    const t = theme();
    const idle = !this.changedAt || Date.now() - this.changedAt > 10000;
    const state = this.file ? (idle ? "idle" : "live") : "waiting";
    const empty = this.error ?? (this.file ? "No user or assistant messages in the last 300 lines." : "No Claude or omp session found beside this pane.");
    const feed = v_virtual_list(
      "transcript-scroll",
      this.messages.length,
      this.messages.map(itemHeight),
      (index) => this.messages[index].id,
      (range) => this.messages.slice(range.start, range.end).map((message) => this.item(message, t)),
    ).track_scroll(this.scroll);

    return v_flex()
      .size_full()
      .min_h(0)
      .bg(t.chrome)
      .child(
        h_flex()
          .h(38)
          .flex_none()
          .items_center()
          .gap(9)
          .px(12)
          .border_b(1)
          .border_color(t.border)
          .child(div().w(3).h(18).rounded(2).bg(this.source === "claude" ? "#d97757" : t.accent))
          .child(div().font_medium().text_color(t.foreground).child(this.agent ?? "Transcript"))
          .child(div().flex_1().min_w(0).text_size(11).text_color(t.dim).overflow_hidden().child(baseName(this.file)))
          .child(div().text_size(10.5).text_color(state === "live" ? t.accent : t.dim).child(state)),
      )
      .when(Boolean(this.error) || this.messages.length === 0, (el) => el.child(div().px(20).py(18).text_size(12).text_color(this.error ? t.blocked : t.dim).child(empty)))
      .child(
        v_flex()
          .relative()
          .flex_1()
          .min_h(0)
          .py(7)
          .on_scroll_wheel((event, cx) => {
            const y = event.delta_lines?.y ?? event.delta.y;
            if (y < 0 && this.following) {
              this.following = false;
              cx.notify();
            }
          })
          .child(feed)
          .child(Scrollbar.vertical("transcript-scroll").absolute().inset_0())
          .when(this.hasNew, (el) => el.child(
            div()
              .absolute()
              .right(14)
              .bottom(12)
              .px(11)
              .py(6)
              .rounded(12)
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
          )),
      );
  }
}

// TODO: image() only loads from appHome(); base64 blocks need a cache file first.
