// Harness icons for the threads layout's spaces list: one per coding agent
// running in a space (Claude Code, OpenCode, omp…), at the end of its row
// before the ahead/behind counts. scripts/herdr-app-setup copies this into
// mods/spaces-square-threads as agents.js.
//
// The icon is the pane's own from Herdr's program table, Claude Code's in the
// orange the threads and usage mods draw it in, with a status dot: yellow
// working, green idle or done, red blocked (waiting on you). Hovering names
// its thread (the agent's terminal title) and status; clicking goes to it.
import { div, svg, image } from "gpui-kit";
import { h_flex } from "gpui-base";
import { panes, run } from "herdr";

const COLORS = { claude: "#d97757" };
const STATUS = { working: "working", blocked: "needs you", done: "done", idle: "idle" };
// Leading spinner and status glyphs some agents put in their title.
const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();

// Space id -> its agents' panes, in tab order.
export function agentsBySpace(spaceList) {
  const tabOf = {};
  for (const s of spaceList) for (const t of s.tabs ?? []) tabOf[t.id] = s.id;
  const out = {};
  for (const p of panes()) {
    const space = tabOf[p.tab];
    if (space && p.program?.agent && p.program.icon) (out[space] ??= []).push(p);
  }
  return out;
}

function threadName(p) {
  const title = clean(p.title);
  const pr = p.program;
  return title && title !== pr.name && title.toLowerCase() !== pr.key && !/^[~/]/.test(title) ? title : null;
}

export function agentMarks(list, t, id) {
  if (!list?.length) return null;
  const dot = { working: t.ansi3, blocked: t.ansi1 };
  return h_flex().flex_none().gap(5).items_center().children(list.map((p) => {
    const pr = p.program;
    const glyph = pr.tint ? svg(pr.icon).size(13).text_color(COLORS[pr.key] ?? pr.color ?? t.foreground) : image(pr.icon).size(13);
    const tip = [threadName(p) ?? pr.name, `${pr.name} · ${STATUS[p.status] ?? "idle"}`].join("\n");
    return div().id(`space-agent-${id}-${p.pane}`).relative().flex_none().cursor_pointer()
      .tooltip(tip)
      // The row selects its space on mouse up after its own mouse down; keep it out.
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => {
        cx.stop_propagation();
        run("pane.focus", { pane: p.pane });
      })
      .child(glyph)
      .child(div().absolute().bottom(-1).right(-2).size(5).rounded(0).bg(dot[p.status] ?? t.ansi2));
  }));
}
