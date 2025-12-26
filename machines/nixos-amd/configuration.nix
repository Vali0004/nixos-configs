{ config
, inputs
, lib
, modulesPath
, pkgs
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    ../../modules/programs/steam.nix
    boot/boot.nix
    home-manager/home.nix
    programs/agenix.nix
    programs/dconf.nix
    programs/gnupg.nix
    programs/ssh.nix
    services/windowManager/dwm.nix
    services/displayManager.nix
    #services/dnsmasq.nix
    services/krb5.nix
    #services/monado.nix
    services/picom.nix
    services/ratbagd.nix
    services/syslog.nix
    services/toxvpn.nix
    virtualisation/docker.nix
    ./pkgs.nix
  ];

  environment.variables = {
    CM_LAUNCHER = "dmenu";
  };

  fileSystems = {
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
    };
    # Mount D:\
    "/mnt/d" = {
      device = "/dev/disk/by-uuid/06BEE3E0BEE3C671";
      fsType = "ntfs";
      options = [ "x-systemd.automount" ];
    };
    # Mount the NFS
    "/mnt/data" = {
      device = "10.0.0.6:/data";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "soft" ];
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
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
    openrazer.enable = true;
    wifi.enable = true;
    virtualisation.enable = true;
  };

  networking = {
    dhcpcd = {
      #
      # TP-Link is stupid...
      #
      # enp10s0: adding route to fdb5:8d30:9e81:1::/64 via fe80::1691:38ff:fed0:2729
      # enp10s0: dhcp_envoption 24.0/3: malformed embedded option
      # enp10s0: deleting route to fdb5:8d30:9e81:1::/64 via fe80::1691:38ff:fed0:2729
      #
      # Why is my router vomitting malformed DHCPv6 packets,
      # and killing networking?
      # Dumbest thing ever.
      extraConfig = ''
        nohook resolv.conf
        # Stop dhcpcd from ever requesting vendor class or FQDN
        nooption rapid_commit
        nooption vendorclassid
        nooption fqdn
        nooption 24
        nooption 25
      '';
      IPv6rs = true;
    };
    hostName = "nixos-amd";
    interfaces.enp10s0.useDHCP = true;
    nameservers = [
      "10.0.0.10"
      "75.75.75.75"
      "2601:406:8100:91D8:8EEC:4BFF:FE55:B2F1"
      "2001:558:FEED::1"
    ];
    useDHCP = false;
    usePredictableInterfaceNames = true;
  };

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true;
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
    spicetify.enable = true;
    steam.enable = true;
    unityhub.enable = true;
    vscode.enable = true;
    wireshark = {
      dumpcap.enable = true;
      enable = true;
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
    udev.extraRules = ''
      # Aula, SayoDevice O3C
      SUBSYSTEM=="usb", ATTRS{idVendor}=="8089", GROUP="wheel", MODE="0677"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", GROUP="wheel", MODE="0677"
      # Elgato
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", GROUP="wheel", MODE="0677"
      # HTC
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", GROUP="plugdev", MODE="0666"
      # Oculus
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2833", GROUP="plugdev", MODE="0666"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2833", GROUP="plugdev", MODE="0666"
      # SlimeVR
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", GROUP="plugdev", MODE="0666"
      # Sony - 054c:0fa8
      SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", GROUP="plugdev", MODE="0666"
      # Steam
      SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", GROUP="plugdev", MODE="0666"
      # Razer
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1532", GROUP="plugdev", MODE="0666"
      # RedOctane
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1430", TAG+="uaccess", MODE="0666", GROUP="plugdev"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1430", TAG+="uaccess", MODE="0666", GROUP="plugdev"
      # Espressif
      SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", GROUP="plugdev", MODE="0666"
      # RockChip
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2207", GROUP="plugdev", MODE="0666"
      # Set /dev/bus/usb/*/* as read-write for the plugdev group (0666) for Nordic Semiconductor devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", MODE="0666"
      # Set /dev/bus/usb/*/* as read-write for the plugdev group (0666) for WCH-CN devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1d6b", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", MODE="0666"
      # USB CDC ACM for Nordic + Espressif
      KERNEL=="ttyACM[0-9]*", SUBSYSTEM=="usb", ATTRS{idVendor}=="1915|303a", MODE="0666", ENV{CDC_ACM}="1"
      KERNEL=="ttyACM[0-9]*", SUBSYSTEM=="tty", ATTRS{idVendor}=="1915|303a", MODE="0666", ENV{CDC_ACM}="1"
      ENV{CDC_ACM}=="1", ENV{ID_MM_CANDIDATE}="0", ENV{ID_MM_DEVICE_IGNORE}="1"
    '';
    udisks2.enable = true;
    xserver = {
      enable = true;
      # Disable XTerm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
  };

  # 8GiB Swap
  swapDevices = [{
    device = "/var/lib/swap1";
    size = 8192;
  }];

  systemd.settings.Manager.RebootWatchdogSec = "0";

  users.users.vali = {
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
    useDefaultShell = false;
    shell = pkgs.zsh;
  };

  xdg.enable = true;
}