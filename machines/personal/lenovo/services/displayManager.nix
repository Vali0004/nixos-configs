{ pkgs
, ... }:

let
  sddm-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
  };
in {
  environment.systemPackages = [ sddm-theme ];

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