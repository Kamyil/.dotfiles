// Floating terminals over the layout, and the second-brain space toggle.
// keys.json binds "nav.git" (Ctrl+Shift+G), "nav.shell" (Ctrl+Shift+F) and
// "nav.brain" (Ctrl+Shift+S); main.js hands those commands here.
//
// - git: lazygit in a large dialog, in the focused terminal's repo. The key
//   hides it and lazygit keeps running; a later press reopens the same one
//   while the repo is unchanged. Esc at lazygit's top level (and q) quits it
//   (lazygit-float.yml, merged over ~/.config/lazygit/config.yml), and the
//   dialog closes with it.
// - shell: one shell per space in a centered dialog. The key shows it, typing
//   straight away, and hides it again; so does a click beside it. The shell
//   keeps running while hidden; `exit` ends it.
// - brain: switches to the "second-brain" space (nvim on ~/second-brain,
//   made on first use) and back to the space you came from.
//
// Dialogs, unlike windows, take the keyboard when they open; nothing else can
// focus a terminal inside an overlay (pane.focus sees model panes only, and
// focused() doesn't report it). So "is it open" asks `herdr-app status` for
// a layout overlay, which only these floats open.
//
// Floating terminals are started with `hc run` and no herdr.space/tab labels,
// so they never become tabs. Their addresses live in shared state, so they
// outlive a layout switch and an app restart.
import { appHome, closeOverlay, exec, focused, hc, home, notify, openOverlay, run, setShared, shared, spaces, terminals } from "herdr";

const STATE = "nav.floats";
const BRAIN = "second-brain";

function state() {
  return /** @type {Record<string, any>} */ (shared(STATE) ?? {});
}

function remember(patch) {
  setShared(STATE, { ...state(), ...patch });
}

function live(address) {
  return Boolean(address) && terminals().some((t) => t.address === address && t.state === "live");
}

// The focused terminal's folder and machine, else its space's.
function here() {
  const f = focused();
  const space = f ? spaces().find((s) => s.id === f.space) : null;
  return { space: space?.id ?? null, machine: space?.machine ?? null, cwd: f?.cwd || space?.folder || home() };
}

async function repoRoot(at) {
  const r = await exec("git", ["rev-parse", "--show-toplevel"], { cwd: at.cwd, on: at.machine }).catch(() => null);
  return r && r.code === 0 ? r.stdout.trim() : at.cwd;
}

async function floatOpen() {
  const r = await exec("herdr-app", ["status"]).catch(() => null);
  if (!r || r.code !== 0) return false;
  try {
    return (JSON.parse(r.stdout).overlays ?? []).includes("layout");
  } catch (_) {
    return false;
  }
}

function dialog(address, width, height) {
  return { kind: "dialog", width, height, layout: { type: "column", children: [{ type: "block", content: { terminal: address } }] } };
}

// Esc at the top level quits lazygit only in the float: the extra file is
// merged over the person's config (here only; another machine keeps its own).
function lazygit(at) {
  if (at.machine) return ["lazygit"];
  const files = [`${home()}/.config/lazygit/config.yml`, `${appHome()}/mods/nav/lazygit-float.yml`];
  return ["env", `LG_CONFIG_FILE=${files.join(",")}`, "lazygit"];
}

async function start(argv, at, cwd) {
  const args = ["run", "--json", "--bg", "--no-parent", "--cwd", cwd];
  if (at.machine) args.push("--on", at.machine);
  const r = await hc([...args, "--", ...argv]);
  const address = r.code === 0 ? JSON.parse(r.stdout).address : null;
  if (!address) notify({ title: `Couldn't start ${argv[0] ?? "a shell"}`, body: r.stderr.trim(), level: "error" });
  return address;
}

const FLOATS = {
  git: { argv: lazygit, slot: () => "git", cwd: repoRoot, overlay: (address) => dialog(address, 0.92, 0.9) },
  shell: { argv: () => [], slot: (at) => `shell:${at.space}`, cwd: async (at) => at.cwd, overlay: (address) => dialog(address, 0.75, 0.7) },
};

export async function toggleFloat(name) {
  const spec = FLOATS[name];
  const at = here();
  const slot = spec.slot(at);
  let rec = state()[slot];
  // One float at a time: the key closes whichever is open, and toggles its own.
  if (await floatOpen()) {
    const mine = Boolean(rec?.overlay);
    if (mine) closeOverlay(rec.overlay);
    else run("overlay.close");
    setShared(STATE, Object.fromEntries(Object.entries(state()).map(([k, v]) => [k, v?.address ? { ...v, overlay: null } : v])));
    if (mine) return;
    rec = state()[slot];
  }
  const cwd = await spec.cwd(at);
  if (!rec || !live(rec.address) || (name === "git" && rec.cwd !== cwd)) {
    if (rec && live(rec.address)) run("terminal.kill", { terminal: rec.address });
    const address = await start(spec.argv(at), at, cwd);
    if (!address) return;
    rec = { address, cwd };
  }
  remember({ [slot]: { ...rec, overlay: openOverlay(spec.overlay(rec.address)) } });
}

export function toggleBrain() {
  const all = spaces();
  const current = all.find((s) => s.active);
  const brain = all.find((s) => s.name === BRAIN && !s.machine);
  if (current && brain && current.id === brain.id) {
    const back = state().brainPrev;
    if (back && all.some((s) => s.id === back)) run("space.select", { id: back });
    return;
  }
  if (current) remember({ brainPrev: current.id });
  if (brain) run("space.select", { id: brain.id });
  else run("space.new", { name: BRAIN, folder: `${home()}/${BRAIN}`, argv: ["nvim", "."] });
}
