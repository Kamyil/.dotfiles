# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ pkgs, ... }:

let
  opencode-overlay = import ../nix/overlays/opencode.nix;
  omp-overlay = import ../nix/overlays/omp.nix;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./bootstrap.nix
  ];

  programs.hyprland.enable = true; # ships Hyprland + Xwayland

  # Enable nix-ld for running dynamically linked binaries (like opencode)
  programs.nix-ld.enable = true;

  users.groups.kamil = {
    gid = 1000;
  };
  programs.zsh.enable = true;
  users.users.kamil = {
    uid = 1000;
    shell = pkgs.zsh;
    isNormalUser = true;
    group = "kamil"; # Add this line
    description = "kamil";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
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
  hardware.enableRedistributableFirmware = true;

  services.fwupd.enable = true;
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.timeout = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  # Disable the damaged internal Intel AX210 Wi-Fi adapter.
  boot.blacklistedKernelModules = [ "iwlwifi" ];

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
      "addn-hosts" = "/etc/dnsmasq-private-hosts";
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
      liberation_ttf
      nerd-fonts.comic-shanns-mono
    ];
    fontconfig.defaultFonts = {
      serif = [ "Liberation Sans" ];
      sansSerif = [ "Liberation Sans" ];
      monospace = [
        "Berkeley Mono SemiBold SemiCondensed"
        "Ubuntu Mono"
      ];
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

  # Apply custom overlays
  nixpkgs.overlays = [
    opencode-overlay
    omp-overlay
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Recovery and system integration
    vim
    bash
    xorg.xkeyboardconfig
    pkg-config
    openssl
    gnumake
    tuigreet

    # Desktop applications
    vivaldi
    slack
    keepassxc
    foot
    ghostty
    dbeaver-bin
    love

    # Hyprland session tools
    hyprpaper
    swaybg
    hypridle
    nwg-displays
    hyprsunset
    swaylock
    waybar
    quickshell
    pulseaudio
    dunst
    libnotify
    pulsemixer
    netcat-openbsd
    pamixer
    rfkill_udev
    wl-clipboard
    wtype
    grim
    slurp
    uwsm
    walker
  ];

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
    userland-proxy = true;
    features = {
      buildkit = true;
    };
  };
  virtualisation.docker.enableOnBoot = true;
  environment.variables.DOCKER_BUILDKIT = "1";
  environment.variables.COMPOSE_DOCKER_CLI_BUILD = "1";

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
  system.stateVersion = "26.05"; # Did you read the comment?

}
