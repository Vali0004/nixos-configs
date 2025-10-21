{ pkgs, ... }:

let
  sddm-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
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

  services.xserver.displayManager.setupCommands = ''
    sleep 5
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1440 --rate 120 --primary --right-of DP-1 --rotate normal
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-1 --left-of DP-2 --mode 1920x1080 --rate 60 --rotate normal
  '';
}
