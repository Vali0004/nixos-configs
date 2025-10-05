{ config, lib, pkgs, ... }:

let
  nixGamingFlake = builtins.getFlake "github:fufexan/nix-gaming";
  agenixFlake = builtins.getFlake "github:ryantm/agenix";
  spicetifyFlake = builtins.getFlake "github:Gerg-L/spicetify-nix";
  toxvpnFlake = builtins.getFlake "github:cleverca22/toxvpn/403586be0181a0b20dfc0802580f7f919aaa83de";
  openhmdFlake = builtins.getFlake "github:Vali0004/OpenHMD/c56529c22618325dfc31e7c44f17e804cb7e7edf";
in {
  options.hasNixGaming = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable nix-gaming integration.";
  };

  imports = [
    agenixFlake.nixosModules.default
    nixGamingFlake.nixosModules.pipewireLowLatency
    spicetifyFlake.nixosModules.default
  ];

  config = {
    # Required for agenix
    nixpkgs.config.permittedInsecurePackages = [
      "libxml2-2.13.8"
      "qtwebengine-5.15.19"
    ];

    nixpkgs.overlays = [
      # Flake overrides
      (self: super: {
        openhmd = openhmdFlake.outputs.packages.x86_64-linux.openhmd;
        agenix = agenixFlake.outputs.packages.x86_64-linux.agenix;
        spicetifyThemes = spicetifyFlake.outputs.legacyPackages.x86_64-linux.themes;
        spicetifyExtensions = spicetifyFlake.outputs.legacyPackages.x86_64-linux.extensions;
        toxvpn = toxvpnFlake.packages.x86_64-linux.default;
      })
      # Existing pkgs
      (self: super: {
        dmenu = super.dmenu.overrideAttrs (old: {
          buildInputs = (old.buildInputs or []) ++ [ pkgs.libspng ];
          src = /home/vali/development/dmenu;
          postPatch = ''
            ${old.postPatch or ""}
            sed -ri -e 's!\<(dmenu|dmenu_path_desktop|stest)\>!'"$out/bin"'/&!g' dmenu_run_desktop
            sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path_desktop
          '';
        });
        dwm = super.dwm.overrideAttrs (old: {
          buildInputs = old.buildInputs ++ [ super.yajl ];
          src = super.fetchFromGitHub {
            owner = "Vali0004";
            repo = "dwm-fork";
            rev = "cd7c67e75dd782c46c38dee38722ea64abe6d463";
            hash = "sha256-Ij52wdZznFQSaCA2UoqZxLVn2BkBLqtoNS1EKEcQphg=";
          };
        });
        dwmblocks = super.dwmblocks.overrideAttrs (old: {
          src = super.fetchFromGitHub {
            owner = "nimaaskarian";
            repo = "dwmblocks-statuscmd-multithread";
            rev = "6700e322431b99ffc9a74b311610ecc0bc5b460a";
            hash = "sha256-TfPomjT/Z4Ypzl5P5VcVccmPaY8yosJmMLHrGBA6Ycg=";
          };
        });
        xwinwrap = super.xwinwrap.overrideDerivation (old: {
          version = "v0.9";
          src = super.fetchFromGitHub {
            owner = "Vali0004";
            repo = "xwinwrap";
            rev = "373426eb95ca62dedad3d77833ccf649f98f489b";
            hash = "sha256-przCOyureolbPLqy80DuyQoGeQ7lbGIXeR1z26DvN/E=";
          };
        });
      })
      # Custom pkgs
      (self: super: {
        beammp-launcher = pkgs.callPackage ./beammp-launcher {};
        clipmenu-paste = pkgs.callPackage ./clipmenu { dmenu = self.dmenu; };
        darling = pkgs.callPackage ./darling {};
        dnspy = pkgs.callPackage ./dnspy {};
        dwmblocks-battery = pkgs.callPackage ./dwmblocks/battery {};
        dwmblocks-cpu = pkgs.callPackage ./dwmblocks/cpu {};
        dwmblocks-memory = pkgs.callPackage ./dwmblocks/memory {};
        dwmblocks-network = pkgs.callPackage ./dwmblocks/network {};
        dwmblocks-playerctl = pkgs.callPackage ./dwmblocks/playerctl {};
        ida-pro = pkgs.callPackage ./ida-pro {};
        jlink = pkgs.callPackage ./nordic/jlink {};
        manage-gnome-calculator = pkgs.callPackage ./manage-gnome-calculator {};
        nrf-studio = pkgs.callPackage ./nordic {};
        nrf-util = pkgs.callPackage ./nordic/nrfutil {};
        fastfetch-simple = pkgs.writeScriptBin "fastfetch-simple" ''
          ${pkgs.fastfetch}/bin/fastfetch --config /home/vali/.config/fastfetch/simple.jsonc
        '';
        flameshot-upload = pkgs.writeScriptBin "flameshot_fuckk_lol" ''
          ${pkgs.flameshot}/bin/flameshot gui --accept-on-select -r > /tmp/screenshot.png
          ${pkgs.curl}/bin/curl -H "authorization: ${config.secrets.zipline.authorization}" https://holy.fuckk.lol/api/upload -F file=@/tmp/screenshot.png -H 'content-type: multipart/form-data' | ${pkgs.jq}/bin/jq -r .files[0].url | tr -d '\n' | ${pkgs.xclip}/bin/xclip -selection clipboard
        '';
        xwinwrap-gif = pkgs.callPackage ./xwinwrap {};
      })
    ] ++ lib.optionals config.hasNixGaming [
      (self: super: {
        nixGaming = nixGamingFlake.outputs.packages.x86_64-linux;

        osu-base = pkgs.callPackage ./osu {
          osu-mime = self.nixGaming.osu-mime;
          wine-discord-ipc-bridge = self.nixGaming.wine-discord-ipc-bridge;
          proton-osu-bin = self.nixGaming.proton-osu-bin;
        };
        osu-stable = self.osu-base;
        osu-gatari = self.osu-base.override {
          desktopName = "osu!gatari";
          pname = "osu-gatari";
          launchArgs = "-devserver gatari.pw";
        };
      })
    ];
  };
}