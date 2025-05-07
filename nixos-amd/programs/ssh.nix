{ config, lib, pkgs, ... }:

{
  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };

  programs.ssh.extraConfig = ''
    IdentityFile /home/vali/.ssh/id_rsa
    IdentityFile /home/vali/.ssh/nixos_main
    Host router
      Hostname 31.59.128.8

    Host shitzen-nixos
      Hostname 10.0.0.244

    Host chromeshit
      Hostname 10.0.0.124

    Host r2d2box
      Hostname 10.0.0.204
  '';
}
