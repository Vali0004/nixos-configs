{ config, lib, pkgs, ... }:

{
  imports = [
    ../../pkgs/module.nix
  ];

  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty-graphics
    # Key system (remote deploy)
    agenix
    # Android tools (ADB)
    android-tools
    # Arduino IDE
    arduino
    # Better TOP
    btop
    # BeamMP Launcher
    beammp-launcher
    # 3D Modeling
    blender
    # Binary Tools
    bintools
    # Remote deploy
    colmena
    # Cider - Alternative Apple Music Client
    cider-2
    # cURL
    curl
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
    # Another matrix client
    fluffychat
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
    # Network Security Services
    nss
    # cli unrar
    libarchive
    # Reduced blanking profiles
    libxcvt
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
    # Node.js - JavaScript Engine
    nodejs_24
    # nRF Studio
    nrf-studio
    # SEGGER JLink
    jlink
    # nRF SDK
    nrf5-sdk
    # Adafurit nRF Util
    nrf-util
    # ndisc - used for RAs
    ndisc6
    # Network Map
    nmap
    # Video capture tool
    obs-studio
    # Razer Software Daemon
    openrazer-daemon
    # nix-gaming
    osu-gatari
    osu-stable
    # PCI Utilities
    pciutils
    # Audio Player Control
    playerctl
    # Razer Daemon Frontend
    polychromatic
    # Python
    python3
    # Minecraft launcher
    prismlauncher
    # proot
    proot
    # VM
    qemu
    (writeShellScriptBin "qemu-system-x86_64-uefi" ''
      ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
        -bios ${pkgs.OVMFFull.fd}/FV/OVMF.fd \
        "$@"
    '')
    # Thunderstore (Mod Manager)
    r2modman
    # Skylander's Portal Tool
    skylanders-nfc-reader
    # SlimeVR Trackers (VRC)
    slimevr
    slimevr-server
    # Socket Output Concat
    socat
    # Syncplay, allows for syncing video streams with others via mpvr
    syncplay
    # System stats
    sysstat
    # TCP Dump
    tcpdump
    # TMate
    tmate
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
    # ZIP Archive Utility
    zip
  ];
}