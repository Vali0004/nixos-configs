{ config, lib, pkgs, ... }:

let
  secrets = import ./../network-secrets.nix { inherit lib; };

  flameshot_fuckk_lol = pkgs.writeScriptBin "flameshot_fuckk_lol" ''
    ${pkgs.flameshot}/bin/flameshot gui --accept-on-select -r > /tmp/screenshot.png
    ${pkgs.curl}/bin/curl -H "authorization: ${secrets.zipline.authorization}" https://holy.fuckk.lol/api/upload -F file=@/tmp/screenshot.png -H 'content-type: multipart/form-data' | ${pkgs.jq}/bin/jq -r .files[0].url | tr -d '\n' | ${pkgs.xclip}/bin/xclip -selection clipboard
  '';

  fastfetch_simple = pkgs.writeScriptBin "fastfetch_simple" ''
    ${pkgs.fastfetch}/bin/fastfetch --config /home/vali/.config/fastfetch/simple.jsonc
  '';

  dmenu = ((pkgs.dmenu.override {
    conf = ./dmenu-config.h;
  }).overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [ pkgs.libspng ];
    src = /home/vali/development/dmenu;
    postPatch = ''
      ${old.postPatch or ""}
      sed -ri -e 's!\<(dmenu|dmenu_path_desktop|stest)\>!'"$out/bin"'/&!g' dmenu_run_desktop
      sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path_desktop
    '';
  }));
  clipmenu-paste = pkgs.callPackage ./clipmenu { inherit dmenu; };

  agenix = builtins.getFlake "github:ryantm/agenix";
  agenixPkgs = agenix.outputs.packages.x86_64-linux;

  nixGaming = builtins.getFlake "github:fufexan/nix-gaming";
  nixGamingPkgs = nixGaming.outputs.packages.x86_64-linux;

  osu-base = pkgs.callPackage ./osu {
    osu-mime = nixGamingPkgs.osu-mime;
    wine-discord-ipc-bridge = nixGamingPkgs.wine-discord-ipc-bridge;
    proton-osu-bin = nixGamingPkgs.proton-osu-bin;
  };
  osu-stable = osu-base;
  osu-gatari = (osu-base.override {
    desktopName = "osu!gatari";
    pname = "osu-gatari";
    launchArgs = "-devserver gatari.pw";
  });
in {
  imports = [
    agenix.nixosModules.default
    nixGaming.nixosModules.pipewireLowLatency
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "libxml2-2.13.8"
  ];

  environment.systemPackages = with pkgs; [
    # Key system (remote deploy)
    agenixPkgs.agenix
    # Terminal
    alacritty-graphics
    alsa-utils
    # XDG debug
    bustle
    bridge-utils
    # Better TOP
    btop
    # BeamMP
    (callPackage ./beammp-launcher {})
    # Cache system
    cachix
    # Remote deploy
    colmena
    # Cider - Alternative Apple Music Client
    cider-2
    # Clipboard Manager
    clipmenu
    clipmenu-paste
    # cURL
    curl
    # macOS Translation Layer
    (callPackage ./darling {})
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
    ((discord.override { withVencord = true; }).overrideAttrs {
      src = fetchurl {
        url = "https://stable.dl2.discordapp.net/apps/linux/0.0.106/discord-0.0.106.tar.gz";
        hash = "sha256-FqY2O7EaEjV0O8//jIW1K4tTSPLApLxAbHmw4402ees=";
      };
    })
    # SMBIOS
    dmidecode
    # App launcher
    dmenu
    # .NET Disassembler
    (callPackage ./dnspy {})
    # Notification daemon
    dunst
    # Extended Display Id Data Decode
    edid-decode
    # Matrix client
    element-desktop
    envsubst
    # Image/pdf viewer
    eog
    # Noise suppression
    easyeffects
    evtest
    # Flexing
    fastfetch
    fastfetch_simple
    feh
    # Screenshot tool
    flameshot
    # Screenshot tool with my uploader secret
    flameshot_fuckk_lol
    # Tool used to check file types
    file
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
    (callPackage ./ida-pro {})
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
    # Fixes BeamNG
    nss
    # cli unrar
    libarchive
    # X CVT
    libxcvt
    # Wormhole
    magic-wormhole
    # COM Reader
    minicom
    # 360-deploy
    morph
    # Video Player
    mpv
    # Directory info
    ncdu
    # nRF Studio
    (callPackage ./nordic {})
    # SEGGER JLink
    (callPackage ./nordic/jlink {})
    # Adafurit nRF Util
    (callPackage ./nordic/nrfutil {})
    # Node.js
    nodejs_24
    obs-studio
    openssl
    # Hex Editor
    okteta
    # nix-gaming pkg, slightly modified
    osu-gatari
    osu-stable
    # Tablet Driver
    opentabletdriver
    # Different audio control
    pamixer
    # Audio control
    pavucontrol
    pciutils
    # Compositer
    picom
    playerctl
    # Minecraft launcher
    prismlauncher
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
    # Single-frame gfx debugging
    renderdoc
    # socat - listener
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
    # Remote shell service over tmux
    tmate
    # Tree, helps create file structures in text form
    tree
    # Unity
    (unityhub.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        ${desktop-file-utils}/bin/update-desktop-database $out/share/applications
      '';
    }))
    # Unzip
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
    # wget
    wget
    # Packet sniffer
    wireshark
    # Wine
    wineWowPackages.stable
    winetricks
    # Electron hell
    xdg-launch
    xdg-utils
    # X11 helper
    xdotool
    # Fallback XDG file manager
    zenity
    zip
  ];
}
