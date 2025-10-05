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
    panels=panel1

    [backlight]
    alignment=Right
    type=backlight

    [customcommand]
    alignment=Right
    click="notify-send -a \"Numlock Indicator\" \"input3 can be different on your system, configure or remove this widget\""
    command="if [ \"$(cat /sys/class/leds/input3\\:\\:numlock/brightness)\" == \"0\" ]; then echo ' ';else echo 'N';fi\n"
    font="DejaVu Sans Mono,14,-1,5,75,0,0,0,0,0,Bold"
    maxWidth=20
    repeatTimer=1
    type=customcommand

    [customcommand1]
    alignment=Right
    autoRotate=false
    click="notify-send -a \"Capslock Indicator\" \"input3 can be different on your system, configure or remove this widget\""
    command="if [ \"$(cat /sys/class/leds/input3\\:\\:capslock/brightness)\" == \"0\" ]; then echo ' ';else echo 'C';fi\n"
    font="DejaVu Sans Mono,14,-1,5,75,0,0,0,0,0,Bold"
    maxWidth=20
    repeatTimer=1
    type=customcommand

    [mainmenu]
    alignment=Left
    filterClear=true
    showText=true
    text=LXQt
    type=mainmenu

    [mount]
    alignment=Right
    type=mount

    [panel1]
    alignment=0
    animation-duration=0
    background-color=@Variant(\0\0\0\x43\0\xff\xff\0\0\0\0\0\0\0\0)
    background-image=
    desktop=0
    font-color=@Variant(\0\0\0\x43\0\xff\xff\0\0\0\0\0\0\0\0)
    hidable=false
    hide-on-overlap=false
    iconSize=30
    lineCount=1
    lockPanel=false
    opacity=100
    panelSize=38
    plugins=mainmenu, quicklaunch, spacer, mount, statusnotifier, customcommand, customcommand1, backlight, volume, worldclock
    position=Top
    reserve-space=true
    show-delay=0
    visible-margin=true
    width=100
    width-percent=true

    [quicklaunch]
    alignment=Left
    type=quicklaunch

    [spacer]
    alignment=Left
    expandable=true
    spaceType=invisible
    type=spacer

    [statusnotifier]
    alignment=Left
    type=statusnotifier

    [volume]
    alignment=Right
    type=volume

    [worldclock]
    alignment=Right
    type=worldclock
  '';

  # Link some extra directories in /run/current-system/software/share
  environment.pathsToLink = [ "/share" "${pkgs.lxqt.lxqt-wayland-session}/share" ];

  systemd.tmpfiles.rules = [
    "L+ /home/vali/.config/lxqt/session.conf - - - - /etc/lxqt/session.conf"
    "L+ /home/vali/.config/lxqt/panel.conf - - - - /etc/lxqt/panel.conf"
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