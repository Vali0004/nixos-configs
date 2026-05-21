# Configuration for rescueBoot,
# a LiveCD stored in a initramfs used to rescue a NixOS install
# after it is considered "unrescuable" from its graphical interface

{ config
, lib
, pkgs
, ... }:

{
  documentation = {
    enable = false;
    doc.enable = false;
    info.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  environment = {
    defaultPackages = [ ];
    # Prevent installation media from evacuating persistent storage, as their
    # var directory is not persistent and it would thus result in deletion of
    # those entries.
    etc."systemd/pstore.conf".text = ''
      [PStore]
      Unlink=no
    '';
    stub-ld.enable = false;
    systemPackages = with pkgs; [
      ddrescue
      e2fsprogs
      efibootmgr
      efivar
      gptfdisk
      hdparm
      ms-sys
      nano
      nvme-cli
      parted
      pciutils
      sdparm
      smartmontools
      socat
      tcpdump
      testdisk
      usbutils
    ];
    # Tell the Nix evaluator to garbage collect more aggressively.
    # This is desirable in memory-constrained environments that don't
    # (yet) have swap set up.
    variables.GC_INITIAL_HEAP_SIZE = "1M";
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
  };

  networking = {
    firewall.logRefusedConnections = false;
    hostId = "8425e349";
    hostName = "nixos-rescue-cd";
    wireless = {
      enable = lib.mkDefault true;
      userControlled = true;
    };
  };

  # Allow 'nixos' to nix-copy to live system
  nix.settings.trusted-users = [ "nixos" ];

  programs = {
    command-not-found.enable = false;
    git.enable = false;
    less.lessopen = null;
  };

  security = {
    polkit.enable = lib.mkForce false;
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };

  services = {
    getty = {
      autologinUser = "nixos";
      helpLine = ''
        The "nixos" and "root" accounts have empty passwords.

        To log in over ssh you must set a password for either "nixos" or "root"
        with `passwd` (prefix with `sudo` for "root"), or add your public key to
        /home/nixos/.ssh/authorized_keys or /root/.ssh/authorized_keys.

        Wireless is available in this rescue image if firmware and hardware support it.
      '';
    };
    logrotate.enable = false;
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
    udisks2.enable = false;
  };

  system.stateVersion = "26.05";

  users.users = {
    nixos = {
      extraGroups = [ "tty" "wheel" ];
      initialHashedPassword = "";
      isNormalUser = true;
    };
    root.initialHashedPassword = "";
  };

  xdg = {
    autostart.enable = false;
    icons.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
}
