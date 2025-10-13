{ config, lib, pkgs, ... }:

{
  options.zfs = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable ZFS support or not.";
    };
    autoSnapshot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable ZFS's auto snapshot service.";
      };
    };
    zed = {
      enableMail = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable ZED's (ZFS Event Deamon) mail service.";
      };
      logPath = lib.mkOption {
        type = lib.types.str;
        default = "/tmp/zed.debug.log";
        description = "ZED's debug log path.";
      };
      notifyInterval = lib.mkOption {
        type = lib.types.int;
        default = 3600;
        description = "ZED's debug log path.";
      };
    };
  };

  config = lib.mkIf config.zfs.enable {
    environment.systemPackages = [ pkgs.zfs ];

    boot = {
      kernelPackages = pkgs.linuxKernel.packages.linux_6_16.extend (self: super: {
        zfs_2_3 = super.zfs_2_3.overrideAttrs (old: {
          src = pkgs.fetchurl {
            url = "https://github.com/openzfs/zfs/archive/pull/14013/head.tar.gz";
            hash = "sha256-X4PO6uf/ppEedR6ZAoWmrDRfHXxv2LuBThekRZOwmoA=";
          };
          patches = [];
        });
      });
      supportedFilesystems = [ "zfs" ];
      zfs = {
        devNodes = "/dev/disk/by-partuuid";
        # In the event of a failure, this can save a lot of headache,
        # but it can also cause services to silently fail
        forceImportRoot = false;
        forceImportAll = false;
      };
    };

    services.zfs.autoSnapshot.enable = config.zfs.autoSnapshot.enable;

    services.zfs.zed = {
      enableMail = false;
      settings = {
        ZED_DEBUG_LOG = config.zfs.zed.logPath;

        ZED_EMAIL_ADDR = [ "root" ];
        ZED_EMAIL_PROG = "mail";
        ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";

        ZED_NOTIFY_INTERVAL_SECS = config.zfs.zed.notifyInterval;
        ZED_NOTIFY_VERBOSE = false;

        ZED_USE_ENCLOSURE_LEDS = true;
        ZED_SCRUB_AFTER_RESILVER = false;
      };
    };
  };
}