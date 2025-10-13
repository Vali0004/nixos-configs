{ config, lib, pkgs, ... }:

{
  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };

  programs.ssh.extraConfig = ''
    include config.d/*

    IdentityFile /home/vali/.ssh/id_rsa
    IdentityFile /home/vali/.ssh/nixos_main
    Host router
      Hostname router-vps
      User root

    Host shitzen-nixos
      Hostname shitzen-nixos
      User root

    Host chromeshit
      Hostname chromeshit
      User root

    Host lenovo
      Hostname lenovo
      User root
  '';
}
