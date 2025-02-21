# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let 
  spice = builtins.getFlake "github:Gerg-L/spicetify-nix";
  spicePkgs = spice.outputs.legacyPackages.x86_64-linux;
in {
  imports = [
    ./hardware-configuration.nix
    spice.nixosModules.default
  ];

  boot.loader = {
    grub = {
      enable = true;
      copyKernels = true;
      device = "nodev";
      efiSupport = true;
      efiInstallAsRemovable = false;
    };
    efi.canTouchEfiVariables = true;
  };

  console = {
    useXkbConfig = true; # use xkb.options in tty.
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
      curl
      dos2unix
      envsubst
      evtest
      fastfetch
      git
      htop
      i3
      iperf
      mpv
      neovim
      openssl
      pavucontrol
      pciutils
      picom
      playerctl
      pulseaudio
      spotify
      spicetify-cli
      steamcmd
      sysstat
      tmux
      unzip
      vim
      vulkan-extension-layer
      vulkan-tools
      vulkan-validation-layers
      wget
      wireshark
      zenity
      zip
    ];
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    pulseaudio.support32Bit = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    hostName = "nixos-amd";
    wireless.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  programs = {
    command-not-found.enable = true;
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
      settings.blur = {
        strength = 5;
      };
      shadow = true;
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
      excludePackages = with pkgs; [
        xterm
      ];
      desktopManager.xterm.enable = false;
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          i3status
          i3lock
          i3blocks
          rofi
        ];
      };
      xkb = {
        layout = "us";
      };
    };
  };

  system = {
    copySystemConfiguration = true;
    stateVersion = "24.11";
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
        vscode
      ];
    };
  };

}
