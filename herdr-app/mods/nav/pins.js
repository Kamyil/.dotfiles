// Pinned terminals: shells that stay on screen while you switch tabs.
// keys.json binds "nav.pin" (Ctrl+Shift+P) and "nav.pin-global" (Ctrl+Shift+O);
// main.js hands those commands here and calls syncPins() on every render.
//
// - space pin: one per space, started on its machine in the focused pane's
//   folder (else the space's).
//   Shown under the panes of that space's tabs only; another space shows its
//   own pin, or none.
// - global pin: one shell in the home folder, shown in every space.
//
// The nav layouts (scripts/herdr-app-setup) put a hidden "pins" row under the
// tab block, holding "pin-space" and "pin-global" terminal blocks. A layout
// block shows one fixed address, so on a space switch syncPins() writes that
// space's address into "pin-space" (layout.set) and shows or hides the blocks.
//
// The key shows or hides the pin; click it to type there. Herdr can't focus
// a layout terminal block from a mod (pane.focus {terminal} reports "no such
// pane", or succeeds without moving focus), so a click is the only way in.
// Hiding a focused pin hands focus back to the pane you came from. The shell keeps
// running while hidden; `exit` ends it, and the next press starts a new one.
// Pins are started like the floats (hc run, no herdr.space/tab labels), so
// they never become tabs; their addresses live in shared state and outlive a
// restart. Closing a space kills its pin.
//
// The pin button in each pane header ("nav.pin-pane", the pane in
// shared("nav.pin-request")) makes that pane's terminal its space's pin: its
// pane is parked and its herdr labels dropped, so it leaves its tab and keeps
// running. A pin the space had already goes back to a tab first. Each pin's
// header (pin-head.js) sends it back to a tab ("nav.unpin", "nav.unpin-global")
// or hides it.
import { focused, hc, home, layout, machines, notify, panes, run, setShared, shared, spaces, terminals } from "herdr";
import { start } from "./floats.js";

const STATE = "nav.pins";
const lastPane = {}; // space id -> the pane focused last there
let applied = null;

function state() {
  const s = /** @type {any} */ (shared(STATE) ?? {});
  return { global: s.global ?? null, spaces: s.spaces ?? {} };
}

function save(next) {
  setShared(STATE, next);
}

function live(address) {
  return Boolean(address) && terminals().some((t) => t.address === address && t.state === "live");
}

function findNode(node, id) {
  if (!node || typeof node !== "object") return null;
  if (node.id === id) return node;
  for (const child of node.children ?? []) {
    const hit = findNode(child, id);
    if (hit) return hit;
  }
  return null;
}

function currentSpace() {
  const all = spaces();
  const id = focused()?.space;
  return all.find((s) => s.id === id) ?? all.find((s) => s.active) ?? null;
}

// What should be on screen now: an address per block, or null for hidden.
function wanted() {
  const s = state();
  const space = currentSpace();
  const mine = space ? s.spaces[space.id] : null;
  return {
    "pin-space": mine?.shown && live(mine.address) ? mine.address : null,
    "pin-global": s.global?.shown && live(s.global.address) ? s.global.address : null,
  };
}

// A closed space's pin has no tab to go with: kill it. Only spaces on
// machines whose layout has loaded count as closed.
function prune() {
  const s = state();
  const ready = new Set(machines().filter((m) => m.layout === "ready").map((m) => m.name ?? ""));
  const ids = new Set(spaces().map((sp) => sp.id));
  let changed = false;
  const kept = {};
  for (const [id, rec] of Object.entries(s.spaces)) {
    // A remote terminal reads as not live while its machine connects.
    const known = ready.has(rec?.machine ?? "");
    const gone = known && !ids.has(id);
    if (gone || !rec?.address || (known && !live(rec.address))) {
      if (gone && live(rec?.address)) run("terminal.kill", { terminal: rec.address });
      changed = true;
      continue;
    }
    kept[id] = rec;
  }
  if (changed) save({ ...s, spaces: kept });
}

// Called on every render of the nav mod (Herdr re-renders on space, focus,
// terminal and shared-state changes); acts only when the picture changes.
export function syncPins() {
  const f = focused();
  if (f?.pane) lastPane[f.space] = f.pane;
  const tree = /** @type {any} */ (layout());
  // The terminal sits in "<pin>-term"; "<pin>" (with its header) shows or hides.
  const blocks = ["pin-space", "pin-global"].map((id) => findNode(tree, `${id}-term`));
  if (!findNode(tree, "pins") || blocks.some((b) => !b)) return;
  const want = wanted();
  const shown = blocks.map((b) => b.content?.terminal ?? null);
  const key = JSON.stringify([shared("layout"), want, shown]);
  if (key === applied) return;
  applied = key;
  // Swap an address in only when it differs: a hidden block keeps its old one.
  const pinOf = (b) => b.id.replace(/-term$/, "");
  const stale = blocks.filter((b) => want[pinOf(b)] && b.content?.terminal !== want[pinOf(b)]);
  if (stale.length) {
    const next = JSON.parse(JSON.stringify(tree));
    for (const b of stale) findNode(next, b.id).content = { terminal: want[pinOf(b)] };
    run("layout.set", { layout: next });
  }
  for (const id of ["pin-space", "pin-global"]) run(want[id] ? "layout.show" : "layout.hide", { id });
  run(want["pin-space"] || want["pin-global"] ? "layout.show" : "layout.hide", { id: "pins" });
  prune();
}

