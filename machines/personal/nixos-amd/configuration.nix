{ config
, inputs
, lib
, modulesPath
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
    programs/nix-index.nix
    programs/ssh.nix

    services/windowManager/dwm.nix
    services/displayManager.nix

    #services/dnsmasq.nix
    services/krb5.nix
    #services/monado.nix
    services/openssh.nix
    services/picom.nix
    services/ratbagd.nix
    services/syslog.nix
    services/toxvpn.nix
    services/udev.nix

    virtualisation/docker.nix

    ./pkgs.nix
  ];

  fileSystems = let
    ntfs_options = [
      "rw"
      "uid=1000"
      "gid=100"
      "umask=0022"
      "fmask=0133"
      "dmask=0022"
      "windows_names"
    ];
  in {
    # Mount the Root Partition
    "/" = {
      fsType = "ext4";
      label = "NIXOS_ROOT";
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
    # Mount the Windows C:\ drive
    "/mnt/c" = {
      device = "/dev/disk/by-uuid/BE68F85A68F812BF";
      fsType = "ntfs";
      options = ntfs_options;
    };
    # Mount D:\
    "/mnt/d" = {
      device = "/dev/disk/by-uuid/06BEE3E0BEE3C671";
      fsType = "ntfs";
      options = ntfs_options ++ [
        "noauto"
        "x-systemd.automount"
      ];
    };
    # Mount #:\
    "/mnt/e" = {
      label = "WIN_NIX";
      fsType = "ntfs";
      options = ntfs_options;
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
      rocmSupport = true;
    };
    audio.pipewire.enable = true;
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
    opencl.enable = true;
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
    openrazer.enable = true;
    enableKvm = true;
    wifi.enable = true;
    virtualisation.enable = false;
  };

  networking = {
    hostName = "nixos-amd";
    interfaces = {
      #wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
    useDHCP = false;
    usePredictableInterfaceNames = true;
  };

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true && config.programs.nix-index.enable == false;
    dconf.enable = true;
    element-desktop.enable = true;
    easyeffects.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    google-chrome.enable = true;
    java.enable = true;
    kde-ark.enable = true;
    nemo.enable = true;
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        # Background modifiers
        obs-backgroundremoval
        obs-composite-blur
        # PipeWire Audio Capture
        obs-pipewire-audio-capture
        # AMD accel
        obs-vaapi
        obs-gstreamer
        # Vulkan capture
        obs-vkcapture
      ];
    };
    spicetify.enable = true;
    steam = {
      enable = true;
      enableGamescope = true;
      enableVramMgmt = true;
    };
    unityhub.enable = true;
    vscode.enable = true;
    wireshark = {
      dumpcap.enable = true;
      enable = true;
      package = pkgs.wireshark;
      usbmon.enable = true;
    };
    zsh.enable = true;
  };

  qt.enable = true;

  security = {
    rtkit.enable = true;
    sudo.enable = true;
  };

  services = {
    flatpak.enable = true;
    # Linux GPU Configuration And Monitoring Tool
    lact.enable = true;
    udisks2.enable = true;
  };

  systemd.services.dhcpcd = {
    after = [
      "wpa_supplicant.service"
      "sys-subsystem-net-devices-wlan0.device"
    ];
    wants = [
      "wpa_supplicant.service"
      "sys-subsystem-net-devices-wlan0.device"
    ];
    serviceConfig = {
      TimeoutStopSec = "5s";
      KillMode = "mixed";
      SendSIGKILL = true;
    };
  };

  systemd.network.links = {
    "10-eth0" = {
      matchConfig.MACAddress = "10:ff:e0:35:08:fb";
      linkConfig.Name = "eth0";
    };
    "10-wlan0" = {
      matchConfig.MACAddress = "94:bb:43:52:13:b8";
      linkConfig.Name = "wlan0";
    };
    #"10-sfp0" = {
    #  matchConfig.MACAddress = "14:02:ec:7f:3c:4c";
    #  linkConfig.Name = "sfp0";
    #};
    #"10-sfp1" = {
    #  matchConfig.MACAddress = "14:02:ec:7f:3c:4d";
    #  linkConfig.Name = "sfp1";
    #};
  };

  # 8GiB Swap
  swapDevices = [{
    device = "/var/lib/swap1";
    size = 8192;
  }];

  users.users = let
    my_keys = import ../../../ssh_keys_personal.nix;
    common_keys = import ../../../ssh_keys.nix;
  in {
    root = {
      openssh.authorizedKeys.keys = my_keys;
    };
    vali = {
      isNormalUser = true;
      extraGroups = [
        "corectrl"
        "dialout"
        "input"
        "openrazer"
        "qemu-libvirtd"
        "render"
        "tty"
        "video"
        "wheel"
        "wireshark"
        "usbmon"
      ];
      useDefaultShell = false;
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
  };

  xdg.enable = true;
}