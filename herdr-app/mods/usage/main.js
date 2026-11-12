// Claude Code and Codex plan usage from scripts/agent-usage. It stays loaded in
// its layout block, refreshing in the background, and shows the last result
// (kept in localStorage) at once after a restart: no cold fetch on open.
// Click the header to refresh now. Shown by the threads layout
// (scripts/herdr-app-setup). The quest layout gives props { skin: "hud" }:
// limits show as mana left instead of usage. The threads layout's title strip
// gives props { place: "strip" }: one line of small meters (strip()).
import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, home, theme, props } from "herdr";

const ICONS = { claude: { icon: "icons/claude.svg", color: "#d97757" }, codex: { icon: "mods/usage/codex.svg" } };
const REFRESH_MS = 5 * 60000;

function until(ms) {
  const m = Math.max(0, Math.round(ms / 60000));
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h ${m % 60}m`;
  return `${Math.floor(h / 24)}d ${h % 24}h`;
}

const ago = (ms) => (ms < 60000 ? "now" : `${until(ms)} ago`);

export default class Usage extends View {
  init(_props, cx) {
    this.hud = props()?.skin === "hud";
    this.inStrip = props()?.place === "strip";
    this.data = JSON.parse(localStorage.getItem("usage") ?? "null");
    this.busy = false;
    this.error = null;
    cx.spawn(async (cx) => {
      for (;;) {
        await this.refresh(cx);
        await cx.sleep(REFRESH_MS);
      }
    });
    cx.timer.every(60000, (cx) => cx.notify());
  }

  async refresh(cx) {
    if (this.busy) return;
    this.busy = true;
    cx.notify();
    try {
      const r = await exec(`${home()}/.dotfiles/scripts/agent-usage`);
      if (r.code !== 0) throw new Error(r.stderr.trim().split("\n").pop() || `exit ${r.code}`);
      const fresh = JSON.parse(r.stdout);
      // Keep a provider's last numbers when only this fetch failed.
      for (const p of fresh.providers) {
        const old = this.data?.providers.find((o) => o.id === p.id);
        if (p.error && !p.limits.length && old?.limits.length) Object.assign(p, { limits: old.limits, plan: old.plan, stale: true });
      }
      this.data = fresh;
      this.error = null;
      localStorage.setItem("usage", JSON.stringify(fresh));
    } catch (e) {
      this.error = String(e.message ?? e);
    }
    this.busy = false;
    cx.notify();
  }

  bar(limit, now, t) {
    const pct = Math.max(0, Math.min(100, limit.percent));
    const color = pct >= 90 ? t.blocked : pct >= 70 ? t.working : t.accent;
    if (this.hud) return this.mana(limit, pct, now, t);
    return v_flex()
      .gap(3)
      .child(
        h_flex()
          .text_size(11)
          .child(div().flex_1().text_color(t.dim).child(limit.label))
          .child(div().text_color(t.foreground).child(`${Math.round(pct)}%`))
          .when(Boolean(limit.resets), (el) => el.child(div().w(64).text_right().text_color(t.dim).child(until(limit.resets - now)))),
      )
      .child(div().h(4).bg(t.hover).child(div().h_full().w(`${pct}%`).bg(color)));
  }

  // The hud skin: what's left of a limit, as a mana bar that drains.
  mana(limit, pct, now, t) {
    const left = 100 - Math.round(pct);
    const color = left <= 10 ? "#c2413a" : left <= 30 ? "#e0a84a" : "#3f7fd9";
    return v_flex()
      .gap(3)
      .child(
        h_flex()
          .text_size(11)
          .child(div().flex_1().text_color(t.dim).child(limit.label))
          .child(div().text_color(t.foreground).child(`${left}% left`))
          .when(Boolean(limit.resets), (el) => el.child(div().w(64).text_right().text_color(t.dim).child(until(limit.resets - now)))),
      )
      .child(div().h(7).border_1().border_color(t.border).bg("#0b0907").child(div().h_full().w(`${left}%`).bg(color)));
  }

  // The title strip's line: per provider its icon, then each limit's label, a
  // small bar and its percent; the reset times, plan and age in its tooltip.
  // A click refreshes. The strip is a window_drag block, so presses stay here.
  strip(providers, now, status, t) {
    const meter = (l) => {
      const pct = Math.max(0, Math.min(100, l.percent));
      const color = pct >= 90 ? t.blocked : pct >= 70 ? t.working : t.accent;
      return h_flex()
        .gap(5)
        .items_center()
        .child(div().text_color(t.dim).child(l.label))
        .child(div().w(34).h(4).rounded(2).bg(t.hover).overflow_hidden().child(div().h_full().w(`${pct}%`).bg(color)))
        .child(div().min_w(24).text_color(t.foreground).child(`${Math.round(pct)}%`));
    };
    const tip = (p) =>
      [
        `${p.name}${p.plan ? ` ${p.plan}` : ""}`,
        ...p.limits.map((l) => `${l.label} ${Math.round(l.percent)}%${l.resets ? `, resets in ${until(l.resets - now)}` : ""}`),
        p.error && !p.stale ? p.error : p.stale ? "stale" : null,
        `updated ${status}`,
      ]
        .filter(Boolean)
        .join("\n");
    return h_flex()
      .id("usage-strip")
      .size_full()
      .justify_end()
      .items_center()
      .gap(8)
      .px(6)
      .text_size(11)
      .cursor_pointer()
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_mouse_down("right", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => this.refresh(cx))
      .when(Boolean(this.error), (el) => el.child(div().id("usage-error").size(6).rounded(3).bg(t.blocked).tooltip(this.error)))
      .children(
        providers.map((p) =>
          h_flex()
            .id(`usage-${p.id}`)
            .h(18)
            .gap(8)
            .items_center()
            .px(7)
            .rounded(5)
            .border_1()
            // A chip per provider, tinted with its icon's color where it has one.
            .border_color(ICONS[p.id]?.color ? `${ICONS[p.id].color}59` : t.border)
            .bg(ICONS[p.id]?.color ? `${ICONS[p.id].color}14` : t.raised)
            .hover((s) => s.bg(ICONS[p.id]?.color ? `${ICONS[p.id].color}29` : t.hover))
            .tooltip(tip(p))
            .when(this.busy || p.stale, (el) => el.opacity(0.6))
            .child(svg(ICONS[p.id]?.icon ?? "icons/agent.svg").size(12).flex_none().text_color(ICONS[p.id]?.color ?? t.foreground))
            .when(Boolean(p.error) && !p.stale && !p.limits.length, (el) => el.child(div().text_color(t.blocked).child("error")))
            .children(p.limits.map(meter)),
        ),
      );
  }

  render(cx) {
    const t = theme();
    const now = Date.now();
    const providers = this.data?.providers ?? [];
    const status = this.busy ? "refreshing…" : this.data ? ago(now - this.data.updated) : "";
    if (this.inStrip) return this.strip(providers, now, status, t);

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
        h_flex()
          .id("usage-refresh")
          .flex_none()
          .px(10)
          .py(8)
          .border_b(1)
          .border_color(t.border)
          .hover((s) => s.bg(t.hover))
          .on_click((_e, cx) => this.refresh(cx))
          .tooltip("Refresh")
          .when(this.hud, (el) => el.gap(7).child(svg("mods/hud/icons/potion.svg").size(13).flex_none().text_color(t.accent)))
          .child(
            this.hud
              ? div().flex_1().text_size(11.5).font_bold().text_color(t.accent).child("MANA")
              : div().flex_1().text_size(11.5).font_medium().text_color(t.dim).child("Usage"),
          )
          .child(div().text_size(11).text_color(t.dim).child(status)),
      )
      .when(Boolean(this.error), (el) => el.child(div().px(10).pt(8).text_size(11).text_color(t.blocked).child(this.error)))
      .child(
        v_flex()
          .id("usage-list")
          .flex_1()
          .min_h(0)
          .overflow_y_scrollbar()
          .px(10)
          .py(8)
          .gap(12)
          .children(
            providers.map((p) =>
              v_flex()
                .gap(6)
                .child(
                  h_flex()
                    .gap(7)
                    .items_center()
                    .child(svg(ICONS[p.id]?.icon ?? "icons/agent.svg").size(13).flex_none().text_color(ICONS[p.id]?.color ?? t.foreground))
                    .child(div().text_size(12).text_color(t.foreground).child(p.name))
                    .child(div().flex_1().text_size(11).text_color(t.dim).child(p.plan))
                    .when(Boolean(p.stale), (el) => el.child(div().text_size(11).text_color(t.dim).child("stale"))),
                )
                .when(Boolean(p.error) && !p.stale, (el) => el.child(div().text_size(11).text_color(t.blocked).child(p.error)))
                .children(p.limits.map((l) => this.bar(l, now, t))),
            ),
          ),
      );
  }
}
