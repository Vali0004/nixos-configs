{ config, lib, modulesPath, pkgs, ... }:

let
  secrets = import ./network-secrets.nix { inherit lib; };

  agenix = builtins.getFlake "github:ryantm/agenix";
  agenixPkgs = agenix.outputs.packages.x86_64-linux;
in {
  imports = [
    agenix.nixosModules.default
    "${modulesPath}/installer/scan/not-detected.nix"
    boot/boot.nix
    home-manager/home.nix
    programs/spicetify.nix
    programs/ssh.nix
    programs/steam.nix
    programs/zsh.nix
    services/windowManager/dwm.nix
    services/bluetooth.nix
    services/displayManager.nix
    services/easyEffects.nix
    services/openssh.nix
    services/picom.nix
    services/pipewire.nix
    services/prometheus.nix
    #services/zdb.nix
    ./../modules/audio/module.nix
    ./../modules/certificates/module.nix
    ./../modules/xdg.nix
    ./pkgs.nix
  ];

  console.useXkbConfig = true;

  environment = {
    shellAliases = {
      l = null;
      ll = null;
      lss = "ls --color -lha";
    };

    variables = {
      CM_LAUNCHER = "rofi";
    };
  };

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

  hardware = {
    amdgpu.overdrive.enable = true;
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  };

  networking = {
    extraHosts = ''
      10.0.0.31 lenovo
      10.0.0.124 chromeshit
      10.0.0.201 nixos-amd
      10.0.0.244 shitzen-nixos
      74.208.44.130 router-vps
    '';
    hostId = "2632ac4c";
    hostName = "lenovo";
    useDHCP = true;
    usePredictableInterfaceNames = false;
    wireless = {
      enable = true;
      networks = {
        "${secrets.wifi.ssid}" = {
          psk = secrets.wifi.password;
        };
      };
      userControlled.enable = true;
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://hydra.fuckk.lol"
      "https://cache.nixos.org/"
    ];
    trusted-users = [
      "root"
      "vali"
      "@wheel"
    ];
    trusted-public-keys = [
      "hydra.fuckk.lol:6+mPv9GwAFx/9J+mIL0I41pU8k4HX0KiGi1LUHJf7LY="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";

  programs = {
    corectrl.enable = true;
    command-not-found.enable = true;
    dconf.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
    };
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
    # CPU Power Saving Settings (daemon)
    cpupower-gui.enable = true;
    # Linux GPU Configuration And Monitoring Tool
    lact.enable = true;
    udev.extraRules = ''
      # Keyboard
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="wheel"
      # RedOctane
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1430", GROUP="wheel"
    '';
    # upower daemon
    upower.enable = true;
    xserver = {
      enable = true;
      # Disable XTerm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;
      # Set our X11 Keyboard layout
      xkb.layout = "us";
    };
  };

  system = {
    copySystemConfiguration = true;
    stateVersion = "25.11";
  };

  systemd.settings.Manager.RebootWatchdogSec = "0";

  time.timeZone = "America/Detroit";

  users = let
    my_keys = import ./../ssh_keys_personal.nix;
  in {
    defaultUserShell = pkgs.zsh;
    users.root.openssh.authorizedKeys.keys = my_keys;
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
}
