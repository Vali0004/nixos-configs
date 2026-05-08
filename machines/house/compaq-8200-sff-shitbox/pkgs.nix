{ pkgs
, ... }:

{
  environment.systemPackages = with pkgs; [
    # Terminal
    alacritty-graphics
    # Better TOP
    btop
    # cURL
    curl
    # Coreboot Utilities
    coreboot-utils
    devmem2
    # Discord
    (discord.override { withVencord = true; })
    # SMBIOS
    dmidecode
    # Ethernet tool
    ethtool
    # Modern Neofetch
    fastfetch
    # Screenshot Tool
    flameshot
    # Screenshot Tool (Upload)
    (pkgs.writeScriptBin "flameshot-upload" ''
      set -euo pipefail

      tmp="$(mktemp --suffix=.png)"
      trap 'rm -f "$tmp"' EXIT

      ${pkgs.flameshot}/bin/flameshot gui --accept-on-select -r > "$tmp"

      resp="$(${pkgs.curl}/bin/curl -sS --fail-with-body \
        -H "@/run/agenix/zipline-upload-headers" \
        -H "x-zipline-domain: furryfemboy.ca" \
        -F "file=@$tmp" \
        "https://cdn.lab004.dev/api/upload")"

      url="$(printf '%s' "$resp" | ${pkgs.jq}/bin/jq -er '.files[0].url')"

      printf '%s' "$url" | ${pkgs.xclip}/bin/xclip -selection clipboard
    '')
    # Flash programmer
    flashprog
    # Internet utilities (ping6, etc.)
    inetutils
    # Internet performance tool
    iperf
    # JSON parser
    jq
    # Killall (psmisc)
    killall
    # Load monitor sensors
    lm_sensors
    # Video Player
    mpv
    # Directory info
    ncdu
    # Video capture tool
    obs-studio
    # PCI Utilities
    pciutils
    # Audio Player Control
    playerctl
    # Python
    python3
    # Ookla Speedtest
    speedtest
    # Syncplay, allows for syncing video streams with others via mpvr
    syncplay
    # TCP Dump
    tcpdump
    # ZIP Archive Undo
    unzip
    # USB Utils
    usbutils
    # Vulkan
    spirv-cross
    spirv-tools
    vulkan-extension-layer
    vulkan-tools
    vulkan-validation-layers
    # X Window System Clipboard
    xclip
    # WebGet
    wget
    # Wine
    wineWow64Packages.stable
    winetricks
    # ZIP Archive Utility
    zip
  ];
}