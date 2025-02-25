# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ config, lib, modulesPath, pkgs, ... }:

let 
  spice = builtins.getFlake "github:Gerg-L/spicetify-nix";
  spicePkgs = spice.outputs.legacyPackages.x86_64-linux;
#  rescueBoot = import (pkgs.path + "/nixos/lib/eval-config.nix") {
#    modules = [
#      (pkgs.path + "/nixos/modules/installer/scan/detected.nix")
#      (pkgs.path + "/nixos/modules/installer/scan/not-detected.nix")
#      (pkgs.path + "/nixos/modules/profiles/clone-config.nix")
#      module
#    ];
#  };
#  module = {
#    imports = [
#      /etc/nixos/rescue-configuration.nix
#    ];
#    boot = {
#      initrd = {
#        availableKernelModules = [ "squashfs" "overlay" "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
#        kernelModules = [ "loop" "overlay" ];
#        systemd.enable = true;
#      };
#      kernelParams = [
#        "boot.shell_on_fail"
#      ];
#      kernel.sysctl."vm.overcommit_memory" = "1";
#      enableContainers = false;
#      # Don't enable grub, we don't need it anyways and it causes a cyclic dep
#      loader.grub.enable = false;
#      loader.timeout = 10;
#      postBootCommands = ''
#        # After booting, register the contents of the Nix store
#        # in the Nix database in the tmpfs.
#        ${config.nix.package}/bin/nix-store --load-db < /nix/store/nix-path-registration
#
#        # nixos-rebuild also requires a "system" profile and an
#        # /etc/NIXOS tag.
#        touch /etc/NIXOS
#        ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
#      '';
#      supportedFilesystems = [ "btrfs" "cifs" "f2fs" "ntfs" "vfat" "xfs" ];
#      swraid = {
#        enable = true;
#        mdadmConf = "PROGRAM ${pkgs.coreutils}/bin/true";
#      };
#    };
#
#    fileSystems = {
#      "/" = {
#        fsType = "tmpfs";
#        options = [ "mode=0755" ];
#      };
#      "/nix/.ro-store" = {
#        fsType = "squashfs";
#        device = "../nix-store.squashfs";
#        options = [ "loop" "threads=multi" ];
#        neededForBoot = true;
#      };
#      "/nix/.rw-store" = {
#        fsType = "tmpfs";
#        options = [ "mode=0755" ];
#        neededForBoot = true;
#      };
#      "/nix/store" = {
#        overlay = {
#          lowerdir = [ "/nix/.ro-store" ];
#          upperdir = "/nix/.rw-store/store";
#          workdir = "/nix/.rw-store/work";
#        };
#        neededForBoot = true;
#      };
#    };
#
#    system = with lib; {
#      # I know that it isn't alphabetically sorted, it's done that way on purpose.
#      build = with pkgs; {
#        # A script invoking kexec on ./bzImage and ./initrd.gz.
#        # Usually used through system.build.kexecTree, but exposed here for composability.
#        kexecScript = pkgs.writeScript "kexec-boot" ''
#          #!/usr/bin/env bash
#          if ! kexec -v >/dev/null 2>&1; then
#            echo "kexec not found: please install kexec-tools" 2>&1
#            exit 1
#          fi
#          SCRIPT_DIR=$( cd -- "$( dirname -- "''${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#          kexec --load ''${SCRIPT_DIR}/bzImage \
#            --initrd=''${SCRIPT_DIR}/initrd.gz \
#            --command-line "init=${module.config.system.build.toplevel}/init ${toString module.boot.kernelParams}"
#          kexec -e
#        '';
#        kexecTree = linkFarm "kexec-tree" [
#          {
#            name = "initrd.gz";
#            path = "${module.system.build.netbootRamdisk}/initrd";
#          }
#          {
#            name = "bzImage";
#            path = "${module.system.build.kernel}/${module.system.boot.loader.kernelFile}";
#          }
#          {
#            name = "kexec-boot";
#            path = module.system.build.kexecScript;
#          }
#        ];
#        # Create the squashfs that contains the Nix store
#        squashfsStore = callPackage (path + "/nixos/lib/make-squashfs.nix") {
#          storeContents = [ config.system.build.toplevel ];
#          comp = "zstd -Xcompression-level 19";
#        };
#        # Create the initrd
#        ramdisk = pkgs.makeInitrdNG {
#          inherit (config.boot.initrd) compressor;
#          #inherit (module.boot.initrd) compressor;
#          prepend = [ "${module.system.build.initialRamdisk}/initrd" ];
#
#          contents = [
#            {
#              source = module.system.build.squashfsStore;
#              target = "/nix-store.squashfs";
#            }
#          ];
#        };
#      };
#
#      stateVersion = trivial.release;
#
#      extraDependencies = with pkgs; [
#        busybox
#        jq # for closureInfo
#        # For boot.initrd.systemd
#        makeInitrdNGTool
#      ];
#    };
#  };
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    spice.nixosModules.default
  ];

  boot = {
    consoleLogLevel = 0;
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      systemd.enable = true;
      # Silence Stage 1
      verbose = true;
    };
    kernelModules = [ "kvm-amd" ];
    kernelParams = [
      "boot.shell_on_fail"
      # https://wiki.archlinux.org/title/Silent_boot
      #"quiet"
      #"splash"
      #"rd.systemd.show_status=auto"
      #"rd.udev.log_level=3"
      "usbhid.kbpoll=1"
      #"vga=current"
    ];
    kernelPatches = [
      {
        # ALVR has a stroke, as it needs this for asynchronous reprojection
        # However, NixOS runs steam in a bubble-wrapped env simply due to how NixOS works. It emulates a Debian install to make Steam happy
        # This just makes amdgpu say "Fuck it, we'll do it anyways"
        name = "amdgpu-ignore-ctx-privileges";
        patch = pkgs.fetchpatch {
          name = "cap_sys_nice_begone.patch";
          url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
          hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
        };
      }
    ];
    tmp.useTmpfs = false;
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        copyKernels = true;
        device = "nodev";
        efiSupport = true;
        efiInstallAsRemovable = false;
