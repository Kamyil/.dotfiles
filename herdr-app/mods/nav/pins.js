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
import { focused, home, layout, machines, run, setShared, shared, spaces, terminals } from "herdr";
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
  const blocks = ["pin-space", "pin-global"].map((id) => findNode(tree, id));
  if (!findNode(tree, "pins") || blocks.some((b) => !b)) return;
  const want = wanted();
  const shown = blocks.map((b) => b.content?.terminal ?? null);
  const key = JSON.stringify([shared("layout"), want, shown]);
  if (key === applied) return;
  applied = key;
  // Swap an address in only when it differs: a hidden block keeps its old one.
  const stale = blocks.filter((b) => want[b.id] && b.content?.terminal !== want[b.id]);
  if (stale.length) {
    const next = JSON.parse(JSON.stringify(tree));
    for (const b of stale) findNode(next, b.id).content = { terminal: want[b.id] };
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
