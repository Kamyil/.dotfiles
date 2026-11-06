// Resource bars for the threads layout's spaces list: CPU, GPU, RAM and disk
// per machine, in each machine header (scripts/herdr-app-setup copies this
// into mods/spaces-square-threads as stats.js).
//
// One `sh` per machine and poll, through Herdr's own connection to it (exec's
// `on`), so no new SSH session: it reads /proc and /sys on Linux, sysctl,
// vm_stat, ps and ioreg on macOS. CPU and the i915 GPU need two readings; the
// previous one is kept here instead of sleeping in the probe. A Pi has no GPU
// load to read, so its second bar is the SoC temperature.
import { div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { exec, window } from "herdr";

const EVERY = 5000; // window in front
const IDLE_EVERY = 60000; // window behind
const STALE = 30000; // drop bars older than this (a machine gone away)

const PROBE = `export LC_ALL=C
if [ -r /proc/stat ]; then
  read -r l < /proc/stat; echo "$l"
  while read -r k v _; do case "$k" in MemTotal:|MemAvailable:) echo "$k $v";; esac; done < /proc/meminfo
  for f in /sys/class/drm/card*/gt/gt0/rc6_residency_ms; do [ -r "$f" ] && { read -r v < "$f"; echo "rc6 $v"; break; }; done
  read -r up _ < /proc/uptime; echo "up $up"
  [ -r /sys/class/thermal/thermal_zone0/temp ] && { read -r v < /sys/class/thermal/thermal_zone0/temp; echo "temp $v"; }
  set -- $(df -Pk / | tail -n 1); echo "disk $3 $4"
else
  echo "ncpu $(sysctl -n hw.ncpu)"; echo "memsize $(sysctl -n hw.memsize)"
  ps -A -o %cpu= | awk '{s+=$1} END {print "cpusum", s}'
  vm_stat
  ioreg -r -d 1 -c IOAccelerator | grep -o '"Device Utilization %"=[0-9]*' | head -n 1
  set -- $(df -Pk /System/Volumes/Data | tail -n 1); echo "disk $3 $4"
fi`;

const clamp = (x) => Math.min(1, Math.max(0, x));
const gb = (bytes) => (bytes / 2 ** 30).toFixed(bytes < 10 * 2 ** 30 ? 1 : 0);

function parse(text) {
  const kv = {};
  for (const line of text.split("\n")) {
    const vm = /^(.+?):\s+(\d+)\.$/.exec(line);
    if (vm) kv[vm[1]] = Number(vm[2]);
    const page = /page size of (\d+) bytes/.exec(line);
    if (page) kv.page = Number(page[1]);
    const gpu = /"Device Utilization %"=(\d+)/.exec(line);
    if (gpu) kv.gpu = Number(gpu[1]);
    const [k, ...rest] = line.trim().split(/\s+/);
    if (k && !vm) kv[k.replace(/:$/, "")] = rest.map(Number);
  }
  return kv;
}

export default class MachineStats {
  constructor() {
    this.stats = {}; // machine ("" local) -> { cpu, gpu, temp, ram, disk, ... , at }
    this.prev = {}; // machine -> last raw counters
    this.busy = new Set();
    this.last = 0;
  }

  // Ask each of `names` (null: this computer) unless asked recently.
  poll(names, cx) {
    const now = Date.now();
    if (now - this.last < (window().active ? EVERY : IDLE_EVERY) - 500) return;
    this.last = now;
    for (const m of names) {
      const key = m ?? "";
      if (this.busy.has(key)) continue;
      this.busy.add(key);
      cx.spawn(async (cx) => {
        try {
          const r = await exec("sh", ["-c", PROBE], { on: m });
          if (r.code === 0) this.stats[key] = this.read(key, parse(r.stdout));
        } catch {}
        this.busy.delete(key);
        cx.notify();
      });
    }
  }

  read(key, kv) {
    const out = { at: Date.now() };
    const prev = this.prev[key] ?? {};
    const raw = {};
    if (kv.cpu) {
      const [user, nice, system, idle, iowait = 0, irq = 0, softirq = 0, steal = 0] = kv.cpu;
      raw.total = user + nice + system + idle + iowait + irq + softirq + steal;
      raw.idle = idle + iowait;
      if (prev.total != null && raw.total > prev.total) out.cpu = 1 - (raw.idle - prev.idle) / (raw.total - prev.total);
    } else if (kv.cpusum && kv.ncpu) {
      out.cpu = kv.cpusum[0] / 100 / kv.ncpu[0];
    }
    if (kv.rc6 && kv.up) {
      raw.rc6 = kv.rc6[0];
      raw.up = kv.up[0] * 1000;
      if (prev.up != null && raw.up > prev.up) out.gpu = 1 - (raw.rc6 - prev.rc6) / (raw.up - prev.up);
    } else if (kv.gpu != null) {
      out.gpu = kv.gpu / 100;
    } else if (kv.temp) {
      out.temp = kv.temp[0] / 1000;
    }
    if (kv.MemTotal && kv.MemAvailable) {
      out.ramTotal = kv.MemTotal[0] * 1024;
      out.ramUsed = out.ramTotal - kv.MemAvailable[0] * 1024;
    } else if (kv.memsize && kv.page) {
      out.ramTotal = kv.memsize[0];
      const pages = (kv["Anonymous pages"] ?? 0) + (kv["Pages wired down"] ?? 0) + (kv["Pages occupied by compressor"] ?? 0);
      out.ramUsed = pages * kv.page;
    }
    if (kv.disk) {
      const [used, avail] = kv.disk;
      out.diskUsed = used * 1024;
      out.diskTotal = (used + avail) * 1024;
    }
    for (const k of ["cpu", "gpu"]) if (out[k] != null) out[k] = clamp(out[k]);
    // A counter that went backwards (a reboot) gives no delta: keep the last figure.
    for (const k of ["cpu", "gpu"]) out[k] ??= this.stats[key]?.[k];
    this.prev[key] = raw;
    return out;
  }

  // The header's bars for machine `m`, or nothing before the first answer.
  view(m, t) {
    const s = this.stats[m ?? ""];
    if (!s || Date.now() - s.at > STALE) return div().flex_none();
    const level = (x, warn = 0.7, hot = 0.9) => (x >= hot ? t.ansi1 : x >= warn ? t.ansi3 : t.ansi2);
    const pct = (x) => (x == null ? "…" : `${Math.round(x * 100)}%`);
    const bar = (label, x, color) =>
      h_flex().flex_none().gap(3).items_center()
        .child(div().text_size(9).text_color(t.dim).child(label))
        .child(h_flex().w(16).h(4).flex_none().bg(t.hover)
          .child(div().h_full().w(x == null ? 0 : Math.max(1, Math.round(16 * x))).bg(x == null ? t.dim : color)));
    const ram = s.ramTotal ? s.ramUsed / s.ramTotal : null;
    const disk = s.diskTotal ? s.diskUsed / s.diskTotal : null;
    const second = s.temp != null
      ? bar("T", clamp((s.temp - 30) / 55), s.temp >= 80 ? t.ansi1 : s.temp >= 70 ? t.ansi3 : t.ansi2)
      : bar("G", s.gpu, s.gpu == null ? null : level(s.gpu));
    const tip = [
      `CPU ${pct(s.cpu)}`,
      s.temp != null ? `SoC ${Math.round(s.temp)}°C` : `GPU ${pct(s.gpu)}`,
      s.ramTotal ? `RAM ${gb(s.ramUsed)} / ${gb(s.ramTotal)} GB` : null,
      s.diskTotal ? `Disk ${gb(s.diskUsed)} / ${gb(s.diskTotal)} GB (${gb(s.diskTotal - s.diskUsed)} GB free)` : null,
    ].filter(Boolean).join("\n");
    return h_flex().id(`machine-stats-${m ?? "local"}`).flex_none().gap(5).items_center().tooltip(tip)
      .child(bar("C", s.cpu, s.cpu == null ? null : level(s.cpu)))
      .child(second)
      .child(bar("R", ram, ram == null ? null : level(ram, 0.8, 0.92)))
      .child(bar("D", disk, disk == null ? null : level(disk, 0.8, 0.92)));
  }
}
