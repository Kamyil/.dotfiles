{ lib, ... }:

{
  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      generic-extlinux-compatible.enable = true;
    };

  };

  hardware.raspberry-pi.firmware = {
    enable = true;
    path = "/boot/firmware";
    uboot.enable = true;
  };
  # Avoid the Raspberry Pi module shrinker probing unavailable DRM aliases.
  boot.initrd.includeDefaultModules = false;
  boot.initrd.kernelModules = lib.mkForce [ ];
  boot.initrd.availableKernelModules = lib.mkForce [
    "mmc_block"
    "sdhci_iproc"
    "uas"
    "usb-storage"
    "xhci-pci"
  ];

  # Keep the HDMI/virtual console out of the normal headless boot path while
  # preserving the serial console as a recovery option.
  console.enable = lib.mkDefault false;
}
