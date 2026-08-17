{ lib, ... }:

{
  boot = {
    loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    initrd.availableKernelModules = [
      "uas"
      "usb-storage"
      "xhci-pci"
    ];
  };

  hardware.raspberry-pi.firmware = {
    enable = true;
    path = "/boot/firmware";
    uboot.enable = false;
  };
  # Avoid the Raspberry Pi module shrinker probing unavailable DRM aliases.
  boot.initrd.includeDefaultModules = false;

  # Keep the HDMI/virtual console out of the normal headless boot path while
  # preserving the serial console as a recovery option.
  console.enable = lib.mkDefault false;
}
