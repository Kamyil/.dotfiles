// Shared by the hud roles: the HUD palette, the Godot project in focus, and
// the game run (started by Play, stopped by Stop) that every role can see.
// The run lives in shared("hud.run") as { pid, project, log, started, ended,
// code }; the game writes its output to that log file, which the log role tails.
import { exec, focused, spaces, home, shared, setShared, playSound, settings, notify } from "herdr";
import * as fs from "fs/promises";

// Dark stone panels, bronze edges, gold for what matters.
export const C = {
  bg: "#0e0c0a",
  panel: "#15110d",
  raised: "#211a13",
  sunk: "#0b0907",
  edge: "#3a2d1c",
  edgeHi: "#5a4527",
  gold: "#d6a54a",
  goldDim: "#8a6a32",
  text: "#ece1c8",
  muted: "#c3b498",
  dim: "#9c8b6c",
  hp: "#c2413a",
  mana: "#3f7fd9",
  xp: "#a77bf0",
  ok: "#7fb069",
  warn: "#e0a84a",
};

export const ASSETS = "mods/hud";
const STATE = `${home()}/.local/state/herdr-hud`;
const GODOTS = [
  "/Applications/Godot.app/Contents/MacOS/Godot",
  "/Applications/Godot_mono.app/Contents/MacOS/Godot",
  `${home()}/Applications/Godot.app/Contents/MacOS/Godot`,
  `${home()}/Applications/Godot_mono.app/Contents/MacOS/Godot`,
];

export const tidy = (path) => (path && path.startsWith(home()) ? "~" + path.slice(home().length) : path ?? "");
export const baseName = (path) => (path ?? "").split("/").filter(Boolean).pop() ?? "";

export function sfx(name) {
  if (settings()?.sounds?.enabled === false || shared("hud.mute") === true) return;
  try {
    playSound(`${ASSETS}/sounds/${name}.mp3`);
  } catch {}
}

const exists = (path) => fs.exists(path).catch(() => false);

// The nearest folder at or above `dir` holding project.godot, stopping at home.
async function godotRoot(dir) {
  let d = dir?.replace(/\/+$/, "");
  while (d && d !== home() && d !== "") {
    if (await exists(`${d}/project.godot`)) return d;
    d = d.slice(0, d.lastIndexOf("/"));
  }
  return null;
}

// The focused terminal's project, else the active space's, else the last one found.
export async function findProject() {
  const space = spaces().find((s) => s.active);
  for (const dir of [focused()?.cwd, space?.folder]) {
    const root = await godotRoot(dir);
    if (root) {
      if (shared("hud.project") !== root) setShared("hud.project", root);
      return root;
    }
  }
  const last = shared("hud.project");
  return typeof last === "string" && (await exists(`${last}/project.godot`)) ? last : null;
}

async function godotBinary() {
  for (const path of GODOTS) if (await exists(path)) return path;
  const r = await exec("zsh", ["-lc", "command -v godot"]).catch(() => null);
  return r?.code === 0 ? r.stdout.trim() : null;
}

export const runState = () => shared("hud.run") ?? null;
export const isRunning = () => Boolean(runState()?.pid) && !runState()?.ended;

// Alive and still Godot: after a reboot the old pid may belong to anything.
async function alive(pid) {
  const r = await exec("ps", ["-p", String(pid), "-o", "comm="]).catch(() => null);
  return r?.code === 0 && /godot/i.test(r.stdout);
}

export async function play() {
  if (isRunning()) return stop().then(play);
  const project = await findProject();
  if (!project) {
    notify({ title: "No Godot project here", body: "Focus a terminal inside a folder with project.godot.", level: "warning" });
    return;
  }
  const godot = await godotBinary();
  if (!godot) {
    notify({ title: "Godot not found", body: "Install Godot in /Applications or put godot on PATH.", level: "error" });
    return;
  }
  await fs.mkdir(STATE, { recursive: true }).catch(() => {});
  const log = `${STATE}/${baseName(project)}.log`;
  // Detached, so the game outlives this exec; the shell prints its pid.
  const script = 'cd "$1" && nohup "$2" --path "$1" >"$3" 2>&1 </dev/null & echo $!';
  const r = await exec("sh", ["-c", script, "hud", project, godot, log]).catch((e) => ({ code: 1, stderr: String(e) }));
  const pid = Number(r.stdout?.trim());
  if (r.code !== 0 || !pid) {
    notify({ title: "Couldn't start the game", body: r.stderr?.trim() || "no pid", level: "error" });
    return;
  }
  setShared("hud.run", { pid, project, log, started: Date.now(), ended: null });
  sfx("play");
}

export async function stop() {
  const st = runState();
  if (!st?.pid || st.ended) return;
  await exec("kill", [String(st.pid)]).catch(() => {});
  setShared("hud.run", { ...st, ended: Date.now(), stopped: true });
  sfx("stop");
}

// Marks a run that ended by itself (the game window closed, or it crashed).
export async function checkRun() {
  const st = runState();
  if (!st?.pid || st.ended) return;
  if (!(await alive(st.pid))) {
    setShared("hud.run", { ...st, ended: Date.now() });
    sfx("stop");
  }
}

export function clock(ms) {
  const s = Math.max(0, Math.floor(ms / 1000));
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  const pad = (n) => String(n).padStart(2, "0");
  return h ? `${h}:${pad(m)}:${pad(s % 60)}` : `${m}:${pad(s % 60)}`;
}
