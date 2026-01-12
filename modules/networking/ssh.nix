{ config, ... }:

{
  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };

  programs.ssh.extraConfig = ''
    Host 10.0.0.*
      IPQoS none
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m

    Host chromeshit
      Hostname chromeshit
      User root

    Host nixos-hass
      Hostname nixos-hass
      User root
      IPQoS none
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m

    Host nixos-router
      Hostname nixos-router
      User root
      IPQoS none
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m

    Host nixos-shitclient
      Hostname nixos-shitclient
      User root
      IPQoS none
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m

    Host shitzen-nixos
      Hostname shitzen-nixos
      User root
      IPQoS none
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m

    Host router-vps
      Hostname router-vps
      User root
      IPQoS none
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m

    Host lenovo
      Hostname lenovo
      User root
      IPQoS none
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m
  '';
}