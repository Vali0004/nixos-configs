{ ... }:

{
  home = {
    file.".config/fastfetch/simple.jsonc".source = ./fastfetch-simple.jsonc;
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "auto";
      };
      display = {
        constants = [
          "───────────────"
        ];
        key = {
          type = "icon";
          paddingLeft = 2;
        };
        separator = " → ";
      };
      modules = [
        {
          type = "custom"; # Hardware start
          # {#1} is equivalent to `\u001b[1m`. {#} is equivalent to `\u001b[m`
          format = "┌{$1} {#1}Hardware Information{#} {$1}┐";
        }
        "host"
        "cpu"
        "gpu"
        "disk"
        "memory"
        {
          type = "custom"; # SoftwareStart
          format = "├{$1} {#1}Software Information{#} {$1}┤";
        }
        "os"
        "kernel"
        "uptime"
        "wm"
        "shell"
        "terminal"
        "theme"
        "packages"
        {
          type = "custom"; # SoftwareEnd
          format = "└{$1}{#1}──────────────────────{#}{$1}┘";
        }
        {
          type = "colors";
          paddingLeft = 2;
          symbol = "circle";
        }
      ];
    };
  };
}