{ config, lib, modulesPath, pkgs, ... }:

let
  skylandersFlake = builtins.getFlake "home/vali/skylanders-nfc-reader";
in {
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
    ../../modules/services/openssh.nix
    boot/boot.nix
    home-manager/home.nix
    programs/ssh.nix
    #services/windowManager/lxqt-hypr.nix
    services/windowManager/lxqt-sway.nix
    services/displayManager.nix
    services/prometheus.nix
    ./pkgs.nix
  ];

  nixpkgs.overlays = [
    (self: super: {
      skylanders = skylandersFlake.outputs.packages.x86_64-linux.skylanders;
    })
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
      device = "10.0.0.244:/data";
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
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  networking = {
    hostId = "2632ac4c";
    hostName = "lenovo";
    useDHCP = true;
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
    nemo.enable = true;
    spicetify.enable = true;
    steam.enable = true;
    vscode.enable = true;
  };

  qt.enable = true;

  security = {
    rtkit.enable = true;
    sudo.enable = true;
  };

  services = {
    udev.extraRules = ''
      # Keyboard
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="wheel"
      # RedOctane
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1430", GROUP="wheel"
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

  system.stateVersion = "25.05";

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
        "input"
        "render"
        "tty"
        "wheel"
        "video"
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
