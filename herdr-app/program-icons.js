// Installed with the tab artwork catalog, shared by the sidebar widgets.
import { div, svg, image } from "gpui-kit";

export function programIcon(key, size, fallback = null) {
  const art = PROGRAM_ICONS[key];
  if (art) return svg(art.icon).size(size).flex_none().text_color(art.color);
  if (!fallback?.icon) return div().size(size).flex_none();
  return fallback.tint
    ? svg(fallback.icon).size(size).flex_none().text_color(fallback.color ?? "#cbd8e5")
    : image(fallback.icon).size(size).flex_none();
}
