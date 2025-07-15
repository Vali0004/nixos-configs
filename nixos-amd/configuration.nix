{ config, lib, modulesPath, pkgs, ... }:

let
  flameshot_fuckk_lol = pkgs.writeScriptBin "flameshot_fuckk_lol" ''
    ${pkgs.flameshot}/bin/flameshot gui --accept-on-select -r > /tmp/screenshot.png
    ${pkgs.curl}/bin/curl -H "authorization: MTc0NTgwNjM3OTI1NA==.NTc3N2U3Yzc0NDBhMWExY2JhYWMyZWUwZGY2ZjEzOWIuM2I2MmQ0OTgwMzA0ZTIyNTFhYzZmNTcwN2ZhM2FjZjhjYzcyODgyYjIzZTIyZTEyOWZkN2VmNWMwMmViN2FlNTkxMjc3MzQ3MWQ2YjgyMWVhYzM0OGJiZTE2MTQyMDM4Mjg4Zjk5MGFkYzBjZDNmYWI3ODM1MjM2Y2MzYTU3OGE3ODZkYzExYTA3OTU2OWYzNGRlMGM0ZWJhNTZmYzEwZQ==" https://holy.fuckk.lol/api/upload -F file=@/tmp/screenshot.png -H 'content-type: multipart/form-data' | ${pkgs.jq}/bin/jq -r .files[0].url | tr -d '\n' | ${pkgs.xclip}/bin/xclip -selection clipboard
  '';
  fastfetch_simple = pkgs.writeScriptBin "fastfetch_simple" ''
    ${pkgs.fastfetch}/bin/fastfetch --config /home/vali/.config/fastfetch/simple.jsonc
  '';
in {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    boot/boot.nix
    home-manager/home.nix
    pkgs/adafruit-nrfutil.nix
    pkgs/cider.nix
    pkgs/nordic.nix
    programs/spicetify.nix
    programs/ssh.nix
    programs/steam.nix
    programs/zsh.nix
    services/windowManager/i3.nix
    services/bluetooth.nix
    services/displayManager.nix
    services/easyEffects.nix
    services/monado.nix
    services/picom.nix
    services/pipewire.nix
    services/toxvpn.nix
    services/virtualisation.nix
  ];

  console = {
    # Just point it to X11
    useXkbConfig = true;
  };

  environment.shellAliases = {
    l = null;
    ll = null;
    lss = "ls --color -lha";
  };

  environment.systemPackages = with pkgs; [
    alacritty-graphics
    alsa-utils
    bridge-utils
    btop
    busybox
    cachix
    colmena
    curl
    # Clipboard Manager
    clipmenu
    # macOS Translation Layer
    (pkgs.callPackage ./pkgs/darling.nix {})
    dos2unix
    direnv
    (discord.override { withVencord = true; })
    dmidecode
    dunst
    edid-decode
    envsubst
    eog
    # Noise suppression
    easyeffects
    evtest
    # Flexing
    fastfetch
    fastfetch_simple
    # Screenshot tool
    flameshot
    # Screenshot tool with my uploader secret
    flameshot_fuckk_lol
    feh
    fzf
    gdb
    git
    glib
    gnused
    # Browser
    google-chrome
    iperf
    # Media Player
    jellyfin-media-player
    jq
    # MS Paint
    kdePackages.kolourpaint
    # File browser
    kdePackages.ark
    # cli unrar
    libarchive
    # Wormhole
    magic-wormhole
    # COM Reader
    minicom
    # 360-deploy
    morph
    # Video Player
    mpv
    nodejs_24
    obs-studio
    openssl
    # Tablet Driver
    opentabletdriver
    p7zip-rar
    # Different audio control
    pamixer
    # Audio control
    pavucontrol
    pciutils
    # Compositer
    picom
    playerctl
    # Minecraft launcher
    prismlauncher
    protontricks
    # Audio server
    pulseaudio
    qemu_kvm
    # dmenu replacement
    rofi
    socat
    # Spotify mods
    spicetify-cli
    steamcmd
    syncplay
    sysstat
    tmux
    tree
    unzip
    usbutils
    vesktop
    vim
    virt-viewer
    # VRChat Friendship Management
    vrcx
    # Editor
    vscode
    vscode-extensions.mkhl.direnv
    vscode-extensions.bbenoist.nix
    vscode-extensions.jnoortheen.nix-ide
    vscode-extensions.mshr-h.veriloghdl
    vulkan-extension-layer
    vulkan-tools
    vulkan-validation-layers
    wget
    wireshark
    wineWowPackages.stable
    winetricks
    (writeShellScriptBin "qemu-system-x86_64-uefi" ''
      qemu-system-x86_64 \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        "$@"
    '')
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-launch
    xdg-utils
    zenity
    zip
  ];

  environment.variables.CM_LAUNCHER = "rofi";
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
#    "/mnt/c" = {
#      device = "/dev/disk/by-uuid/5A40382940380E6F";
#      fsType = "ntfs";
#    };
    # Mount D:\
