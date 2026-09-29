{ lib
, ... }:

{
  services.openssh.enable = true;
  services.openssh.settings = {
    AcceptEnv = lib.mkForce [ "LANG" "LC_*" ];
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
    X11Forwarding = true;
  };
}
