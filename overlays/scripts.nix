self: super: {
  fastfetch-simple = self.writeScriptBin "fastfetch-simple" ''
    ${self.fastfetch}/bin/fastfetch --config /home/vali/.config/fastfetch/simple.jsonc
  '';
  flameshot-upload = self.writeScriptBin "flameshot-upload" ''
    ${self.flameshot}/bin/flameshot gui --accept-on-select -r > /tmp/screenshot.png
    ${self.curl}/bin/curl -H "$(${self.coreutils}/bin/cat /run/agenix/zipline-upload-headers)" https://holy.fuckk.lol/api/upload -F file=@/tmp/screenshot.png -H 'content-type: multipart/form-data' | ${self.jq}/bin/jq -r .files[0url | tr -d '\n' | ${self.xclip}/bin/xclip -selection clipboard
  '';
}