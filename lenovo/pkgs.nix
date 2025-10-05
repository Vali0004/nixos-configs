{ config, lib, pkgs, ... }:

{
  imports = [
    ../pkgs/module.nix
  ];

  hasNixGaming = false;

  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty
    # Key system (remote deploy)
    agenix
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
    # Browser
    google-chrome
    # Internet performance tool
    iperf
    # Media Player
    jellyfin-media-player
    # JSON parser
    jq
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
    # Video capture tool
    obs-studio
    # Audio Player Control
    playerctl
    # GPU Control
    radeon-profile
    # Skylander's Portal Tool
    skylanders
    # System stats
    sysstat
    # Unzip
    unzip
    # USB Utils
    usbutils
    # Editor
    vscode
    vscode-extensions.bbenoist.nix
    vscode-extensions.jnoortheen.nix-ide
    vscode-extensions.ms-vscode.cpptools-extension-pack
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
  ];
}
