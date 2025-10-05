{ pkgs, utils, ... }:

{
  environment.systemPackages = with pkgs; [
    lxqt.lxqt-wayland-session
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

  environment.etc."lxqt/panel.conf".text = ''
    [General]
    __userfile__=true
    iconTheme=oxygen
    panelSize=32
    fontColor=#000000
    panelTransparency=0
    alignment=Center
    length=100
    position=Top
    hidable=false
    animationDuration=0
    autoHide=false
    showDelay=0
    hideDelay=0
    panels=panel1

    [panel1]
    alignment=Center
    position=Top
    length=100
    size=32
    iconSize=22
    plugins=fancymenu,quicklaunch,taskbar,tray,statusnotifier,volume,worldclock

    [fancymenu]
    type=fancymenu
    alignment=Left
    filterClear=true
    autoSel=true
    autoSelDelay=150

    [quicklaunch]
    apps\1\desktop=/run/current-system/sw/share/applications/com.google.Chrome.desktop
    apps\42desktop=/run/current-system/sw/share/applications/Alacritty.desktop
    apps\2\desktop=/run/current-system/sw/share/applications/discord.desktop
    apps\4\desktop=/run/current-system/sw/share/applications/code.desktop
    apps\5\desktop=/run/current-system/sw/share/applications/nemo.desktop
    apps\size=5
    type=quicklaunch

    [taskbar]
    groupTasks=true
    showOnlyCurrentDesktop=false
    type=taskbar

    [tray]
    alignment=Right
    type=tray

    [statusnotifier]
    alignment=Right
    type=statusnotifier

    [volume]
    alignment=Right
    type=volume

    [worldclock]
    alignment=Right
    timeFormat=%R
    dateFormat=%x
    showDate=true
    fontColor=#ffffff
    type=worldclock
  '';

  # Link some extra directories in /run/current-system/software/share
  environment.pathsToLink = [ "/share" "${pkgs.lxqt.lxqt-wayland-session}/share" ];

  systemd.tmpfiles.rules = [
    "L+ /home/vali/.config/lxqt/session.conf             - - - - /etc/lxqt/session.conf"
    "L+ /home/vali/.config/lxqt/panel.conf               - - - - /etc/lxqt/panel.conf"
    "L+ /home/vali/.config/lxqt/power.conf               - - - - /run/current-system/sw/share/lxqt/power.conf"
    "L+ /home/vali/.config/lxqt/lxqt.conf                - - - - /run/current-system/sw/share/lxqt/lxqt.conf"
    "L+ /home/vali/.config/lxqt/graphics                 - - - - /run/current-system/sw/share/lxqt/graphics"
    "L+ /home/vali/.config/lxqt/icons                    - - - - /run/current-system/sw/share/lxqt/icons"
    "L+ /home/vali/.config/lxqt/translations             - - - - /run/current-system/sw/share/lxqt/translations"
    "L+ /home/vali/.config/lxqt/themes                   - - - - /run/current-system/sw/share/lxqt/themes"
    "L+ /home/vali/.config/lxqt/wallpapers               - - - - /run/current-system/sw/share/lxqt/wallpapers"
    "L+ /home/vali/.config/lxqt/wayland/lxqt-sway.config - - - - /home/vali/.config/sway/config"
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