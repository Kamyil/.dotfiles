{ pkgs, ... }:

{
  networking = {
    hostName = "malinka";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "kamil" ];
      X11Forwarding = false;
    };
  };

  users = {
    mutableUsers = false;
    groups.kamil.gid = 1000;
    users.kamil = {
      uid = 1000;
      isNormalUser = true;
      group = "kamil";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJiuMFNmYYkbod/nSvrjgd20n1sD1q7tnf228ioIA2Ju mccom_kks@mccom.pl"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZkp/BPlXCidN/qW8Emv23EbzKuFI7XKgX5qDILzuld kamyilksen@gmail.com"
      ];
    };
  };

  # SSH keys are the only login mechanism, so remote administration must not
  # depend on a password that deliberately does not exist.
  security.sudo.wheelNeedsPassword = false;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    libraspberrypi
    raspberrypi-eeprom
    smartmontools
    tmux
    usbutils
    vim
  ];

  services.fstrim.enable = true;

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  system.stateVersion = "26.05";
}
