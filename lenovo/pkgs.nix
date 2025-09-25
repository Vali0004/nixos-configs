{ config, lib, pkgs, ... }:

{
  imports = [
    ./../pkgs/module.nix
  ];

  hasNixGaming = false;

  environment.systemPackages = with pkgs; [
    # Key system (remote deploy)
    agenix
    # Terminal
    alacritty-graphics
    # ALSA (PipeWire/Audio Subsystem)
    alsa-utils
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
    # SMBIOS
    dmidecode
    # Notification daemon
    dunst
    # Flexing
    fastfetch
    # Screenshot tool
    flameshot
    # Tool used to check file types
    file
    # CLI Fuzzy Finder
    fzf
    # Debugger
    gdb
    # sed
    gnused
    # GTK3, used for gtk-launch in dmenu
    gtk3
    # Browser
    google-chrome
    # Internet performance tool
    iperf
    # Media Player
    jellyfin-media-player
    # JSON parser
    jq
    # Archive tool
    kdePackages.ark
    # Killall (psmisc)
    killall
    # File browser
    nemo-with-extensions
    # cli unrar
    libarchive
    # Wormhole
    magic-wormhole
    # Video Player
    mpv
    # Directory info
    ncdu
    # Node.js
    nodejs_24
    # Video capture tool
    obs-studio
    # SSL Library
    openssl
    # Hex Editor
    okteta
    # Different audio control
    pamixer
    # Audio control
    pavucontrol
    # PCI Utilities
    pciutils
    # Compositer
    picom
    # Audio Player Control
    playerctl
    # GPU Control
    radeon-profile
    # App launcher
    rofi
    # socat - listener
    socat
    # Spotify mods
    spicetify-cli
    # Steam CMD
    steamcmd
    # System stats
    sysstat
    # Remote shell service over tmux
    tmate
    # Tree, helps create file structures in text form
    tree
    # Unzip
    unzip
    # USB Utils
    usbutils
    # vi
    vim
    # Editor
    vscode
    vscode-extensions.mkhl.direnv
    vscode-extensions.bbenoist.nix
    vscode-extensions.jnoortheen.nix-ide
    vscode-extensions.mshr-h.veriloghdl
    vscode-extensions.ms-vscode.cpptools-extension-pack
    vscode-extensions.ms-vscode.cmake-tools
    vscode-extensions.shardulm94.trailing-spaces
    # Vulkan
    vulkan-extension-layer
    vulkan-tools
    vulkan-validation-layers
    # wget
    wget
    # XDG
    xdg-launch
    xdg-utils
    # X11 helper
    xdotool
    # Fallback XDG file manager
    zenity
    # ZIP Archive Tool
    zip
  ];
}
