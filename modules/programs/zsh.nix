{ config, lib, pkgs, ... }:

{
  environment.shells = lib.mkIf config.programs.zsh.enable [
    pkgs.zsh
  ];

  programs.zsh = lib.mkIf config.programs.zsh.enable {
    autosuggestions.enable = false;
    enableBashCompletion = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
    };
    promptInit = ''
      autoload -U promptinit && promptinit
      autoload -U colors && colors
      for COLOR in RED GREEN YELLOW BLUE MAGENTA CYAN BLACK WHITE; do
          eval $COLOR='$fg_no_bold[''${(L)COLOR}]'
          eval BOLD_$COLOR='$fg_bold[''${(L)COLOR}]'
      done
      eval RESET='%{$reset_color%}'
      autoload -Uz vcs_info
      setopt prompt_subst

      # Git
      precmd() {
        psvar=()

        vcs_info
        [[ -n $vcs_info_msg_0_ ]] && print -v 'psvar[1]' -Pr -- "$vcs_info_msg_0_"
      }
      zstyle ':vcs_info:*' enable git svn
      zstyle ':vcs_info:*' formats ' (%s:\\\\%b)'

      # Prompt (Bash-like)
      PROMPT_COLOR="''${BOLD_GREEN}"
      (( UID )) || PROMPT_COLOR="''${BOLD_RED}"
      PROMPT="%{$PROMPT_COLOR%}[%n@%m:%~]%1v%(!.#.$)%f "
    '';
    shellInit = ''
      export SSH_CONFIG_FILE="/etc/ssh/ssh_config"
      export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:/home/vali/.local/share/flatpak/exports/share:$XDG_DATA_DIRS"
      export PATH=/home/vali/.local/bin:$PATH
      export PRIVATE_KEY=/home/vali/.ssh/nixos_main
    '';
    syntaxHighlighting.enable = true;
  };

  users.defaultUserShell = lib.mkIf config.programs.zsh.enable pkgs.zsh;
}