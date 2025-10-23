{
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
    KbdInteractiveAuthentication = false;
    PasswordAuthentication = false;
  };
}