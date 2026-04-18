{ config
, pkgs
, modulesPath
, ... }:

{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"

    modules/boot.nix
    modules/kernel.nix

    programs/dconf.nix

    services/windowManager/dwm.nix
    services/displayManager.nix
    services/picom.nix
  ];

  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty-graphics
    # Better TOP
    btop
    dmidecode
    fastfetch
  ];

  fileSystems = {
    "/" = {
      label = "NIXOS_ROOT";
      fsType = "ext4";
    };
    "/boot" = {
      label = "NIXOS_BOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  fonts.packages = [ pkgs.nerd-fonts.dejavu-sans-mono ];

  gtk.enable = true;

  hardware = {
    intel.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  networking = {
    hostId = "bade5fb2";
    hostName = "compaq-8200-sff-shitbox";
    interfaces = {
      eth0.useDHCP = true;
    };
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
    google-chrome.enable = true;
    java.enable = true;
    kde-ark.enable = true;
    nemo.enable = true;
    steam.enable = true;
    zsh.enable = true;
  };

  qt.enable = true;

  security = {
    rtkit.enable = true;
    sudo.enable = true;
  };

  services = {
    xserver = {
      enable = true;
      # Disable XTerm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
    };
  };

  # 16GiB Swap
  swapDevices = [{
    device = "/var/lib/swap1";
    size = 16384;
  }];

  users.users.vali = {
    isNormalUser = true;
    extraGroups = [
      "corectrl"
      "dialout"
      "input"
      "plugdev"
      "render"
      "tty"
      "video"
      "wheel"
      "usbmon"
    ];
    useDefaultShell = false;
    shell = pkgs.zsh;
    password = "773415";
  };

  xdg.enable = true;

  zfs.enable = false;
}