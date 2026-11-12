// Names a tab after the thread its agent is on: Claude Code (and OpenCode,
// omp) put the session's topic in the terminal title ("✳ Fix login redirect"),
// and that, without the status glyph, becomes the tab's name.
// A tab is only renamed while Herdr names it automatically or while it still
// carries the name set here: renaming it by hand (tab.rename) keeps that name,
// and tab.rename with "" hands it back. When the agent leaves, the tab gets its
// automatic name again. The names set here live in shared state, so they are
// still recognised as ours after a restart.
// In a tab with several agents, the focused one wins; otherwise the name stays
// while it is still one of their titles.
import { focused, panes, run, setShared, shared, spaces } from "herdr";

const STATE = "nav.tab-titles";
const MAX = 40;
// Titles that name the program rather than the thread.
const GENERIC = /^(claude( code)?|opencode|omp|pi|codex|zsh|bash|fish|shell)$/i;

function clean(title) {
  const t = String(title ?? "")
    .replace(/^[^\p{L}\p{N}]+/u, "")
    .replace(/\s+/g, " ")
    .trim();
  return t.length > MAX ? `${t.slice(0, MAX - 1).trimEnd()}…` : t;
}

function threadTitle(pane) {
  if (!pane.terminal || !(pane.status || pane.program?.agent)) return "";
  const t = clean(pane.title);
  if (!t || GENERIC.test(t) || t.toLowerCase() === String(pane.program?.name ?? "").toLowerCase()) return "";
  return t;
}

let applied = null;

// Called on every render of the nav mod; acts only when the picture changes.
export function syncTabTitles() {
  const ours = /** @type {Record<string, string>} */ ({ ...(shared(STATE) ?? {}) });
  const f = focused();
  const byTab = {};
  for (const p of panes()) {
    const t = threadTitle(p);
    if (t) (byTab[p.tab] ??= []).push({ pane: p.pane, title: t });
  }
  const tabs = spaces().flatMap((s) => s.tabs);
  const key = JSON.stringify([byTab, f?.pane, tabs.map((t) => [t.id, t.name, t.named]), ours]);
  if (key === applied) return;
  applied = key;

  const next = {};
  for (const tab of tabs) {
    const mine = ours[tab.id];
    // Named by hand: not ours to change.
    if (tab.named && mine !== tab.name) continue;
    const titles = byTab[tab.id] ?? [];
    let want = "";
    if (titles.length) {
      const here = titles.find((t) => t.pane === f?.pane);
      want = here ? here.title : titles.some((t) => t.title === tab.name) ? tab.name : titles[0].title;
    }
    if (want) {
      next[tab.id] = want;
      if (tab.name !== want) run("tab.rename", { id: tab.id, name: want });
    } else if (mine !== undefined && tab.named) {
      run("tab.rename", { id: tab.id, name: "" });
    }
  }
  if (JSON.stringify(next) !== JSON.stringify(ours)) setShared(STATE, next);
}
