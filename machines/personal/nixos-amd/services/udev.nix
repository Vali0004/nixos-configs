{ pkgs
, ... }:

let
  cp5-pedals = pkgs.writeScriptBin "cp5-pedals" ''
    ${pkgs.linuxConsoleTools}/bin/evdev-joystick --e /dev/input/by-id/usb-CAMMUS006_CAMMUS_CP5_PEDALS_4975237D3448-event-if00 --d 0 --minimum 0 --maximum 4095 --axis 1
    ${pkgs.linuxConsoleTools}/bin/evdev-joystick --e /dev/input/by-id/usb-CAMMUS006_CAMMUS_CP5_PEDALS_4975237D3448-event-if00 --d 0 --minimum 0 --maximum 2930 --axis 2
  '';
in {
  services.udev.extraRules = ''
    # Aula, SayoDevice O3C
    SUBSYSTEM=="usb", ATTRS{idVendor}=="8089", GROUP="wheel", MODE="0677"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", GROUP="wheel", MODE="0677"
    # Cammus C5
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3416", ATTRS{idProduct}=="1018", MODE="0666", ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_CLASS}="joystick", TAG+="uaccess"
    SUBSYSTEM=="input", ATTRS{idVendor}=="3416", ATTRS{idProduct}=="1018", MODE="0666", ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_CLASS}="joystick", TAG+="uaccess"
    SUBSYSTEM=="event", ATTRS{idVendor}=="3416", ATTRS{idProduct}=="1018", MODE="0666", ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_CLASS}="joystick", TAG+="uaccess"
    SUBSYSTEM=="js", ATTRS{idVendor}=="3416", ATTRS{idProduct}=="1018", MODE="0666", ENV{ID_INPUT_JOYSTICK}="1", ENV{ID_CLASS}="joystick", TAG+="uaccess"
    ACTION=="add", ENV{ID_VENDOR_ID}=="3416", ENV{ID_MODEL_ID}=="1018", RUN+="${cp5-pedals}/bin/cp5-pedals"
    # Elgato
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", GROUP="wheel", MODE="0677"
    # HTC
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bb4", GROUP="wheel", MODE="0666"
    # Oculus
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2833", GROUP="wheel", MODE="0666"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="2833", GROUP="wheel", MODE="0666"
    # SlimeVR
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", GROUP="wheel", MODE="0666"
    # Sony - 054c:0fa8
    SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", GROUP="wheel", MODE="0666"
    # Steam
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", GROUP="wheel", MODE="0666"
    # Razer
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1532", GROUP="wheel", MODE="0666"
    # RedOctane
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1430", TAG+="uaccess", MODE="0666", GROUP="wheel"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1430", TAG+="uaccess", MODE="0666", GROUP="wheel"
    # Espressif
    SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", GROUP="wheel", MODE="0666"
    # RockChip
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2207", GROUP="wheel", MODE="0666"
    # Sigrok (OpenMoto Fx2lafw)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d50", GROUP="wheel", MODE="0666"
    # Set /dev/bus/usb/*/* as read-write for the wheel group (0666) for Nordic Semiconductor devices
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1915", MODE="0666"
    # Set /dev/bus/usb/*/* as read-write for the wheel group (0666) for WCH-CN devices
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1d6b", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1209", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0bda", MODE="0666"
    # USB CDC ACM for Nordic + Espressif
    KERNEL=="ttyACM[0-9]*", SUBSYSTEM=="usb", ATTRS{idVendor}=="1915|303a", MODE="0666", ENV{CDC_ACM}="1"
    KERNEL=="ttyACM[0-9]*", SUBSYSTEM=="tty", ATTRS{idVendor}=="1915|303a", MODE="0666", ENV{CDC_ACM}="1"
    ENV{CDC_ACM}=="1", ENV{ID_MM_CANDIDATE}="0", ENV{ID_MM_DEVICE_IGNORE}="1"
  '';
}