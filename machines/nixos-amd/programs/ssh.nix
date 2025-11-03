{
  programs.gnupg.agent = {
    enable = true;
    enableBrowserSocket = true;
    enableExtraSocket = true;
    enableSSHSupport = true;
  };

  programs.ssh.extraConfig = ''
    include config.d/*

    IdentityFile /home/vali/.ssh/nixos_main
    IdentityFile /home/vali/.ssh/test_ppk
  '';
}