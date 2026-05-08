{
  programs.ssh.extraConfig = ''
    include config.d/*

    IdentityFile /home/vali/.ssh/nixos_main
  '';
}