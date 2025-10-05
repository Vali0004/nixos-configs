{ config, lib, pkgs, ... }:

{
  imports = [
    ../pkgs/module.nix
  ];

  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty-graphics
    # Key system (remote deploy)
    agenix
    # ALSA (PipeWire/Audio Subsystem)
    alsa-utils
    # XDG GUI Debug Utility
    bustle
    # XDG Debug Utility
    bridge-utils
    # Better TOP
    btop
    # BeamMP Launcher
    beammp-launcher
    # 3D Modeling
    blender
    # Remote deploy
    colmena
    # Cider - Alternative Apple Music Client
    cider-2
    # cURL
    curl
    # XDG Mime/Desktop utils
    desktop-file-utils
    # Binary utility, desined to identify what a binary is (including the compiler)
    detect-it-easy
    # DNS & IP Tool
    dig
    # dos2unix tool
    dos2unix
    # Discord
    (discord.override { withVencord = true; })
    # SMBIOS
    dmidecode
    # .NET Disassembler
    dnspy
    # Extended Display Id Data Decode
    edid-decode
    # Matrix client
    element-desktop
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
    # Binary hacking
    ghidra
    # Calculator
    gnome-calculator
    # sed
    gnused
    # GTK3, used for gtk-launch in dmenu
    gtk3
    # Browser
    google-chrome
    # Hex-Rays IDA Pro 9.0 Beta
    ida-pro
    # Internet utilities (ping6, etc.)
    inetutils
    # Internet performance tool
    iperf
    # IRC Client
    irssi
    # Media Player
    jellyfin-media-player
    # JSON parser
    jq
    # MS Paint
    kdePackages.kolourpaint
    # CAD software
    kicad
    # Killall (psmisc)
    killall
    # File browser
    nemo-with-extensions
    # Network Security Services
    nss
    # cli unrar
    libarchive
    # Wormhole, file sender
    magic-wormhole
    # COM Reader
    minicom
    # Video Player
    mpv
    # Directory info
    ncdu
    # Network tools
    net-tools
    # nRF Studio
    nrf-studio
    # SEGGER JLink
    jlink
    # Adafurit nRF Util
    nrf-util
    # Video capture tool
    obs-studio
    # nix-gaming
    osu-gatari
    osu-stable
    # PCI Utilities
    pciutils
    # Audio Player Control
    playerctl
    # Minecraft launcher
    prismlauncher
    # VM
    (writeShellScriptBin "qemu-system-x86_64-uefi" ''
      ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
        -bios ${pkgs.OVMFFull.fd}/FV/OVMF.fd \
        "$@"
    '')
    # Thunderstore (Mod Manager)
    r2modman
    # GPU Control
    radeon-profile
    # Single-frame Graphics Debugging
    renderdoc
    # Socket Output Concat
    socat
    # Syncplay, allows for syncing video streams with others via mpv
    syncplay
    # System stats
    sysstat
    # TCP Dump
    tcpdump
    # Unity
    unityhub
    # ZIP Archive Undo
    unzip
    # USB Utils
    usbutils
    # Alternative Discord client
    vesktop
    # VM helper
    virt-viewer
    # VRChat Friendship Management
    vrcx
    # Editor
    vscode
    vscode-extensions.bbenoist.nix
    vscode-extensions.jnoortheen.nix-ide
    vscode-extensions.ms-vscode.cpptools-extension-pack
    vscode-extensions.ms-vscode.cmake-tools
    vscode-extensions.shardulm94.trailing-spaces
    # Vulkan
    vulkan-extension-layer
    vulkan-tools
    vulkan-validation-layers
    # WebGet
    wget
    # Packet sniffer
    wireshark
    # Wine
    wineWowPackages.stable
    winetricks
    # XDG
    xdg-launch
    xdg-utils
    # ZIP Archive Utility
    zip
  ];
}
