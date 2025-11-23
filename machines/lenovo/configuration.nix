{ inputs
, modulesPath
, lib
, pkgs
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    ../../modules/services/openssh.nix
    boot/boot.nix
    home-manager/home.nix
    programs/agenix.nix
    programs/dconf.nix
    programs/gnupg.nix
    programs/ssh.nix
    services/windowManager/lxqt-hypr.nix
    #services/windowManager/lxqt-sway.nix
    services/displayManager.nix
    services/prometheus.nix
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
      device = "10.0.0.229:/data";
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
    enableKvm = true;
    wifi.enable = true;
  };

  networking = {
    dhcpcd = {
      # TP-Link is stupid...
      #
      # eth0: adding route to fdb5:8d30:9e81:1::/64 via fe80::1691:38ff:fed0:2729
      # eth0: dhcp_envoption 24.0/3: malformed embedded option
      # eth0: deleting route to fdb5:8d30:9e81:1::/64 via fe80::1691:38ff:fed0:2729
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
    nameservers = [
      "10.0.0.229"
      "75.75.75.75"
      "2601:406:8100:91d8:9504:1cf3:185b:1fa4"
      "2001:558:FEED::1"
    ];
    hostId = "2632ac4c";
    hostName = "lenovo";
    interfaces.wlan0.useDHCP = true;
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true;
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

  security = {
    # Fucking realtime priority
    rtkit.enable = lib.mkForce false;
    sudo.enable = true;
  };

  services = {
    flatpak.enable = true;
    # Linux GPU Configuration And Monitoring Tool
    lact.enable = true;
    udev.extraRules = ''
      # Aula, SayoDevice O3C
      SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="plugdev", MODE="0666"
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
    # upower daemon
    upower.enable = true;
    xserver = {
      enable = false;
      # Disable XTerm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
  };

  users = let
    my_keys = import ../../ssh_keys_personal.nix;
  in {
    defaultUserShell = pkgs.zsh;
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
      enable = true;
      openFirewall = true;
    };
    enable = true;
    autoSnapshot.enable = true;
  };
}