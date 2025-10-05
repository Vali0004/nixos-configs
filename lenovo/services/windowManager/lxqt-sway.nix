{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # LXQt uses this for it's terminal in some cases, and this is as a fallback.
    # It will be forced out at some point
    xterm
  ] ++ pkgs.lxqt.preRequisitePackages
    ++ pkgs.lxqt.corePackages
    ++ (utils.removePackagesByName pkgs.lxqt.optionalPackages (with pkgs; with pkgs.lxqt; [
      compton-conf
      lximage-qt
      lxqt-archiver
      obconf-qt
      qps
      qterminal
      screengrab
      xscreensaver
    ]));

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };

  environment.etc."lxqt/session.conf".text = ''
    [General]
    leave_confirmation=true
    compositor=sway
    lock_command_wayland=swaylock
  '';

  # Link some extra directories in /run/current-system/software/share
  environment.pathsToLink = [ "/share" "${pkgs.lxqt.lxqt-wayland-session}/share" ];

  systemd.tmpfiles.rules = [
    "L+ /home/vali/.config/lxqt/session.conf - - - - /etc/lxqt/session.conf"
  ];

  programs = {
    gnupg.agent.pinentryPackage = pkgs.pinentry-qt;
    sway = {
      enable = true;
      package = pkgs.swayfx;
      extraPackages = with pkgs; [
        swayidle
        swaylock
        # D(ynamic)Menu for Wayland
        wmenu
      ];
      xwayland.enable = true;
    };
    xwayland.enable = true;
  };

  security = {
    pam.services.swaylock = { };
    polkit.enable = true;
  };

  services = {
    displayManager = {
      # Set what the greeter defaults to
      defaultSession = "lxqt-wayland";
      sessionPackages = [ pkgs.lxqt.lxqt-wayland-session ];
    };
    # Enable libinput
    libinput.enable = true;
    # Window manager only sessions (unlike DEs) don't handle XDG
    # autostart files, so force them to run the service
    xserver.desktopManager.runXdgAutostartIfNone = true;
  };

  xdg.portal.lxqt.enable = true;
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1050804
  xdg.portal.config.lxqt.default = [
    "lxqt"
    "gtk"
  ];
}