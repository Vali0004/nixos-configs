{ config, lib, pkgs, ... }:

let
  barConfig = import ./../../barconfig.nix;
in {
  home.file.".config/polybar/pipewire.sh" = {
    source = pkgs.callPackage ./pipewire-polybar.nix {
      barConfig = import ./../../barconfig.nix;
    };
    executable = true;
  };
  home.file.".config/polybar/playerctl.sh" = {
    source = pkgs.callPackage ./playerctl-polybar.nix {};
    executable = true;
  };
  services.polybar = {
    enable = true;
    script = "polybar bar &";
    settings = {
      "colors" = {
        background = barConfig.barBackground;
        background-alt = barConfig.barBackgroundAlt;
        foreground = barConfig.barForeground;
        primary = barConfig.barPrimary;
        secondary = barConfig.barSecondary;
        alert = barConfig.barAlert;
        disabled = barConfig.barDisabled;
      };
      "bar/bar" = {
        background = barConfig.barBackground;
        border = {
          size = "4pt";
          color = "#00000000";
        };
        cursor = {
          click = "pointer";
          scroll = "ns-resize";
        };
        enable-ipc = true;
        font = [
          "DejaVuSansM Nerd Font:size=10;2"
          "DejaVuSansM Nerd Font:size=12;2"
        ];
        foreground = barConfig.barForeground;
        line-size = "4pt";
        module-margin = 1;
        modules = {
          left = "xworkspaces xwindow";
          center = "xkeyboard";
          right = "cpu ram eth filesystem playerctl pipewire-output date systray";
        };
        padding = {
          left = 0;
          right = 0;
        };
        height = "24pt";
        radius = 8;
        separator = {
          foreground = barConfig.barSecondary;
          text = "|";
        };
        width = "100%";
        wm-restack = "i3";
      };
      "module/cpu" = {
        format.prefix = {
          foreground = barConfig.barPrimary;
          padding = 1;
          text = " ";
        };
        interval = 2;
        label = "%percentage%%";
        type = "internal/cpu";
      };
      "module/date" = {
        date = "%Y-%m-%d%";
        interval = 1;
        label = {
          text = "%time%";
          foreground = barConfig.barPrimary;
        };
        time = "%H:%M:%S";
        type = "internal/date";
      };
      "module/eth" = {
        "inherit" = "network-base";
        interface.text = "bond0";
        interface.type = "wired";
        label.connected = "%{F${barConfig.barPrimary}}󰈀%{F-} %local_ip%";
        label.disconnected = "%{F${barConfig.barPrimary}}󰈀%{F${barConfig.barDisabled}} disconnected";
      };
      "module/filesystem" = {
        interval = 25;
        label = {
          mounted = {
            text = "%{F${barConfig.barPrimary}}󰋊%{F-} %free%";
          };
          unmounted = {
            text = "%mountpoint% not mounted";
            foreground = barConfig.barDisabled;
          };
        };
        mount = [ "/" ];
        type = "internal/fs";
      };
      "module/pipewire-input" = {
        click.right = "exec ${pkgs.pavucontrol}/bin/pavucontrol &";
        click.left = "~/.config/polybar/pipewire.sh output mute &";
        scroll.up = "~/.config/polybar/pipewire.sh output up &";
        scroll.down = "~/.config/polybar/pipewire.sh output down &";
        exec = "~/.config/polybar/pipewire.sh input";
        interval = 0;
        label = {
          text = "%output%";
        };
        type = "custom/script";
      };
      "module/pipewire-output" = {
        click.right = "exec ${pkgs.pavucontrol}/bin/pavucontrol &";
        click.left = "~/.config/polybar/pipewire.sh input mute &";
        scroll.up = "~/.config/polybar/pipewire.sh input up &";
        scroll.down = "~/.config/polybar/pipewire.sh input down &";
        exec = "~/.config/polybar/pipewire.sh output";
        interval = 0;
        label = {
          text = "%output%";
        };
        type = "custom/script";
      };
      "module/playerctl" = {
        click.right = "exec ${pkgs.playerctl}/bin/playerctl previous &";
        click.left = "exec ${pkgs.playerctl}/bin/playerctl next &";
        click.middle = "exec ${pkgs.playerctl}/bin/playerctl play-pause &";
        exec = "~/.config/polybar/playerctl.sh";
        interval = 1;
        label = {
          text = "%{F${barConfig.barPrimary}}%{F-} %{F${barConfig.barSecondary}}%output%%{F-}";
        };
        type = "custom/script";
      };
      "module/ram" = {
        format.prefix = {
          text = "  ";
          foreground = barConfig.barPrimary;
        };
        interval = 1;
        label = {
          text = "%gb_used% (%{F${barConfig.barPrimary}}%percentage_used%%%{F-})";
        };
        type = "internal/memory";
      };
      "module/swap" = {
        format.prefix = {
          text = " ";
          foreground = barConfig.barPrimary;
        };
        interval = 3;
        label = {
          text = "%gb_swap_used% (%{F${barConfig.barPrimary}}%percentage_swap_used%%%{F-})";
        };
        type = "internal/memory";
      };
      "module/systray" = {
        format.margin = "4pt";
        tray.spacing = "8pt";
        type = "internal/tray";
      };
      "module/xkeyboard" = {
        blacklist = [ "num lock" ];
        format = {
          text = "%{F${barConfig.barPrimary}}󰌌%{F-} <label-layout> <label-indicator>";
        };
        label = {
          font = 1;
          indicator = {
            background = barConfig.barSecondary;
            foreground = barConfig.barBackground;
            margin = 1;
            padding = 2;
          };
          layout.text = "%layout%";
        };
        type = "internal/xkeyboard";
      };
      "module/xworkspaces" = {
        type = "internal/xworkspaces";
        label = {
          active = {
            text = "%name%";
            background = barConfig.barBackgroundAlt;
            underline = barConfig.barPrimary;
            padding = 1;
          };
          occupied = {
            text = "%name%";
            padding = 1;
          };
          urgent = {
            text = "%name%";
            background = barConfig.barAlert;
            padding = 1;
          };
          empty = {
            text = "%name%";
            foreground = barConfig.barDisabled;
            padding = 1;
          };
        };
      };
      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:70:...%";
      };
      "network-base" = {
        format = {
          connected.text = "<label-connected>";
          disconnected.text = "<label-disconnected>";
        };
        label.disconnected = "%{F${barConfig.barPrimary}}%ifname%%{F${barConfig.barDisabled}} disconnected";
        type = "internal/network";
      };
      "settings" = {
        screenchange-reload = true;
        pseudo-transparency = true;
      };
    };
  };

  systemd.user.services.polybar = {
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
