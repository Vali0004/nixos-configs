{
  services.openssh.enable = true;
  # We don't need most methods, as we force ssh keys.
  # Disable expensive modules
  services.openssh.settings = {
    ChallengeResponseAuthentication = false;
    GSSAPIAuthentication = false;
    KbdInteractiveAuthentication = false;
    # I'd still like the last login, even if it adds a small cost
    PrintMotd = true;
    PrintLastLog = false;
    PasswordAuthentication = false;
    TCPKeepAlive = true;
    UseDns = false;
    UsePAM = false;
  };
}