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

    Host PRV-Germany-01
      Hostname PRV-Germany-01
      User root
      Port 5192

    Host AU-Syndey-01-OVH-WG
      Hostname AU-Syndey-01-OVH-WG
      User root
      Port 1731

    Host BHS-02-OVH-WG
      Hostname BHS-02-OVH-WG
      User root
      Port 9289

    Host LZ-AMS-02-OVH-WG
      Hostname LZ-AMS-02-OVH-WG
      User root
      Port 6934

    Host RBX-01-OVH-WG
      Hostname RBX-01-OVH-WG
      User root
      Port 5296

    Host UK-London-02-OVH-WG
      Hostname UK-London-02-OVH-WG
      User root
      Port 3952
  '';
}
