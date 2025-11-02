{ config, lib, pkgs, ... }:

{
  imports = [
    ../../pkgs/module.nix
  ];

  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty-graphics
    # Better TOP
    btop
    # cURL
    curl
    # DNS & IP Tool
    dig
    # Discord
    (discord.override { withVencord = true; })
    # Image/PDF viewer
    eog
    # Modern Neofetch
    fastfetch
    # Simpler Fastfetch Config
    fastfetch-simple
    # Screenshot Tool
    flameshot
    # Screenshot Tool (Upload to fuckk.lol)
    flameshot-upload
    # Tool used to check file types
    file
    # CLI Fuzzy Finder
    fzf
    # Debugger
    gdb
    # Calculator
    gnome-calculator
    # sed
    gnused
    # Internet utilities (ping6, etc.)
    inetutils
    # Internet performance tool
    iperf
    # JSON parser
    jq
    # MS Paint
    kdePackages.kolourpaint
    # Killall (psmisc)
    killall
    # cli unrar
    libarchive
    # Reduced blanking profiles
    libxcvt
    # Video Player
    mpv
    # Directory info
    ncdu
    # Network tools
    net-tools
    # Node.js - JavaScript Engine
    nodejs_24
    # PCI Utilities
    pciutils
    # Audio Player Control
    playerctl
    # Socket Output Concat
    socat
    # System stats
    sysstat
    # TCP Dump
    tcpdump
    # ZIP Archive Undo
    unzip
    # USB Utils
    usbutils
    # Vulkan
    vulkan-extension-layer
    vulkan-tools
    vulkan-validation-layers
    # WebGet
    wget
    # ZIP Archive Utility
    zip
  ];
}