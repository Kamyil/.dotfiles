// The status strip under the panes: the game repo's commits as XP and a level,
// the daily commit streak, today's haul, and how long this session has run
// (with a nudge to take a break every BREAK_MIN). Click XP to recount, click
// the timer to start a new session. Just for fun: nothing here is a metric.
import { div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { exec, notify } from "herdr";
import { C, ASSETS, findProject, baseName, clock, sfx } from "./game.js";

const REFRESH_MS = 60000;
const IDLE_MIN = 30; // a gap this long starts a new session
const BREAK_MIN = 50;

// Level L takes 150·L XP to clear, so each one is a bit longer than the last.
function levelOf(xp) {
  let level = 1;
  let need = 150;
  while (xp >= need) {
    xp -= need;
    level += 1;
    need = 150 * level;
  }
  return { level, into: xp, need };
}

const day = (d) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;

function parse(out) {
  const commits = [];
  for (const line of out.split("\n")) {
    if (line.startsWith("@")) commits.push({ date: line.slice(1).trim(), lines: 0 });
    else if (commits.length && /changed/.test(line)) {
      const n = (re) => Number(line.match(re)?.[1] ?? 0);
      commits[commits.length - 1].lines = n(/(\d+) insertion/) + n(/(\d+) deletion/);
      commits[commits.length - 1].add = n(/(\d+) insertion/);
      commits[commits.length - 1].del = n(/(\d+) deletion/);
    }
  }
  const xp = commits.reduce((sum, c) => sum + 20 + Math.min(Math.round(c.lines / 4), 100), 0);
  const today = day(new Date());
  const mine = commits.filter((c) => c.date === today);
  const dates = new Set(commits.map((c) => c.date));
  // A streak survives until a whole day passes with no commit.
  const cursor = new Date();
  if (!dates.has(today)) cursor.setDate(cursor.getDate() - 1);
  let streak = 0;
  while (dates.has(day(cursor))) {
    streak += 1;
    cursor.setDate(cursor.getDate() - 1);
  }
  return {
    xp,
    streak,
    today: { commits: mine.length, add: mine.reduce((s, c) => s + (c.add ?? 0), 0), del: mine.reduce((s, c) => s + (c.del ?? 0), 0) },
  };
}

function load(key, empty) {
  try {
    return JSON.parse(localStorage.getItem(key) ?? "null") ?? empty;
  } catch {
    return empty;
  }
}

export default class Xp {
  init(_props, cx) {
    this.root = null;
    this.stats = null;
    this.busy = false;
    const now = Date.now();
    const session = load("session", null);
    this.session = session && now - session.last < IDLE_MIN * 60000 ? session : { start: now, last: now };
    this.nextBreak = this.session.start + BREAK_MIN * 60000 * Math.ceil((now - this.session.start + 1) / (BREAK_MIN * 60000));
    this.saveSession();
    cx.spawn(async (cx) => {
      for (;;) {
        await this.refresh(cx);
        await cx.sleep(REFRESH_MS);
      }
    });
    cx.timer.every(1000, (cx) => this.tick(cx));
  }

  saveSession() {
    localStorage.setItem("session", JSON.stringify(this.session));
  }

  tick(cx) {
    const now = Date.now();
    if (now - this.session.last > IDLE_MIN * 60000) {
      // The Mac slept or Herdr was closed: a fresh session.
      this.session = { start: now, last: now };
      this.nextBreak = now + BREAK_MIN * 60000;
    }
    if (now - this.session.last > 30000) {
      this.session.last = now;
      this.saveSession();
    }
    if (now >= this.nextBreak) {
      const mins = Math.round((now - this.session.start) / 60000);
      notify({ title: "Rest at the campfire", body: `${mins} minutes in. Stretch, drink some water.`, level: "info", timeout: 15000 });
      sfx("rest");
      this.nextBreak = now + BREAK_MIN * 60000;
    }
    cx.notify();
  }

  async refresh(cx) {
    if (this.busy) return;
    this.busy = true;
    try {
      const root = await findProject();
      if (root !== this.root) this.stats = null;
      this.root = root;
      if (root) {
        const r = await exec("git", ["-C", root, "log", "--no-merges", "--format=@%ad", "--date=short-local", "--shortstat"]);
        if (r.code === 0) this.stats = parse(r.stdout);
        this.celebrate(root);
      }
    } catch {}
    this.busy = false;
    cx.notify();
  }

  celebrate(root) {
    if (!this.stats) return;
    const { level } = levelOf(this.stats.xp);
    const seen = load("levels", {});
    if (seen[root] && level > seen[root]) {
      notify({ title: `LEVEL UP! ${baseName(root)} is level ${level}`, body: "Keep committing, adventurer.", level: "success", timeout: 8000 });
      sfx("levelup");
    }
    if (seen[root] !== level) {
      seen[root] = level;
      localStorage.setItem("levels", JSON.stringify(seen));
    }
  }

  render() {
    const now = Date.now();
    const s = this.stats;
    const lv = s ? levelOf(s.xp) : null;
    const pct = lv ? Math.round((lv.into / lv.need) * 100) : 0;
    const sep = () => div().text_color(C.edgeHi).child("◆");

    return h_flex()
      .size_full()
      .px(10)
      .gap(10)
      .items_center()
      .bg(C.panel)
      .border_1()
      .border_color(C.edge)
      .text_size(11.5)
      .text_color(C.muted)
      .child(
        h_flex()
          .id("hud-xp")
          .flex_none()
          .gap(8)
          .items_center()
          .cursor_pointer()
          .tooltip(s ? `${s.xp} XP total in ${baseName(this.root)} · click to recount` : "No Godot project in focus")
          .on_click((_e, cx) => this.refresh(cx))
          .child(
            div()
              .flex_none()
              .px(6)
              .h(18)
              .flex()
              .items_center()
              .border_1()
              .border_color(C.gold)
              .bg(C.sunk)
              .font_bold()
              .text_color(C.gold)
              .child(lv ? `LV ${lv.level}` : "LV –"),
          )
          .child(div().w(150).h(8).border_1().border_color(C.edge).bg(C.sunk).child(div().h_full().w(`${pct}%`).bg(C.xp)))
          .child(div().text_color(C.dim).child(lv ? `${lv.into}/${lv.need} xp` : this.busy ? "counting…" : "no quest")),
      )
      .when(Boolean(s), (el) =>
        el
          .child(sep())
          .child(
            h_flex()
              .gap(5)
              .items_center()
              .tooltip("Days in a row with a commit")
              .child(svg(`${ASSETS}/icons/flame.svg`).size(13).text_color(s.streak ? C.warn : C.dim))
              .child(div().text_color(s.streak ? C.text : C.dim).child(s.streak === 1 ? "1 day" : `${s.streak} days`)),
          )
          .child(sep())
          .child(
            h_flex()
              .gap(6)
              .child(div().child(`today ${s.today.commits} commit${s.today.commits === 1 ? "" : "s"}`))
              .when(s.today.add > 0, (el) => el.child(div().text_color(C.ok).child(`+${s.today.add}`)))
              .when(s.today.del > 0, (el) => el.child(div().text_color(C.hp).child(`−${s.today.del}`))),
          ),
      )
      .child(div().flex_1())
      .child(
        h_flex()
          .id("hud-session")
          .flex_none()
          .gap(6)
          .items_center()
          .cursor_pointer()
          .tooltip(`Session time · break every ${BREAK_MIN} min · click to start over`)
          .on_click((_e, cx) => {
            const t = Date.now();
            this.session = { start: t, last: t };
            this.nextBreak = t + BREAK_MIN * 60000;
            this.saveSession();
            cx.notify();
          })
          .child(svg(`${ASSETS}/icons/hourglass.svg`).size(13).text_color(C.goldDim))
          .child(div().text_color(C.text).child(clock(now - this.session.start))),
      );
  }
}