function focusBack() {
  const pane = lastPane[focused()?.space ?? ""];
  if (pane) run("pane.focus", { pane });
}

export async function togglePin(which) {
  const space = currentSpace();
  if (which === "space" && !space) return;
  const s = state();
  const rec = which === "space" ? s.spaces[space.id] : s.global;
  const f = focused();
  const focusedHere = Boolean(rec && f && !f.pane && f.terminal === rec.address);
  let next;
  if (rec && live(rec.address)) {
    next = { ...rec, shown: !rec.shown };
  } else {
    const at = { machine: which === "space" ? space.machine : null };
    // The focused pane's folder (a space's own folder is often just home),
    // else the space's; an empty one means the machine's home: hc picks it.
    const here = f?.pane ? f.cwd : null;
    const cwd = which === "space" ? here || space.folder || (at.machine ? null : home()) : home();
    const address = await start([], at, cwd);
    if (!address) return;
    next = { address, machine: at.machine, shown: true };
  }
  const latest = state();
  if (which === "space") save({ ...latest, spaces: { ...latest.spaces, [space.id]: next } });
  else save({ ...latest, global: next });
  syncPins();
  if (!next.shown && focusedHere) focusBack();
}

// Ctrl+h/j/k/l from a pin: pane.go can't start from a layout terminal block,
// so any direction goes back to the pane you came from.
export function navFromPin(dir) {
  const f = focused();
  if (!f || f.pane || !f.terminal) return false;
  const want = wanted();
  const onSpace = f.terminal === want["pin-space"];
  const onGlobal = f.terminal === want["pin-global"];
  if (!onSpace && !onGlobal) return false;
  focusBack();
  return true;
}

// The pin's record for a header: the shown space's, or the global one.
export function pinRecord(which) {
  const s = state();
  if (which === "global") return s.global;
  const space = currentSpace();
  return space ? s.spaces[space.id] ?? null : null;
}

// A new tab in the shown space; Herdr labels it there again.
function toTab(address) {
  run("terminal.keep", { terminal: address, place: "tab" });
}

export function unpin(which) {
  const s = state();
  const space = currentSpace();
  const rec = which === "global" ? s.global : space ? s.spaces[space.id] : null;
  if (!rec) return;
  if (live(rec.address)) toTab(rec.address);
  if (which === "global") save({ ...s, global: null });
  else {
    const rest = { ...s.spaces };
    delete rest[space.id];
    save({ ...s, spaces: rest });
  }
  syncPins();
}

export async function pinPane() {
  // A header's click names its pane just before; otherwise the focused one.
  const req = /** @type {any} */ (shared("nav.pin-request"));
  const fresh = req && Date.now() - (req.at ?? 0) < 3000;
  const target = fresh ? req.pane : focused()?.pane;
  if (fresh) setShared("nav.pin-request", null);
  const p = target && panes().find((x) => x.pane === target);
  if (!p?.terminal) return;
  const space = spaces().find((s) => (s.tabs ?? []).some((tab) => tab.id === p.tab));
  if (!space) return;
  // Parking a space's last pane would close the space, and prune() would
  // kill its pin with it.
  if ((space.tabs ?? []).reduce((n, tab) => n + (tab.panes ?? 0), 0) < 2) {
    notify({ title: "Can't pin the space's only pane", body: "Open another tab or split first.", level: "warning" });
    return;
  }
  const s = state();
  const old = s.spaces[space.id];
  if (old && old.address !== p.terminal && live(old.address)) toTab(old.address);
  run("terminal.park", { terminal: p.terminal });
  // Without its labels Herdr won't put it back in its tab on a restart.
  const r = await hc(["label", p.terminal, "herdr.space=", "herdr.tab="]);
  if (r.code !== 0) notify({ title: "Pinned, but its labels stayed", body: r.stderr.trim(), level: "warning" });
  const latest = state();
  const rec = { address: p.terminal, machine: space.machine, shown: true };
  save({ ...latest, spaces: { ...latest.spaces, [space.id]: rec } });
  syncPins();
}
