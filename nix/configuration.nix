# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  programs.hyprland.enable = true; # ships Hyprland + Xwayland

  users.groups.kamil = { };
  programs.zsh.enable = true;
   users.users.kamil = {
     shell = pkgs.zsh;
     isNormalUser = true;
     group = "kamil"; # Add this line
     description = "kamil";
     extraGroups = [ "networkmanager" "wheel" "docker" ];
     packages = with pkgs; [ ];
   };

  services.xserver.enable = false;

  # FIX: Improved greetd configuration with start-hyprland wrapper
  # start-hyprland is the official Hyprland wrapper that properly sets up session management
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd start-hyprland";
        user = "greeter";
      };
    };
  };

  # Ensure displayManager knows about Hyprland session
  services.displayManager.sessionPackages = [ pkgs.hyprland ];


  # Sreenshare, filepickers etc. (desktop portals)
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
  ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable OpenGL GPU acceleration
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.timeout = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  services.dnsmasq = {
    enable = true;
    settings = {
      address = [
        "/.localhost/127.0.0.1"
        "/.localhost/::1"
      ];
      "resolv-file" = "/run/NetworkManager/resolv.conf";
    };
  };

  networking.nameservers = [ "127.0.0.1" ];

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  fonts = {
    packages = with pkgs; [
      ubuntu-classic
      noto-fonts-color-emoji
      jetbrains-mono
      corefonts
    ];
    fontconfig.defaultFonts = {
      serif = [ "Ubuntu" ];
      sansSerif = [ "Ubuntu" ];
      monospace = [ "Berkeley Mono" "Ubuntu Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    neovim
    wget
    curl
    git
    xorg.xkeyboardconfig
    pkg-config
    openssl
    gnumake

    vivaldi
    slack
    keepassxc

    # Shell tools
    bash
    starship
    ripgrep
    delta
    bat
    btop
    fzf
    lsd

    # Terminals
    foot
    ghostty
    wezterm
    kitty

    # Database tools
    dbeaver-bin

    # Game development
    love

    # Others
    hyprpaper
    swaybg
    hypridle
    swaylock
    waybar
    impala
    bluetuith
    pulsemixer
    pamixer
    rfkill_udev
    wl-clipboard
    wtype
    grim
    slurp
    uwsm
    walker

     # AI - FIX: Replace the problematic buildFHSUserEnv with just bun
     bun
     nodejs
     
     # FIX: Add tuigreet to system packages
     tuigreet

     # opencode from unstable (pkgs already is unstable via flake)
     opencode
  ];

  system.activationScripts.dotfilesSymlinks = {
    text = ''
      # Remove existing paths that may block symlinks
      rm -rf /home/kamil/.config/nvim /home/kamil/.config/wezterm /home/kamil/.config/lazygit /home/kamil/.config/lazydocker /home/kamil/.config/lsd /home/kamil/.config/btop /home/kamil/.config/bat /home/kamil/.config/hypr /home/kamil/.config/waybar /home/kamil/.config/sketchybar /home/kamil/.config/aerospace /home/kamil/.config/yabai /home/kamil/.config/skhd /home/kamil/.config/ghostty /home/kamil/.config/tmux /home/kamil/.config/opencode /home/kamil/.config/kitty /home/kamil/.hammerspoon

      # Create direct symlinks
      ln -sfn /home/kamil/.dotfiles/nvim /home/kamil/.config/nvim
      ln -sfn /home/kamil/.dotfiles/wezterm /home/kamil/.config/wezterm
      ln -sfn /home/kamil/.dotfiles/config/lazygit /home/kamil/.config/lazygit
      ln -sfn /home/kamil/.dotfiles/config/lazydocker /home/kamil/.config/lazydocker
      ln -sfn /home/kamil/.dotfiles/config/lsd /home/kamil/.config/lsd
      ln -sfn /home/kamil/.dotfiles/config/btop /home/kamil/.config/btop
      ln -sfn /home/kamil/.dotfiles/bat /home/kamil/.config/bat
      ln -sfn /home/kamil/.dotfiles/config/hypr /home/kamil/.config/hypr
      ln -sfn /home/kamil/.dotfiles/config/waybar /home/kamil/.config/waybar
      ln -sfn /home/kamil/.dotfiles/sketchybar /home/kamil/.config/sketchybar
      ln -sfn /home/kamil/.dotfiles/config/aerospace /home/kamil/.config/aerospace
      ln -sfn /home/kamil/.dotfiles/yabai /home/kamil/.config/yabai
      ln -sfn /home/kamil/.dotfiles/skhd /home/kamil/.config/skhd
      ln -sfn /home/kamil/.dotfiles/config/ghostty /home/kamil/.config/ghostty
      ln -sfn /home/kamil/.dotfiles/config/tmux /home/kamil/.config/tmux
      ln -sfn /home/kamil/.dotfiles/config/opencode /home/kamil/.config/opencode
      ln -sfn /home/kamil/.dotfiles/config/kitty /home/kamil/.config/kitty
      ln -sfn /home/kamil/.dotfiles/hammerspoon /home/kamil/.hammerspoon
    '';
  };

  # Provide /bin/bash for tools expecting an absolute path
  systemd.tmpfiles.rules = [
    "L+ /bin/bash - - - - /run/current-system/sw/bin/bash"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

    # Docker configuration
    virtualisation.docker.enable = true;
    virtualisation.docker.daemon.settings = {
      userland-proxy = false;
      features = {
        buildkit = true;
      };
    };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
