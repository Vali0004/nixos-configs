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
    ${pkgs.xorg.xrandr}/bin/xrandr --newmode "2560x1440_240.00" 1442.50 2560 2800 3088 3616 1440 1443 1448 1663 -hsync +vsync
    ${pkgs.xorg.xrandr}/bin/xrandr --addmode DP-2 "2560x1440_240.00"
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode "2560x1440_240.00" --primary --right-of DP-3 --rotate normal
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-3 --left-of DP-2 --rotate normal
    ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-1 --mode 1920x1080 --pos 4480x0 --rate 75
  '';
}