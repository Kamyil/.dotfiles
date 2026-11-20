// Injected into the threads bar by scripts/herdr-tab-art-setup.
// TAB_ART is generated from artwork/catalog.json with content-addressed paths.
const TAB_WIDTH = 180;
const TAB_HEIGHT = 42;
const TAB_EFFECTS = TAB_ART.__effects;

function tabArtwork(p) {
  return TAB_ART[p?.program?.key] ?? null;
}

function tabScenery(p, active, height) {
  const art = tabArtwork(p);
  return div()
    .absolute()
    .inset(1)
    .rounded(5)
    .overflow_hidden()
    .when(Boolean(art), (el) => el
      .child(image(art.background).absolute().left(0).top(-(84 - height) / 2).w(TAB_WIDTH).h(84))
      .child(div().absolute().inset_0().bg(active ? "#080b1200" : "#080b12b8"))
      .child(image(TAB_EFFECTS.label).absolute().inset_0().w(TAB_WIDTH).h(height)));
}

function tabIllustration(t, p, active) {
  const art = tabArtwork(p);
  if (!art) return tile(t, p);
  const dot = p?.status && p.status !== "idle" ? t[p.status] : null;
  return div()
    .relative()
    .flex_none()
    .w(24)
    .h(24)
    .flex()
    .items_center()
    .justify_center()
    .child((art.multicolor ? image(art.icon) : svg(art.icon).text_color(art.color))
      .w(22).h(22).opacity(active ? 1 : 0.45))
    .when(Boolean(dot), (el) => el.child(div()
      .absolute().top(0).right(0).w(8).h(8).rounded_full()
      .border_1().border_color(C.tray).bg(dot)));
}
