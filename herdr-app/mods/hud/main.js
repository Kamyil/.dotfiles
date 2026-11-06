// The quest layout's game-dev HUD, one mod in roles (props { role }), like
// Herdr 98:
//   bar  the hotbar over the panes: tabs as slots, Play/Stop, palette (bar.js)
//   log  the running game's output under the panes (log.js)
//   xp   the status strip: commit XP and level, streak, session timer (xp.js)
// game.js holds the palette and the Godot run every role shares. Shown by the
// quest layout (scripts/herdr-app-setup); keys in keys.json, layout:quest.
import { View, div } from "gpui-kit";
import { props } from "herdr";
import Bar from "./bar.js";
import Log from "./log.js";
import Xp from "./xp.js";

const ROLES = { bar: Bar, log: Log, xp: Xp };

export default class Hud extends View {
  init(p, cx) {
    const pr = props() ?? p ?? {};
    const Role = ROLES[pr.role];
    this.role = Role ? new Role() : null;
    this.role?.init?.(pr, cx);
  }

  render(cx) {
    if (!this.role) return div().child(`hud: no role "${props()?.role}"`);
    return this.role.render(cx);
  }
}
