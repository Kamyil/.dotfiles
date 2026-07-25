const { Hints } = api;

const palette = {
  background: "#111318",
  surface: "#181820",
  elevated: "#1f1f28",
  hover: "#2a2a37",
  border: "#363646",
  foreground: "#cbc8bc",
  muted: "#8e8a80",
  accent: "#809ba7",
  good: "#7e9579",
  warning: "#a7956a",
  danger: "#c27672",
};

settings.theme = `
  .sk_theme {
    background: ${palette.background};
    color: ${palette.foreground};
    border: 1px solid ${palette.border};
    font-family: "Berkeley Mono SemiBold SemiCondensed", "Berkeley Mono", monospace;
    font-size: 13px;
  }

  .sk_theme input {
    color: ${palette.foreground};
    caret-color: ${palette.accent};
  }

  .sk_theme .url {
    color: ${palette.accent};
  }

  .sk_theme .annotation {
    color: ${palette.muted};
  }

  .sk_theme .omnibar_highlight {
    color: ${palette.warning};
  }

  #sk_omnibar {
    width: min(760px, 72vw);
    left: 50%;
    transform: translateX(-50%);
    border: 1px solid ${palette.border};
    border-radius: 10px;
    background: ${palette.background};
    box-shadow: 0 18px 60px rgba(0, 0, 0, 0.55);
    overflow: hidden;
  }

  .sk_omnibar_middle {
    top: 14%;
  }

  #sk_omnibarSearchArea {
    padding: 10px 14px;
    background: ${palette.surface};
    border-bottom: 1px solid ${palette.border};
  }

  #sk_omnibarSearchArea > input {
    font: inherit;
    font-size: 15px;
    background: transparent;
    border: 0;
    outline: 0;
  }

  .sk_theme #sk_omnibarSearchResult {
    max-height: 62vh;
    overflow: auto;
  }

  .sk_theme #sk_omnibarSearchResult > ul {
    padding: 6px;
  }

  .sk_theme #sk_omnibarSearchResult ul li {
    margin: 2px 0;
    padding: 7px 10px;
    border: 1px solid transparent;
    border-radius: 6px;
  }

  .sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: ${palette.background};
  }

  .sk_theme #sk_omnibarSearchResult ul li.focused {
    background: ${palette.elevated};
    border-color: ${palette.border};
  }

  #sk_usage,
  #sk_popup,
  #sk_editor {
    width: min(900px, 80vw);
    max-height: 80vh;
    top: 10%;
    left: 50%;
    transform: translateX(-50%);
    padding: 14px;
    background: ${palette.background};
    border: 1px solid ${palette.border};
    border-radius: 10px;
    box-shadow: 0 18px 60px rgba(0, 0, 0, 0.55);
  }

  #sk_tabs {
    background: ${palette.background};
    border: 1px solid ${palette.border};
    border-radius: 10px;
    box-shadow: 0 18px 60px rgba(0, 0, 0, 0.55);
    padding: 6px;
  }

  #sk_tabs div.sk_tab {
    background: ${palette.background};
    color: ${palette.foreground};
    border-radius: 6px;
  }

  #sk_tabs div.sk_tab:hover,
  #sk_tabs div.sk_tab:not(:has(.sk_tab_hint)) {
    background: ${palette.elevated};
  }

  #sk_tabs div.sk_tab_title {
    color: ${palette.foreground};
  }

  #sk_status,
  #sk_find,
  #sk_keystroke {
    padding: 6px 9px;
    background: ${palette.surface};
    color: ${palette.foreground};
    border: 1px solid ${palette.border};
    border-radius: 6px;
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.45);
    font: inherit;
  }
`;

Hints.style(`
  font-family: "Berkeley Mono SemiBold SemiCondensed", "Berkeley Mono", monospace;
  font-size: 12px;
  font-weight: 700;
  color: ${palette.background};
  background: ${palette.warning};
  border: 1px solid ${palette.background};
  border-radius: 4px;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.5);
`);

Hints.style(
  `
    div {
      color: ${palette.foreground};
      background: ${palette.surface};
      border: 1px solid ${palette.border};
    }
    div.begin {
      color: ${palette.warning};
    }
  `,
  "text",
);
