{ config, pkgs, ... }:

{
  home.username = "kamyil";
  home.homeDirectory = "/home/kamyil";

  # Core applications
  home.packages = with pkgs; [
    # Browser
    vivaldi

    # Terminal & shell
    wezterm
    zsh

    # Development
    neovim
    git

    # Hyprland essentials
    waybar          # status bar
    wofi           # app launcher
    dunst          # notifications
    swww           # wallpaper
    grim           # screenshots
    slurp          # screen selection
    wl-clipboard   # clipboard
  ];

  # Berkeley Mono font
  home.file = {
    ".local/share/fonts/berkeley-mono".source = /home/kamyil/fonts;
  };

  # Enable font configuration
  fonts.fontconfig.enable = true;

  # Wezterm config
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        font = wezterm.font("Berkeley Mono"),
        font_size = 12.0,
        color_scheme = "Catppuccin Mocha",
        enable_tab_bar = false,
        window_decorations = "RESIZE",
      }
    '';
  };

  # Neovim config
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Zsh config
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Git config
  programs.git = {
    enable = true;
    userName = "kamyil";
    userEmail = "your-email@example.com"; # Update this
  };

  home.stateVersion = "23.11";
}