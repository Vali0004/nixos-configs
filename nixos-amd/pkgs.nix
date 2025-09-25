{ config, lib, pkgs, ... }:

{
  imports = [
    ./../pkgs/module.nix
  ];

  environment.systemPackages = with pkgs; [
    # Key system (remote deploy)
    agenix
    # Terminal
    alacritty-graphics
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
    # Cache system
    cachix
    # Remote deploy
    colmena
    # Cider - Alternative Apple Music Client
    cider-2
    # Clipboard Manager
    clipmenu
    # Clipboard Manager (auto-paste)
    clipmenu-paste
    # cURL
    curl
    # macOS Translation Layer
    darling
    # XDG Mime/Desktop utils
    desktop-file-utils
    # Binary utility, desined to identify what a binary is (including the compiler)
    detect-it-easy
    # Directory envorinment
    direnv
    # DNS & IP Tool
    dig
    # dos2unix tool
    dos2unix
    # Discord
    (discord.override { withVencord = true; })
    # SMBIOS
    dmidecode
    # App launcher
    dmenu
    # .NET Disassembler
    dnspy
    # Notification daemon
    dunst
    # Extended Display Id Data Decode
    edid-decode
    # Matrix client
    element-desktop
    # Image/PDF viewer
    eog
    # Noise suppression
    easyeffects
    # Modern Neofetch
    fastfetch
    # Simpler Fastfetch Config
    fastfetch-simple
    # Simple Image Viewer
    feh
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
    # Ping tool, used to ping a specific port
    hping
    # Hex-Rays IDA Pro 9.0 Beta
    ida-pro
    # Internet performance tool
    iperf
    # IRC Client
    irssi
    # Media Player
    jellyfin-media-player
    # JSON parser
    jq
    # Archive tool
    kdePackages.ark
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
    # X CVT
    libxcvt
    # Wormhole, file sender
    magic-wormhole
    # COM Reader
    minicom
    # Video Player
    mpv
    # Directory info
    ncdu
    # nRF Studio
    nrf-studio
    # SEGGER JLink
    jlink
    # Adafurit nRF Util
    nrf-util
    # Node.js
    nodejs_24
    # Video capture tool
    obs-studio
    # SSL Client
    openssl
    # Hex Editor
    okteta
    # nix-gaming
    osu-gatari
    osu-stable
    # Tablet Driver
    opentabletdriver
    # Audio mixer
    pamixer
    # Audio control
    pavucontrol
    # PCI Utilities
    pciutils
    # Compositer
    picom
    # Audio Player Control
    playerctl
    # Minecraft launcher
    prismlauncher
    # Steam Proton Tricks (winetricks for Proton)
    protontricks
    # Audio server
    pulseaudio
    # VM
    qemu_kvm
    (writeShellScriptBin "qemu-system-x86_64-uefi" ''
      qemu-system-x86_64 \
        -bios ${OVMF.fd}/FV/OVMF.fd \
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
    # Spotify mods
    spicetify-cli
    # Steam CMD
    steamcmd
    # Syncplay, allows for syncing video streams with others via mpv
    syncplay
    # System stats
    sysstat
    # TeamSpeak
    teamspeak3
    # tmux, screen replacement
    tmux
    # Tree, helps create file structures in text form
    tree
    # Unity
    unityhub
    # ZIP Archive Undo
    unzip
    # USB Utils
    usbutils
    # Alternative Discord client
    vesktop
    # vi
    vim
    # VM helper
    virt-viewer
    # VRChat Friendship Management
    vrcx
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
    # X11 Do Tool
    xdotool
    # Fallback XDG file manager
    zenity
    # ZIP Archive Utility
    zip
  ];
}
