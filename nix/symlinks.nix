# Live-editable dotfile symlinks.
# Nix declares the link topology; the Git checkout provides mutable contents so
# apps can hot-reload config changes without a Home Manager rebuild.
{ lib }:

let
  commonLinks = {
    ".config/nvim" = "nvim";
    ".config/wezterm" = "wezterm";
    ".config/lazygit" = "lazygit";
    ".config/lazydocker" = "lazydocker";
    ".config/btop" = "btop";
    ".config/bat" = "bat";
    ".config/sketchybar" = "sketchybar";
    ".config/aerospace" = "aerospace";
    ".config/ghostty" = "ghostty";
    ".config/tmux" = "tmux";
    ".config/opencode" = "opencode";
    ".config/kitty" = "kitty";
    ".hammerspoon" = "hammerspoon";
    ".config/herdr" = "herdr";
    ".config/cmux" = "cmux";
  };

  darwinLinks = commonLinks // {
    ".config/lsd" = "lsd";
    ".config/alacritty" = "alacritty";
    ".alacritty.toml" = "alacritty/alacritty.toml";
  };

  linuxLinks = commonLinks // {
    ".config/hypr" = "hypr";
    ".config/waybar" = "waybar";
  };

  mkLinkCommand = home: repo: target: source: ''
    target=${lib.escapeShellArg "${home}/${target}"}
    source=${lib.escapeShellArg "${repo}/${source}"}
    if [ ! -e "$source" ]; then
      echo "Missing dotfile source: $source" >&2
      exit 1
    fi

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Skipping non-symlink target: $target" >&2
    else
      mkdir -p "$(dirname "$target")"
      ln -sfn "$source" "$target"
    fi
  '';

  mkActivationScript = links: { home, repo }:
    lib.concatStringsSep "\n" (lib.mapAttrsToList (mkLinkCommand home repo) links);
in
{
  inherit commonLinks darwinLinks linuxLinks;

  mkDarwinActivation = { home ? "/Users/kamil", repo ? "${home}/.dotfiles" }:
    mkActivationScript darwinLinks { inherit home repo; };

  mkLinuxActivation = { home ? "/home/kamil", repo ? "${home}/.dotfiles" }:
    mkActivationScript linuxLinks { inherit home repo; };
}
