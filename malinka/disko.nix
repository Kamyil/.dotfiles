{ ... }:

{
  disko.devices.disk.system = {
    type = "disk";

    # Samsung SSD 870 QVO 1TB, serial S5SVNG0N836194B. Reconfirm that this
    # identifier resolves to that exact drive on Malinka before running Disko.
    device = "/dev/disk/by-id/wwn-0x5002538f7080fb02";

    content = {
      type = "gpt";
      partitions = {
        firmware = {
          priority = 1;
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot/firmware";
            mountOptions = [
              "fmask=0077"
              "dmask=0077"
            ];
          };
        };

        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            mountOptions = [ "noatime" ];
          };
        };
      };
    };
  };
}
