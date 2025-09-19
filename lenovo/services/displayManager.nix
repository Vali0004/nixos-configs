{ config, lib, pkgs, ... }:

let
  sddm-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
  };
in {
  services.xserver.displayManager = {
    lightdm.enable = false;
  };
  environment.systemPackages = [ sddm-theme ];
  services.displayManager = {
    sddm = {
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
  };
}
