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

  services.xserver = {
    enable = true;
    # Disable LightDM
    displayManager.lightdm.enable = false;
    # Disable XTerm
    excludePackages = [ pkgs.xterm ];
    desktopManager.xterm.enable = false;
  };

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
    ${pkgs.xrandr}/bin/xrandr --newmode "2560x1440_240.00" 1442.50 2560 2800 3088 3616 1440 1443 1448 1663 -hsync +vsync
    ${pkgs.xrandr}/bin/xrandr --addmode DP-6 "2560x1440_240.00"
    ${pkgs.xrandr}/bin/xrandr --output DP-6 --mode "2560x1440_240.00" --primary --right-of DP-7 --rotate normal
    ${pkgs.xrandr}/bin/xrandr --output DP-7 --left-of DP-6 --rotate normal
  '';
}