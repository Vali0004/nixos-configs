{ lib
, ... }:

{
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    KbdInteractiveAuthentication = false;
    PasswordAuthentication = false;
    AcceptEnv = lib.mkForce [ "LANG" "LC_*" ];
  };
}