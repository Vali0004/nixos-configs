{ config, lib, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    plugins = [
      {
        # Sets the nix-shell to use zsh instead of bash
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }
      {
        # Better host completion for ssh in Zsh
        name = "zsh-ssh";
        file = "zsh-ssh.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "sunlei";
          repo = "zsh-ssh";
          rev = "f73b78bc8f0b40dc939e2819348b83afada09ba9";
          sha256 = "jFcSIv4T1ZNBOujGZ2NLp6Ou3aDrXT76cR9bVbMMJhM=";
        };
      }
    ];
  };
}
