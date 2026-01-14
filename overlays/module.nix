{ config
, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    # Required for agenix
    "libxml2-2.13.8"
    # Required for jellyfin-media-player
    "qtwebengine-5.15.19"
    "python3.13-ecdsa-0.19.1"
  ];

  nixpkgs.overlays = [
    (import ./customPackages.nix)
    (import ./existingPackages.nix)
    (self: super: {
      fastfetch-simple = self.writeScriptBin "fastfetch-simple" ''
        ${self.fastfetch}/bin/fastfetch --config /home/vali/.config/fastfetch/simple.jsonc
      '';
      flameshot-upload = self.writeScriptBin "flameshot-upload" ''
        set -euo pipefail

        tmp="$(mktemp --suffix=.png)"
        trap 'rm -f "$tmp"' EXIT

        ${self.flameshot}/bin/flameshot gui --accept-on-select -r > "$tmp"

        resp="$(${self.curl}/bin/curl -sS --fail-with-body \
          -H "@/run/agenix/zipline-upload-headers" \
          -H "x-zipline-domain: furryfemboy.ca" \
          -F "file=@$tmp" \
          "https://holy.fuckk.lol/api/upload")"

        url="$(printf '%s' "$resp" | ${self.jq}/bin/jq -er '.files[0].url')"

        printf '%s' "$url" | ${self.xclip}/bin/xclip -selection clipboard
      '';
    })
  ];
}