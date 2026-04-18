{ pkgs
, ... }:

let
  sddm-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
  };
in {
  environment.systemPackages = [ sddm-theme ];

  # Use amdgpu TearFree & VRR
  environment.etc."/etc/X11/xorg.conf.d/20-amdgpu.conf".text = ''
    Section "Device"
        Identifier "AMD"
        Driver "amdgpu"
        Option "TearFree" "true"
        Option "VariableRefresh" "true"
    EndSection
  '';

  services.xserver.displayManager.lightdm.enable = false;
  services.displayManager.sddm = {
    enable = true;
    extraPackages = with pkgs.kdePackages; [
      sddm-theme
      sddm-kcm
      qtsvg
      qtmultimedia
      qtvirtualkeyboard
    ];
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    wayland.enable = false;
  };
}