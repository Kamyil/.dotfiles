{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-vm";
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "America/New_York"; # Adjust as needed

  # Enable Hyprland
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define user
  users.users.kamyil = {
    isNormalUser = true;
    description = "Kamyil";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
    firefox # fallback browser
    wl-clipboard
  ];

  # Enable zsh
  programs.zsh.enable = true;

  # Enable OpenGL for graphics
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  system.stateVersion = "23.11";
}