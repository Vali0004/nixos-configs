{ config, lib, pkgs, ... }:

{
  boot = {
    supportedFilesystems = [ "zfs" ];
    # Do not hang my fucking system, please?
    zfs.forceImportRoot = false;
    zfs.forceImportAll = false;
  };

  environment.systemPackages = [ pkgs.zfs ];

  services.zfs.autoSnapshot.enable = true;

  services.zfs.zed = {
    enableMail = false;
    settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";

      ZED_EMAIL_ADDR = [ "root" ];
      ZED_EMAIL_PROG = "mail";
      ZED_EMAIL_OPTS = "-s '@SUBJECT@' @ADDRESS@";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = false;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = false;
    };
  };
}