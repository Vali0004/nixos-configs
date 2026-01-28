{ pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [ 8080 ];
    allowedUDPPorts = [ 8080 ];
  };

  services.xserver = {
    displayManager = {
      autoLogin.user = "kodi";
      lightdm.greeter.enable = false;
    };
    desktopManager = {
      kodi = {
        enable = true;
        package = (pkgs.kodi.withPackages (kodiPkgs: with kodiPkgs; [
          jellyfin
          inputstream-adaptive
        ]));
      };
    };
  };

  users.extraUsers.kodi.isNormalUser = true;
}