// Favicons for the threads layout's spaces list: a space whose project has a
// favicon or app icon shows it in place of its colored letter square.
// scripts/herdr-app-setup copies this into mods/spaces-square-threads as
// favicons.js.
//
// A space's folders are its terminals' live folders, in tab order, a folder
// named like the space first (a space's first terminal often sits elsewhere).
// In a git repo the icon is the best tracked favicon.{svg,png,ico},
// favicon-*.png, apple-touch-icon*.png or icon.{svg,png} (Godot, Expo) at most
// three folders deep; outside one, the same names in the folder itself and its
// public/, static/, assets/ and app/. Found on that space's machine, copied to
// ~/.config/herdr-app/data/favicons/ under its content's hash. Each folder is
// looked at once, then again every ten minutes while it's in use.
import { Avatar, AvatarImage, AvatarFallback } from "gpui-base";
import { exec, appHome } from "herdr";
import * as fs from "fs/promises";
import { Buffer } from "buffer";
import { createHash } from "crypto";

const DIR = "data/favicons";
const AGAIN = 10 * 60 * 1000;
const MAX_BYTES = 512 * 1024;

// $1: a folder. Prints the icon's path, then its bytes in base64; nothing if none.
const FIND = String.raw`
cd "$1" 2>/dev/null || exit 0
if top=$(git rev-parse --show-toplevel 2>/dev/null) && cd "$top"; then
  list=$(git ls-files 2>/dev/null)
else
  list=$(for d in . public static assets app src/app; do
    for n in favicon.svg favicon.png favicon.ico icon.svg icon.png apple-touch-icon.png; do
      [ -f "$d/$n" ] && printf '%s\n' "$d/$n"
    done
  done | sed 's|^\./||')
fi
best=$(printf '%s\n' "$list" | awk '
  /(^|\/)(node_modules|vendor|third_party|tests?|fixtures|examples?|docs?|\.[^\/]+)\// { next }
  {
    depth = gsub(/\//, "/"); if (depth > 3) next
    n = tolower($0); sub(/.*\//, "", n)
    if (n == "favicon.svg") s = 0; else if (n == "favicon.png") s = 1
    else if (n == "favicon.ico") s = 2; else if (n ~ /^favicon.*\.png$/) s = 3
    else if (n ~ /^apple-touch-icon.*\.png$/) s = 4; else if (n == "icon.svg") s = 5
    else if (n == "icon.png") s = 6; else next
    s = s * 10 + depth
    if (best == "" || s < bs) { best = $0; bs = s }
  }
  END { if (best != "") print best }')
[ -n "$best" ] && [ -f "$best" ] || exit 0
[ "$(wc -c < "$best")" -le ${MAX_BYTES} ] || exit 0
printf '%s\n' "$PWD/$best"
base64 < "$best" | tr -d '\n'
`;

const base = (path) => (path ?? "").replace(/\/+$/, "").split("/").pop().toLowerCase();

export default class Favicons {
  constructor() {
    this.found = {}; // [machine, folder] -> app-home-relative icon path, or null
    this.checked = {}; // [machine, folder] -> when it was last looked at
    this.pending = new Set();
    this.busy = false;
  }

  // A space's folders, the one named like it first.
  folders(s, ps) {
    const tabs = new Set((s.tabs ?? []).map((c) => c.id));
    const seen = [...new Set([...ps.filter((p) => tabs.has(p.tab) && p.cwd).map((p) => p.cwd), s.folder].filter(Boolean))];
    const name = base(s.name);
    return [...seen.filter((f) => base(f) === name), ...seen.filter((f) => base(f) !== name)]
      .map((f) => JSON.stringify([s.machine ?? null, f]));
  }

  // Looks at folders not seen yet or due again, one at a time.
  poll(sp, ps, cx) {
    const now = Date.now();
    for (const s of sp) for (const k of this.folders(s, ps)) {
      if (now - (this.checked[k] ?? -Infinity) > AGAIN) this.pending.add(k);
    }
    if (this.busy || !this.pending.size) return;
    this.busy = true;
    cx.spawn(async (cx) => {
      while (this.pending.size) {
        const [k] = this.pending;
        this.pending.delete(k);
        this.checked[k] = Date.now();
        const before = this.found[k];
        try {
          this.found[k] = await this.look(k);
        } catch {
          // The machine is away: keep what it showed, look again sooner.
          this.checked[k] = Date.now() - AGAIN + 30000;
        }
        if (this.found[k] !== before) cx.notify();
      }
      this.busy = false;
    });
  }

  async look(key) {
    const [on, folder] = JSON.parse(key);
    const r = await exec("sh", ["-c", FIND, "sh", folder], { on });
    const nl = r.stdout.indexOf("\n");
    if (r.code !== 0 || nl < 0) return null;
    const path = r.stdout.slice(0, nl);
    const data = r.stdout.slice(nl + 1).trim();
    const ext = (path.match(/\.(svg|png|ico)$/i)?.[1] ?? "png").toLowerCase();
    if (!data) return null;
    const name = `${DIR}/${createHash("sha1").update(data).digest("hex").slice(0, 16)}.${ext}`;
    const out = `${appHome()}/${name}`;
    if (!(await fs.exists(out).catch(() => false))) {
      await fs.mkdir(`${appHome()}/${DIR}`, { recursive: true }).catch(() => {});
      await fs.writeFile(out, Buffer.from(data, "base64"));
    }
    return name;
  }

  icon(s, ps) {
    for (const k of this.folders(s, ps)) if (this.found[k]) return this.found[k];
    return null;
  }

  // The space's favicon, or `letter` (its colored square) when it has none.
  mark(s, ps, letter) {
    const icon = this.icon(s, ps);
    if (!icon) return letter;
    return Avatar.new().size(18).flex_none().overflow_hidden()
      .image(AvatarImage.new(icon).size_full())
      .fallback(AvatarFallback.new().size_full().child(letter));
  }
}
