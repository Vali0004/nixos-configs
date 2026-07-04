{
  services.udev.extraRules = ''
    # Aula, SayoDevice O3C
    SUBSYSTEM=="usb", ATTRS{idVendor}=="8089", GROUP="wheel", MODE="0677"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e3c", GROUP="wheel", MODE="0677"
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