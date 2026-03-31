{
  services.udev = {
    enable = true;
    extraRules = ''
      # Serial converted (Zigbee)
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", GROUP="plugdev", MODE="0677"
    '';
  };

  users.groups.plugdev = {};
}