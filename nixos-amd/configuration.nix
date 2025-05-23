{ config, lib, modulesPath, pkgs, ... }:

let
  # i3 config extras
  flameshot_fuckk_lol = pkgs.writeScriptBin "flameshot_fuckk_lol" ''
    ${pkgs.flameshot}/bin/flameshot gui --accept-on-select -r > /tmp/screenshot.png
    ${pkgs.curl}/bin/curl -H "authorization: MTc0NTgwNjM3OTI1NA==.NTc3N2U3Yzc0NDBhMWExY2JhYWMyZWUwZGY2ZjEzOWIuM2I2MmQ0OTgwMzA0ZTIyNTFhYzZmNTcwN2ZhM2FjZjhjYzcyODgyYjIzZTIyZTEyOWZkN2VmNWMwMmViN2FlNTkxMjc3MzQ3MWQ2YjgyMWVhYzM0OGJiZTE2MTQyMDM4Mjg4Zjk5MGFkYzBjZDNmYWI3ODM1MjM2Y2MzYTU3OGE3ODZkYzExYTA3OTU2OWYzNGRlMGM0ZWJhNTZmYzEwZQ==" https://holy.fuckk.lol/api/upload -F file=@/tmp/screenshot.png -H 'content-type: multipart/form-data' | ${pkgs.jq}/bin/jq -r .files[0].url | tr -d '\n' | ${pkgs.xclip}/bin/xclip -selection clipboard
  '';
in {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    boot/boot.nix
    home-manager/home.nix
    programs/spicetify.nix
    programs/zsh.nix
    services/displayManager.nix
    services/easyEffects.nix
    services/picom.nix
    services/pipewire.nix
    services/toxvpn.nix
    services/virtualisation.nix
    services/windowManager.nix
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
    alacritty
    alsa-utils
    alvr
    bridge-utils
    btop
    busybox
    cachix
    colmena
    curl
    clipmenu # Clipboard Manager
    dos2unix
    direnv
    (discord.override { withVencord = true; })
    dmidecode
    dunst
    edid-decode
    envsubst
    eog
    easyeffects # Noise suppression
    evtest
    fastfetch # Flexing
    flameshot # Screenshot tool
    flameshot_fuckk_lol # Screenshot tool with my uploader secret
    feh # Wallpaper
    fzf
    git
    glib
    gnome-software
    google-chrome # Browser
    iperf
    jq
    mpv # Video Player
    nemo-with-extensions # File browser
    nodejs_24
    obs-studio
    openssl
    opentabletdriver # Tablet Driver
    p7zip-rar # WinRAR
    pamixer # Different audio control
    pavucontrol # Audio control
    pciutils
    picom # Compositer
    playerctl
    plex-desktop
    pulseaudio # Audio server
    rofi # Dmenu replacement
    socat
    spicetify-cli # Spotify mods
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
    xclip
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-launch
    xdg-utils
    xorg.libxcvt
    zenity
    zip
  ];

  environment.variables.CM_LAUNCHER = "rofi";

  fileSystems = {
    # Mount the Root Partition
    "/" = {
      device = "/dev/disk/by-uuid/7608c91c-3416-4261-8b87-1c905f0074d2";
      fsType = "ext4";
    };
    # Mount the EFI Partition
    "/boot" = {
      device = "/dev/disk/by-uuid/F80D-25F5";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
    # Mount the Windows C:\ drive
    "/mnt/c" = {
      device = "/dev/disk/by-uuid/5A40382940380E6F";
      fsType = "ntfs";
    };
    # Mount D:\
    "/mnt/d" = {
      device = "/dev/disk/by-uuid/F696F03D96F00043";
      fsType = "ntfs";
    };
    # Mount X:\
    "/mnt/x" = {
      device = "/dev/disk/by-uuid/06BEE3E0BEE3C671";
      fsType = "ntfs";
    };
    # Mount the NFS
    "/data" = {
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

  i18n.defaultLocale = "en_US.UTF-8";

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
    trusted-users = [
      "root"
      "vali"
      "@wheel"
    ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  programs = {
    alvr = {
      enable = true;
      openFirewall = true;
    };
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

  security.sudo.enable = true;

  services = {
    udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="wheel"
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
