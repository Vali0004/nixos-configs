{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [
    # Enable high-poll rate
    "usbhid.kbpoll=1"
    "boot.shell_on_fail"
    "splash"
    "rd.systemd.show_status=auto"
  ];
}
