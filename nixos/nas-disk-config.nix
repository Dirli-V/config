{
  disk = {
    sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            start = "0";
            end = "1M";
            part-type = "primary";
            flags = ["bios_grub"];
          }
          {
            name = "ESP";
            start = "1MiB";
            end = "100MiB";
            bootable = true;
            content = {
              type = "mdraid";
              name = "boot";
            };
          }
          {
            name = "swap";
            start = "100MiB";
            end = "100%";
            part-type = "primary";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          }
        ];
      };
    };
    sdb = {
      type = "disk";
      device = "/dev/sdb";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "mdadm";
            start = "0";
            end = "100%";
            content = {
              type = "mdraid";
              name = "raid1";
            };
          }
        ];
      };
    };
    sdc = {
      type = "disk";
      device = "/dev/sdc";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "mdadm";
            start = "0";
            end = "100%";
            content = {
              type = "mdraid";
              name = "raid1";
            };
          }
        ];
      };
    };
  };
  mdadm = {
    boot = {
      type = "mdadm";
      level = 1;
      metadata = "1.0";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
      };
    };
    raid1 = {
      type = "mdadm";
      level = 1;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "primary";
            start = "0";
            end = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          }
        ];
      };
    };
  };
}
