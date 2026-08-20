{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            BOOT = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luksSwap = {
              size = "100G";
              content = {
                type = "luks";
                name = "luksSwap";
                settings = {
                  allowDiscards = true;
                  bypassWorkqueues = true;
                };
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        options.ashift = "12";
        rootFsOptions = {
          mountpoint = "none";
          canmount = "off";

          compression = "zstd";

          # xattr=sa is faster than the default dir-based xattrs
          acltype = "posixacl";
          xattr = "sa";

          atime = "off";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
          };
          home = {
            type = "zfs_fs";
            mountpoint = "/home";
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              # bigger blocks for the store's large immutable files
              recordsize = "1M";
            };
          };
        };
      };
    };
  };
}
