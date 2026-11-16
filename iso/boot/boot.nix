{ config, lib, pkgs, ... }:

{
  imports = [
    ./kernel.nix
    ./zfs.nix
  ];

  boot.consoleLogLevel = 0;

  boot.initrd = {
    verbose = true;
  };

  boot.tmp.useTmpfs = false;
}
