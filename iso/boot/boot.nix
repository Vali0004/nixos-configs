{ config, lib, pkgs, ... }:

{
  imports = [
    ./kernel.nix
    ./zfs.nix
  ];

  boot.consoleLogLevel = 0;

  boot.initrd = {
    systemd.enable = true;
    verbose = true;
  };

  boot.tmp.useTmpfs = false;
}
