# Live-editable dotfile symlinks.
# Nix declares the link topology; the Git checkout provides mutable contents so
# apps can hot-reload config changes without a Home Manager rebuild.
{ }:

let
  commonLinks = {
    ".config/nvim" = "nvim";
    ".config/wezterm" = "wezterm";
    ".config/lazygit" = "lazygit";
    ".config/lazydocker" = "lazydocker";
    ".config/btop" = "btop";
    ".config/bat" = "bat";
    ".config/ghostty" = "ghostty";
    ".config/tmux" = "tmux";
    ".config/opencode" = "opencode";
    ".config/kitty" = "kitty";
    ".config/herdr" = "herdr";
    ".config/lsd" = "lsd";
    ".config/alacritty" = "alacritty";
    ".alacritty.toml" = "alacritty/alacritty.toml";
    ".config/hunk" = "hunk";
    ".config/starship.toml" = "starship/starship.toml";
    ".config/fontconfig/fonts.conf" = "fontconfig/fonts.conf";
    ".config/superfile" = "superfile";
    ".config/atuin/config.toml" = "atuin/config.toml";
    ".config/zennotes" = "zennotes";
    ".pi/agent" = "pi/agent";
    "second-brain/.obsidian" = "obsidian";
    ".omp/agent/themes" = "pi/agent/themes";
    "second-brain/.obsidian.vimrc" = "obsidian/obsidian.vimrc";
  };

  darwinLinks = {
    ".config/sketchybar" = "sketchybar";
    ".config/aerospace" = "aerospace";
    ".hammerspoon" = "hammerspoon";
    ".config/cmux" = "cmux";
  };

  linuxLinks = {
    ".config/hypr" = "hypr";
    ".config/waybar" = "waybar";
    ".config/quickshell" = "quickshell";
    ".config/dunst" = "dunst";
    ".config/satty/config.toml" = "satty/config.toml";
    ".config/elephant/calc.toml" = "elephant/calc.toml";
    ".config/elephant/desktopapplications.toml" = "elephant/desktopapplications.toml";
    ".config/omarchy/current/theme/walker.css" = "omarchy/current/theme/walker.css";
    ".config/omarchy/current/theme/waybar.css" = "omarchy/current/theme/waybar.css";
    ".config/omarchy/current/background" = "wallpapers/kanagawa-black-and-white-wallpaper.jpg";
    ".config/walker/config.toml" = "walker/config.toml";
    ".config/walker/themes/kanagawa.css" = "walker/themes/kanagawa.css";
    ".config/kmonad/config.kbd" = "kmonad/config.kbd";
    ".local/share/omarchy/bin" = "omarchy/bin";
    ".local/share/omarchy/default/walker/themes/omarchy-default/layout.xml" =
      "omarchy/default/walker/themes/omarchy-default/layout.xml";
    ".local/share/omarchy/default/walker/themes/omarchy-default/style.css" =
      "omarchy/default/walker/themes/omarchy-default/style.css";
    ".local/share/omarchy/default/waybar/indicators" = "omarchy/default/waybar/indicators";
  };
in
{
  inherit commonLinks darwinLinks linuxLinks;
}
