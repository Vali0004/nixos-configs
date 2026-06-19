{ inputs
, modulesPath
, lib
, pkgs
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    boot/boot.nix
    home-manager/home.nix
    programs/agenix.nix
    programs/dconf.nix
    programs/gnupg.nix
    programs/ssh.nix
    #services/windowManager/lxqt-hypr.nix
    #services/windowManager/lxqt-sway.nix
    services/windowManager/dwm.nix
    services/displayManager.nix
    services/picom.nix
    services/prometheus.nix
    services/udev.nix
    #services/wireguard.nix
    ./pkgs.nix
  ];

  console.keyMap = "us";

  fileSystems = {
    # Mount the Root Partition
    "/" = {
      device = "zpool/root";
      fsType = "zfs";
    };
    "/home" = {
      device = "zpool/home";
      fsType = "zfs";
    };
    "/nix" = {
      device = "zpool/nix";
      fsType = "zfs";
    };
    # Mount the EFI Partition
    "/boot" = {
      fsType = "vfat";
      label = "NIXOS_BOOT";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    # Mount the NFS
    "/mnt/data" = {
      device = "10.0.0.4:/data";
      fsType = "nfs";
      options = [
        "_netdev"
        "noauto"
        "nofail"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "x-systemd.mount-timeout=5s"
        "x-systemd.device-timeout=5s"

        "hard"
        "timeo=50"
        "retrans=2"
      ];
    };
  };

  fonts.packages = [ pkgs.nerd-fonts.dejavu-sans-mono ];

  gtk.enable = true;

  hardware = {
    amd = {
      enable = true;
      enableIommu = true;
    };
    amdgpu = {
      enable = true;
      allowOverclocking = true;
    };
    audio.pipewire.enable = true;
    bluetooth.enable = true;
    enableKvm = true;
    wifi.enable = true;
  };

  networking = {
    dhcpcd = {
      IPv6rs = true;
    };
    hostId = "2632ac4c";
    hostName = "lenovo";
    useDHCP = true;
    usePredictableInterfaceNames = false;
  };

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true && config.programs.nix-index.enable == false;
    dconf.enable = true;
    easyeffects.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    google-chrome.enable = true;
    nemo.enable = true;
    spicetify.enable = true;
    steam.enable = true;
    vscode.enable = true;
    zsh.enable = true;
  };

  qt.enable = true;

  security.sudo.enable = true;

  services = {
    flatpak.enable = true;
    # Linux GPU Configuration And Monitoring Tool
    lact.enable = true;
    # upower daemon
    upower.enable = true;
  };

  users = let
    my_keys = import ../../../ssh_keys_personal.nix;
  in {
    defaultUserShell = pkgs.zsh;
    groups.plugdev = {};
    users.root = {
      openssh.authorizedKeys.keys = my_keys;
      useDefaultShell = false;
      shell = pkgs.zsh;
    };
    users.vali = {
      isNormalUser = true;
      extraGroups = [
        "corectrl"
        "dialout"
        "input"
        "openrazer"
        "plugdev"
        "qemu-libvirtd"
        "render"
        "tty"
        "video"
        "wheel"
        "wireshark"
        "usbmon"
      ];
      openssh.authorizedKeys.keys = my_keys;
      shell = pkgs.zsh;
      useDefaultShell = false;
    };
  };

  xdg.enable = true;

  zfs = {
    fragmentation = {
      enable = false;
      openFirewall = true;
    };
    enable = true;
    autoSnapshot.enable = true;
  };
}