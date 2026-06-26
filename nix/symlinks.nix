# Live-editable dotfile symlinks.
# Nix declares the link topology; the Git checkout provides mutable contents so
# apps can hot-reload config changes without a Home Manager rebuild.
{ lib }:

let
  commonLinks = {
    ".config/nvim" = "nvim";
    ".config/wezterm" = "wezterm";
    ".config/lazygit" = "config/lazygit";
    ".config/lazydocker" = "config/lazydocker";
    ".config/btop" = "config/btop";
    ".config/bat" = "bat";
    ".config/sketchybar" = "sketchybar";
    ".config/aerospace" = "config/aerospace";
    ".config/yabai" = "yabai";
    ".config/skhd" = "skhd";
    ".config/ghostty" = "config/ghostty";
    ".config/tmux" = "config/tmux";
    ".config/opencode" = "config/opencode";
    ".config/kitty" = "config/kitty";
    ".hammerspoon" = "hammerspoon";
  };

  darwinLinks = commonLinks // {
    ".config/lsd" = "config/lsd";
    ".config/alacritty" = "config/alacritty";
    ".alacritty.toml" = "config/alacritty/alacritty.toml";
  };

  linuxLinks = commonLinks // {
    ".config/hypr" = "config/hypr";
    ".config/waybar" = "config/waybar";
  };

  mkLinkCommand = home: repo: target: source: ''
    target=${lib.escapeShellArg "${home}/${target}"}
    source=${lib.escapeShellArg "${repo}/${source}"}

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "Refusing to overwrite non-symlink: $target" >&2
      exit 1
    fi

    mkdir -p "$(dirname "$target")"
    ln -sfn "$source" "$target"
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