#        extraEntries = ''
#          menuentry "NixOS Rescue LiveCD" {
#            linux ($drive1)/rescue-kernel init=${rescueBoot.config.system.build.toplevel}/init ${toString module.boot.kernelParams}
#            initrd ($drive1)/rescue-initrd
#          }
#        '';
#        extraFiles = {
#          "rescue-kernel" = "${module.system.build.kernel}/bzImage";
#          "rescue-initrd" = "${module.system.build.ramdisk}/initrd";
#        };
        memtest86.enable = true;
      };
      timeout = 10;
    };
  };

  console = {
    # Just point it to X11
    useXkbConfig = true;
  };

  environment = {
    shellAliases = {
      l = null;
      ll = null;
      lss = "ls --color -lha";
    };
    systemPackages = with pkgs; [
      alacritty
      alsa-utils
      alvr
      colmena
      curl
      dos2unix
      direnv
      edid-decode
      envsubst
      eog
      easyeffects
      evtest
      fastfetch
      git
      glib
      htop
      i3
      iperf
      mpv
      neovim
      nodejs_23
      obs-studio
      openssl
      pavucontrol
      pciutils
      pcmanfm
      picom
      playerctl
      pulseaudio
      rofi
      spicetify-cli
      steamcmd
      syncplay
      sysstat
      tmux
      unzip
      vim
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
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-launch
      xdg-utils
      xorg.libxcvt
      zenity
      zip
    ];
  };

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
  };

  # Set hardware to support 32-bit graphics for Wine and Proton
  hardware = {
    cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    pulseaudio.support32Bit = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    hostName = "nixos-amd";
    useDHCP = true;
    wireless.enable = true;
  };

  # Setup NixOS exprimental features and unfree options for Chrome
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
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
    spicetify = {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        autoSkipVideo
        beautifulLyrics
        hidePodcasts
        shuffle
      ];
      theme = spicePkgs.themes.sleek;
      colorScheme = "Elementary";
    };
    ssh.extraConfig = ''
      Host router
        Hostname 31.59.128.34
      Host shitzen-nixos
        Hostname 10.0.0.244
      Host chromeshit
        Hostname 10.0.0.124
      Host r2d2box
        Hostname 10.0.0.204
    '';
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };

  services = {
    displayManager.defaultSession = "none+i3";
    picom = {
      enable = true;
      activeOpacity = 1;
      fade = true;
      inactiveOpacity = 0.8;
      settings = {
        blur.strength = 5;
        fade-in-step = 1;
        fade-out-step = 1;
        fade-delta = 0;
        shadow-exclude = [
          "name = 'cpt_frame_xcb_window'"
          "class_g ?= 'discord'"
        ];
        use-damage = false;
      };
      shadow = true;
      vSync = true;
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    xserver = {
      enable = true;
      # Disable XTerm
      excludePackages = with pkgs; [
        xterm
      ];
      desktopManager.xterm.enable = false;
      displayManager.setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --newmode "2560x1440_239.97"  1442.50  2560 2800 3088 3616  1440 1443 1448 1663 -hsync +vsyn
        ${pkgs.xorg.xrandr}/bin/xrandr --addmode DP-3 2560x1440_239.97
        ${pkgs.xorg.xrandr}/bin/xrandr --output DP-3 --mode 2560x1440_239.97
      '';
      # i3
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3status
          i3lock
          i3blocks
        ];
      };
      # Set our X11 Keyboard layout
      xkb = {
        layout = "us";
      };
    };
  };

  # 8GiB Swap
  swapDevices = [
    {
      device = "/var/lib/swap1";
      size = 8192;
    }
  ];

  system = {
    copySystemConfiguration = true;
    stateVersion = "24.11";
  };

  systemd = {
    user.services = {
      easyeffects = {
        enable = true;
        after = [ "graphical-session-pre.target" ];
        description = "EasyEffects Daemon";
        partOf = [ "graphical-session.target" "pipewire.service" ];
        requires = [ "dbus.service" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.easyeffects}/bin/easyeffects --gapplication-service";
          ExecStop = "${pkgs.easyeffects}/bin/easyeffects --quit";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
    watchdog.rebootTime = "0";
  };

  time.timeZone = "America/Detroit";

  users.users = {
    vali = {
      isNormalUser = true;
      extraGroups = [ "render" "tty" "wheel" "video" ];
      packages = with pkgs; [
        (discord.override {
          withVencord = true;
        })
        feh
        flameshot
        google-chrome
        plex-desktop
        tree
      ];
    };
  };

  xdg.portal = {
    enable = true;
    # xdg-desktop-portal 1.17 reworked how portal implementations are loaded, you
    # should either set `xdg.portal.config` or `xdg.portal.configPackages`
    # to specify which portal backend to use for the requested interface.

    # https://github.com/flatpak/xdg-desktop-portal/blob/1.18.1/doc/portals.conf.rst.in
    config.common.default = "*"; # Just go back to the behaviour before 1.17
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
