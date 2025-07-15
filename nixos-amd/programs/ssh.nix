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

    Host *
      ControlPath ~/.ssh/master-%r@%h:%p
      ControlMaster auto

    IdentityFile /home/vali/.ssh/id_rsa
    IdentityFile /home/vali/.ssh/nixos_main
    Host router
      Hostname 74.208.44.130
      User root

    Host shitzen-nixos
      Hostname 10.0.0.244
      User root

    Host chromeshit
      Hostname 10.0.0.124
      User root

    Host r2d2box
      Hostname 10.0.0.204
      User root
  '';
}
