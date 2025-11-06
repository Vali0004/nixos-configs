{ pkgs, ... }:

{
  imports = [
    ../../pkgs/module.nix
  ];

  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty-graphics
    # Key system (remote deploy)
    agenix
    # Better TOP
    btop
    # Remote deploy
    colmena
    # cURL
    curl
    # DNS & IP Tool
    dig
    # dos2unix tool
    dos2unix
    # Discord
    (discord.override { withVencord = true; })
    # Flexing
    fastfetch
    # Tool used to check file types
    file
    # Screenshot tool
    flameshot
    # CLI Fuzzy Finder
    fzf
    # Debugger
    gdb
    # sed
    gnused
    # Internet performance tool
    iperf
    # JSON parser
    jq
    # Killall (psmisc)
    killall
    # cli unrar
    libarchive
    # Wormhole
    magic-wormhole
    # Video Player
    mpv
    # Directory info
    ncdu
    # Video capture tool
    obs-studio
    # Audio Player Control
    playerctl
    # RetroArch
    libretro.mame
    libretro.mgba
    libretro.pcsx2
    libretro.picodrive
    libretro.ppsspp
    libretro.snes9x
    retroarch
    # Skylander's Portal Tool
    skylanders-nfc-reader
    # Syncplay, allows for syncing video streams with others via mpv
    syncplay
    # System stats
    sysstat
    # Unzip
    unzip
    # USB Utils
    usbutils
    # Vulkan
    vulkan-extension-layer
    vulkan-tools
    vulkan-validation-layers
    # wget
    wget
  ];
}