#    "/mnt/d" = {
#      device = "/dev/disk/by-uuid/F696F03D96F00043";
#      fsType = "ntfs";
#      options = [ "x-systemd.automount" ];
#    };
    # Mount X:\
    "/mnt/x" = {
      device = "/dev/disk/by-uuid/06BEE3E0BEE3C671";
      fsType = "ntfs";
      options = [ "x-systemd.automount" ];
    };
    # Mount the NFS
    "/mnt/data" = {
      device = "10.0.0.244:/data";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "soft" ];
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
  ];

  # Set hardware to support 32-bit graphics for Wine and Proton
  hardware = {
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  networking = {
    hostName = "nixos-amd";
    useDHCP = true;
    wireless.enable = true;
  };

  # Setup NixOS exprimental features and unfree options for Chrome
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://cache.saumon.network/proxmox-nixos"
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "root"
      "vali"
      "@wheel"
    ];
    trusted-public-keys = [
      "proxmox-nixos:D9RYSWpQQC/msZUWphOY2I5RLH5Dd6yQcaHIuug7dWM="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    java.enable = true;
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  security = {
    rtkit.enable = true;
    sudo.enable = true;
  };

  services = {
    cloudflare-warp.enable = true;
    udev.extraRules = ''
      # Keyboard
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="wheel"
      # HTC
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bb4", GROUP="wheel"
      # Steam
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="28de", GROUP="wheel"
      # RedOctane
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1430", GROUP="wheel"
      # Set /dev/bus/usb/*/* as read-write for the wheel group (0666) for Nordic Semiconductor devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", MODE="0666"
      # Flag USB CDC ACM devices, handled below
      # Set USB CDC ACM devnodes as read-write for the wheel group
      KERNEL=="ttyACM[0-9]*", SUBSYSTEM=="tty", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1915", MODE="0666", ENV{NRF_CDC_ACM}="1"
      ENV{NRF_CDC_ACM}=="1", ENV{ID_MM_CANDIDATE}="0", ENV{ID_MM_DEVICE_IGNORE}="1"
    '';
    xserver = {
      enable = true;
      # Disable XTerm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
      # Set our X11 Keyboard layout
      xkb.layout = "us";
    };
  };

  # 8GiB Swap
  swapDevices = [{
    device = "/var/lib/swap1";
    size = 8192;
  }];

  system = {
    copySystemConfiguration = true;
    stateVersion = "25.11";
  };

  systemd.watchdog.rebootTime = "0";

  time.timeZone = "America/Detroit";

  users = {
    defaultUserShell = pkgs.zsh;
    users.vali = {
      isNormalUser = true;
      extraGroups = [
        "corectrl"
        "qemu-libvirtd"
        "render"
        "tty"
        "wheel"
        "video"
      ];
      useDefaultShell = false;
      shell = pkgs.zsh;
    };
  };

  xdg.portal = {
    enable = true;
    # xdg-desktop-portal 1.17 reworked how portal implementations are loaded, you
    # should either set `xdg.portal.config` or `xdg.portal.configPackages`
    # to specify which portal backend to use for the requested interface.

    # https:#github.com/flatpak/xdg-desktop-portal/blob/1.18.1/doc/portals.conf.rst.in
    config.common.default = "*"; # Just go back to the behaviour before 1.17
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
