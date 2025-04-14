# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ config, lib, modulesPath, pkgs, ... }:

let 
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  spice = builtins.getFlake "github:Gerg-L/spicetify-nix";
  toxvpn = (builtins.getFlake "github:cleverca22/toxvpn/1830f9b8c12b4c5ef36b1f60f7e600cd1ecf4ccf").packages.x86_64-linux.default;
  spicePkgs = spice.outputs.legacyPackages.x86_64-linux;
  # i3 config extras
  i3Config = {
    # Modifer keys
    windows = "Mod4";
    windowsCode = "133";
    modifier = "Mod1";
    smodifier = "Shift";
    # Application
    wmAppLauncher = "\"rofi -modi drun,run -show drun\"";
    wmAppTerminal = "i3-sensible-terminal";
    wmAppBrowser = "google-chrome-stable";
    # Theme
    barBg = "#3B3B3B";
    barStatusline = "#FFFFFF";
    barSeparator = "#FFFFFF";
    barFocusedWorkspaceBg = "#A3BE8C";
    barFocusedWorkspaceFg = "#3B3B3B";
    barActiveWorkspaceBg = "#EBCB8B";
    barActiveWorkspaceFg = "#3B3B3B";
    barInactiveWorkspaceBg = "#BF616A";
    barInactiveWorkspaceFg = "#3B3B3B";
    barUrgentWorkspaceBg = "#D08770";
    barUrgentWorkspaceFg = "#3B3B3B";
  };
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    spice.nixosModules.default
    (import "${home-manager}/nixos")
  ];

  boot = {
    consoleLogLevel = 0;
    extraModprobeConfig = "options vfio-pci ids=1002:7340,1002:ab38";
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      systemd.enable = true;
      # Silence Stage 1
      verbose = false;
    };
    kernelModules = [
      "kvm-amd"
    ];
    kernelParams = [
      # Enable IOMMU
      "amd_iommu=on"
      "boot.shell_on_fail"
      # https://wiki.archlinux.org/title/Silent_boot
#      "quiet"
#      "splash"
#      "rd.systemd.show_status=auto"
      #"rd.udev.log_level=3"
      "usbhid.kbpoll=1"
#      "vga=current"
    ];
    kernelPackages = let
      version = "6.14.2";
      suffix = "zen1";
    in pkgs.linuxPackagesFor (pkgs.linux_zen.override {
      inherit version suffix;
      modDirVersion = lib.versions.pad 3 "${version}-${suffix}";
      src = pkgs.fetchFromGitHub {
        owner = "zen-kernel";
        repo = "zen-kernel";
        rev = "v${version}-${suffix}";
      };
    });
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
      bridge-utils
      busybox
      cachix
      colmena
      curl
      dos2unix
      direnv
      dmidecode
      edid-decode
      envsubst
      eog
      easyeffects
      evtest
      fastfetch
      git
      glib
      gnome-software
      htop
      iperf
      mpv
      neovim
      nodejs_23
      obs-studio
      openssl
      opentabletdriver
      p7zip-rar
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
    # Mount the NFS
    "/data" = {
      device = "10.0.0.244:/data";
      fsType = "nfs";
      options = [ "x-systemd.automount" "noauto" "soft" ];
    };
  };

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

  home-manager = {
    users.vali = {
      home.stateVersion = "25.05";
      gtk = {
        enable = true;
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
      };
      xdg.mimeApps = {
        associations = {
          added = {
            "x-scheme-handler/osu" = "osu.desktop";
          };
        };
        defaultApplications = {
          "x-scheme-handler/osu" = [ "osu.desktop" ];
        };
        enable = true;
      };
      xsession.windowManager.i3 = {
        enable = true;
        package = pkgs.i3-rounded;
        config = {
          # Modifer keys
          modifier = "${i3Config.modifier}";
          # Theme
          fonts = {
            names = [ "DejaVu Sans Mono 11" "FontAwesome5Free" ];
            style = "Regular";
            size = 11.0;
          };
          colors = {
            focused = {
              border = "#0F0F0F";
              background = "#0F0F0F";
              text = "#FFFFFF";
              indicator = "#0F0F0F";
              childBorder = "#000000";
            };
            focusedInactive = {
              border = "#0F0F0F";
              background = "#0F0F0F";
              text = "#FFFFFF";
              indicator = "#0F0F0F";
              childBorder = "#000000";
            };
            unfocused = {
              border = "#3B3B3B";
              background = "#3B3B3B";
              text = "#FFFFFF";
              indicator = "#3B3B3B";
              childBorder = "#000000";
            };
            background = "#0F0F0F";
          };
          gaps = {
            inner = 2;
            outer = 0;
          };
          # Use Mouse+$mod to drag floating windows to their wanted position
          floating.modifier = "${i3Config.modifier}";
          # Keybindings
          keybindings = {
            #  Applications
            # Start a terminal
            "${i3Config.modifier}+Return" = "exec ${i3Config.wmAppTerminal}";
            # Start a program launcher
            "${i3Config.modifier}+d" = "exec ${i3Config.wmAppTerminal}";
            # Start a web browser
            "${i3Config.modifier}+${i3Config.smodifier}+Return" = "exec ${i3Config.wmAppBrowser}";
            
            # Kill focused window
            "${i3Config.modifier}+q" = "kill";

            # Pipewire-pulse
            "XF86AudioMute" = "exec pactl set-sink-mute 0 toggle";
            "XF86AudioMute --release" = "exec pkill -RTMIN+1 i3blocks";
            "XF86AudioLowerVolume" = "exec pactl set-sink-volume 0 -5%";
            "XF86AudioLowerVolume --release" = "exec pkill -RTMIN+1 i3blocks";
            "XF86AudioRaiseVolume" = "exec pactl set-sink-volume 0 +5%";
            "XF86AudioRaiseVolume --release" = "exec pkill -RTMIN+1 i3blocks";

            # Media player controls
            "XF86AudioPlay" = "exec playerctl play-pause";
            "XF86AudioPause" = "exec playerctl play-pause";
            "XF86AudioNext" = "exec playerctl next";
            "XF86AudioPrev" = "exec playerctl previous";

            # Change focus (Alternatively, you can use the cursor keys)
            "${i3Config.modifier}+j" = "focus left";
            "${i3Config.modifier}+Left" = "focus left";
            "${i3Config.modifier}+k" = "focus down";
            "${i3Config.modifier}+Down" = "focus down";
            "${i3Config.modifier}+i" = "focus up";
            "${i3Config.modifier}+Up" = "focus up";
            "${i3Config.modifier}+l" = "focus right";
            "${i3Config.modifier}+Right" = "focus right";

            # Move focused window (Alternatively, you can use the cursor keys)
            "${i3Config.modifier}+${i3Config.smodifier}+j" = "move left";
            "${i3Config.modifier}+${i3Config.smodifier}+Left" = "move left";
            "${i3Config.modifier}+${i3Config.smodifier}+k" = "move down";
            "${i3Config.modifier}+${i3Config.smodifier}+Down" = "move down";
            "${i3Config.modifier}+${i3Config.smodifier}+i" = "move up";
            "${i3Config.modifier}+${i3Config.smodifier}+Up" = "move up";
            "${i3Config.modifier}+${i3Config.smodifier}+l" = "move right";
            "${i3Config.modifier}+${i3Config.smodifier}+Right" = "move right";

            # Split in horizontal orientation
            "${i3Config.modifier}+h" = "split h";
            # Split in vertical orientation
            "${i3Config.modifier}+v" = "split v";

            # Enter fullscreen mode for the focused container
            "${i3Config.modifier}+f" = "fullscreen";
            # Toggle between tiling and floating
            "${i3Config.modifier}+${i3Config.smodifier}+f" = "floating toggle";
            # Change focus between tiling and floating windows
            "${i3Config.modifier}+space" = "focus mode_toggle";

            # Change container layout (stacked, tabbed, toggle split)
            "${i3Config.modifier}+s" = "layout stacking";
            "${i3Config.modifier}+w" = "layout tabbed";
            "${i3Config.modifier}+e" = "layout toggle split";
            # Focus the parent container
            "${i3Config.modifier}+a" = "focus parent";
            # Focus the child container
            #"${i3Config.modifier}+d" = "focus child";

            # Switch to workspace (${smodifier} moves focused containers to workspace)
            "${i3Config.modifier}+1" = "workspace 1";
            "${i3Config.modifier}+${i3Config.smodifier}+1" = "move container to workspace 1";
            "${i3Config.modifier}+2" = "workspace 2";
            "${i3Config.modifier}+${i3Config.smodifier}+2" = "move container to workspace 2";
            "${i3Config.modifier}+3" = "workspace 3";
            "${i3Config.modifier}+${i3Config.smodifier}+3" = "move container to workspace 3";
            "${i3Config.modifier}+4" = "workspace 4";
            "${i3Config.modifier}+${i3Config.smodifier}+4" = "move container to workspace 4";
            "${i3Config.modifier}+5" = "workspace 5";
            "${i3Config.modifier}+${i3Config.smodifier}+5" = "move container to workspace 5";
            "${i3Config.modifier}+6" = "workspace 6";
            "${i3Config.modifier}+${i3Config.smodifier}+6" = "move container to workspace 6";
            "${i3Config.modifier}+7" = "workspace 7";
            "${i3Config.modifier}+${i3Config.smodifier}+7" = "move container to workspace 7";
            "${i3Config.modifier}+8" = "workspace 8";
            "${i3Config.modifier}+${i3Config.smodifier}+8" = "move container to workspace 8";
            "${i3Config.modifier}+9" = "workspace 9";
            "${i3Config.modifier}+${i3Config.smodifier}+9" = "move container to workspace 9";
            "${i3Config.modifier}+0" = "workspace 10";
            "${i3Config.modifier}+${i3Config.smodifier}+0" = "move container to workspace 10";
            # Restart the configuration file
            "${i3Config.modifier}+${i3Config.smodifier}+c" = "reload";
            # Restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
            "${i3Config.modifier}+${i3Config.smodifier}+r" = "restart";
            # Exit i3 (logs you out of your X session)
            "${i3Config.modifier}+${i3Config.smodifier}+e" = "exec \"i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'\"";
            # Resize window (You can also use the mouse)
            "${i3Config.modifier}+r" = "mode resize";
            # Flameshot keybind
            "Print" = "exec flameshot gui";
          };
          keycodebindings = {
            # Start a program launcher
            "${i3Config.windowsCode}" = "exec ${i3Config.wmAppLauncher}";
          };
          modes = {
            resize = {
              # These bindings trigger as soon as you enter the resize mode

              # Pressing up or i will shrink the window's height.
              "Up" = "resize shrink height 10 px or 10 ppt";
              "i" = "resize shrink height 10 px or 10 ppt";
              # Pressing down or kwill grow the window's height.
              "Down" = "resize grow height 10 px or 10 ppt";
              "k" = "resize grow height 10 px or 10 ppt";
              # Pressing left or j will shrink the window's width.
              "Left" = "resize shrink width 10 px or 10 ppt";
              "j" = "resize shrink width 10 px or 10 ppt";
              # Pressing right or l will grow the window's width.
              "Right" = "resize grow width 10 px or 10 ppt";
              "l" = "resize grow width 10 px or 10 ppt";
              # Back to normal: Enter, Escape, or ${modifier}+r
              "Escape" = "mode default";
              "Return" = "mode default";
              "${i3Config.modifier}+r" = "mode default";
            };
          };
          bars = [
            {
              position = "bottom";
              statusCommand = "${pkgs.i3blocks}/bin/i3blocks";
              colors = {
                background = "${i3Config.barBg}";
                statusline = "${i3Config.barStatusline}";
                separator = "${i3Config.barSeparator}";

                focusedWorkspace = {
                  border = "${i3Config.barFocusedWorkspaceBg}";
                  background = "${i3Config.barFocusedWorkspaceBg}";
                  text = "${i3Config.barFocusedWorkspaceFg}";
                };
                activeWorkspace = {
                  border = "${i3Config.barActiveWorkspaceBg}";
                  background = "${i3Config.barActiveWorkspaceBg}";
                  text = "${i3Config.barActiveWorkspaceFg}";
                };
                inactiveWorkspace = {
                  border = "${i3Config.barInactiveWorkspaceBg}";
                  background = "${i3Config.barInactiveWorkspaceBg}";
                  text = "${i3Config.barInactiveWorkspaceFg}";
                };
                urgentWorkspace = {
                  border = "${i3Config.barUrgentWorkspaceBg}";
                  background = "${i3Config.barUrgentWorkspaceBg}";
                  text = "${i3Config.barUrgentWorkspaceFg}";
                };
              };
            }
          ];
        };
      };
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
    gnupg.agent = {
      enable = true;
      enableBrowserSocket = true;
      enableExtraSocket = true;
      enableSSHSupport = true;
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
      IdentityFile /home/vali/.ssh/id_rsa
      IdentityFile /home/vali/.ssh/nixos_main
      Host router
        Hostname 31.59.128.8
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
    virt-manager = {
      enable = true;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
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
    pulseaudio.support32Bit = true;
    toxvpn = {
      enable = true;
      auto_add_peers = [
        "e0f6bcec21be59c77cf338e3946a766cd17a8e9c40a2b7fe036e7996f3a59554b4ecafdc2df6" # chromeshit
        "dd51f5f444b63c9c6d58ecf0637ce4c161fe776c86dc717b2e209bc686e56a5d2227dfee1338" # clever
        "a4ae9a2114f5310bef4381c463c09b9491c7f0cf0e962bc8083620e2555fd221020e75e411b4" # router
        "3e24792c18ab55c59974a356e2195f165e0d967726533818e5ac0361b264ea671d1b3a8ec221" # shitzen
      ];
      localip = "10.0.127.4";
    };
    udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2e3c|8089", ATTRS{idProduct}=="c365|0009", GROUP="wheel"
    '';
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
        extraSessionCommands = ''
          feh --bg-center /home/vali/wallpaper.jpg
        '';
        package = pkgs.i3-rounded;
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
    stateVersion = "25.05";
  };

  systemd = {
    services.toxvpn.serviceConfig.TimeoutStartSec = "infinity";
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

  users = {
    groups = {
      libvirtd.members = [
        "vali"
      ];
    };
    users = {
      vali = {
        isNormalUser = true;
        extraGroups = [
          "qemu-libvirtd"
          "render"
          "tty"
          "wheel"
          "video"
        ];
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
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        ovmf.enable = true;
        ovmf.packages = with pkgs; [
          OVMFFull.fd
        ];
        package = pkgs.qemu_kvm;
        runAsRoot = false;
      };
    };
    spiceUSBRedirection.enable = true;
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
