{
  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };

  programs.ssh.extraConfig = ''
    include config.d/*

    IdentityFile /home/vali/.ssh/nixos_main
    IdentityFile /home/vali/.ssh/test_ppk

    Host 10.0.0.*
      IPQoS none
      Ciphers aes128-gcm@openssh.com
      KexAlgorithms curve25519-sha256
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m

    Host router
      Hostname router-vps
      User root
      IPQoS none
      Ciphers aes128-gcm@openssh.com
      KexAlgorithms curve25519-sha256
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m

    Host shitzen-nixos
      Hostname shitzen-nixos
      User root
      IPQoS none
      Ciphers aes128-gcm@openssh.com
      KexAlgorithms curve25519-sha256
      Compression no
      TCPKeepAlive yes
      ControlMaster auto
      ControlPath ~/.ssh/control-%r@%h:%p
      ControlPersist 10m

    Host chromeshit
      Hostname chromeshit
      User root

    Host lenovo
      Hostname lenovo
      User root
  '';
}