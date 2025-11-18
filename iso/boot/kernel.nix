{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [
    "boot.shell_on_fail"
    "splash"
    "rd.systemd.show_status=auto"
  ];
}
