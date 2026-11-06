// Harness icons for the threads layout's spaces list: one per coding agent
// running in a space (Claude Code, OpenCode, omp…), at the end of its row
// before the ahead/behind counts. scripts/herdr-app-setup copies this into
// mods/spaces-square-threads as agents.js.
//
// The icon is the pane's own from Herdr's program table, Claude Code's in the
// orange the threads and usage mods draw it in. A working agent is drawn full
// strength, an idle one dimmed, one waiting on you (blocked) with a dot.
import { div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes } from "herdr";

const COLORS = { claude: "#d97757" };

// Space id -> its agents' panes, one per harness (the busiest), in tab order.
export function agentsBySpace(spaceList) {
  const tabOf = {};
  for (const s of spaceList) for (const t of s.tabs ?? []) tabOf[t.id] = s.id;
  const rank = { blocked: 3, working: 2, done: 1 };
  const out = {};
  for (const p of panes()) {
    const space = tabOf[p.tab];
    if (!space || !p.program?.agent || !p.program.icon) continue;
    const mine = (out[space] ??= new Map());
    const had = mine.get(p.program.key);
    if (!had || (rank[p.status] ?? 0) > (rank[had.status] ?? 0)) mine.set(p.program.key, p);
  }
  return Object.fromEntries(Object.entries(out).map(([k, v]) => [k, [...v.values()]]));
}

export function agentMarks(list, t, id) {
  if (!list?.length) return null;
  return h_flex().id(`space-agents-${id}`).flex_none().gap(4).items_center()
    .tooltip(list.map((p) => `${p.program.name}: ${p.status ?? "idle"}`).join("\n"))
    .children(list.map((p) => {
      const pr = p.program;
      const glyph = pr.tint ? svg(pr.icon).size(13).text_color(COLORS[pr.key] ?? pr.color ?? t.foreground) : image(pr.icon).size(13);
      return div().relative().flex_none()
        .when(p.status !== "working" && p.status !== "blocked", (el) => el.opacity(0.55))
        .child(glyph)
        .when(p.status === "blocked", (el) => el.child(div().absolute().top(-2).right(-2).size(5).bg(t.blocked)));
    }));
}
