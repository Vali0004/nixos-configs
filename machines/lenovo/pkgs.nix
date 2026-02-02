{ pkgs
, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty-graphics
    # Key system (remote deploy)
    agenix
    # ADB
    android-tools
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
    # Simpler Fastfetch Config
    fastfetch-simple
    # Tool used to check file types
    file
    # Screenshot Tool
    flameshot
    # Screenshot Tool (Upload)
    flameshot-upload
    # CLI Fuzzy Finder
    fzf
    # Debugger
    gdb
    # sed
    gnused
    # Hex-Rays IDA Pro 9.0 Beta
    ida-pro
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
    # Node.JS
    nodejs_24
    # Video capture tool
    obs-studio
    # Audio Player Control
    playerctl
    # Ookla Speedtest
    speedtest
    # Payment API - Used for testing
    stripe-cli
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