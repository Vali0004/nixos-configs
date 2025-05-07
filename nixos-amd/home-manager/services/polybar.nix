{ config, lib, pkgs, ... }:

let
  i3Config = import ./../../i3config.nix;
in {
  home.file.".config/polybar/pipewire.sh" = {
    source = pkgs.callPackage ./pipewire-polybar.nix {};
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
        background = i3Config.barBackground;
        background-alt = i3Config.barBackgroundAlt;
        foreground = i3Config.barForeground;
        primary = i3Config.barPrimary;
        secondary = i3Config.barSecondary;
        alert = i3Config.barAlert;
        disabled = i3Config.barDisabled;
      };
      "bar/bar" = {
        background = i3Config.barBackground;
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
        foreground = i3Config.barForeground;
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
          foreground = i3Config.barSecondary;
          text = "|";
        };
        width = "100%";
        wm-restack = "i3";
      };
      "module/cpu" = {
        format.prefix = {
          foreground = i3Config.barPrimary;
          padding = 1;
          text = " ";
        };
        interval = 2;
        label = "%percentage%%";
        type = "internal/cpu";
      };
      "module/date" = {
        date = "%Y-%m-%d%";
        interval = 0;
        label = {
          text = "%time%";
          foreground = i3Config.barPrimary;
        };
        time = "%H:%M:%S";
        type = "internal/date";
      };
      "module/eth" = {
        "inherit" = "network-base";
        interface.type = "wired";
        label.connected = "%{F${i3Config.barPrimary}}󰈀%{F-} %local_ip%";
        label.disconnected = "%{F${i3Config.barPrimary}}󰈀%{F${i3Config.barDisabled}} disconnected";
      };
      "module/filesystem" = {
        interval = 25;
        label = {
          mounted = {
            text = "%{F${i3Config.barPrimary}}󰋊%{F-} %free%";
          };
          unmounted = {
            text = "%mountpoint% not mounted";
            foreground = i3Config.barDisabled;
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
          text = "%{F${i3Config.barPrimary}}%{F-} %{F${i3Config.barSecondary}}%output%%{F-}";
        };
        type = "custom/script";
      };
      "module/ram" = {
        format.prefix = {
          text = "  ";
          foreground = i3Config.barPrimary;
        };
        interval = 1;
        label = {
          text = "%gb_used% (%{F${i3Config.barPrimary}}%percentage_used%%%{F-})";
        };
        type = "internal/memory";
      };
      "module/swap" = {
        format.prefix = {
          text = " ";
          foreground = i3Config.barPrimary;
        };
        interval = 3;
        label = {
          text = "%gb_swap_used% (%{F${i3Config.barPrimary}}%percentage_swap_used%%%{F-})";
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
          text = "%{F${i3Config.barPrimary}}󰌌%{F-} <label-layout> <label-indicator>";
        };
        label = {
          font = 1;
          indicator = {
            background = i3Config.barSecondary;
            foreground = i3Config.barBackground;
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
            background = i3Config.barBackgroundAlt;
            underline = i3Config.barPrimary;
            padding = 1;
          };
          occupied = {
            text = "%name%";
            padding = 1;
          };
          urgent = {
            text = "%name%";
            background = i3Config.barAlert;
            padding = 1;
          };
          empty = {
            text = "%name%";
            foreground = i3Config.barDisabled;
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
        label.disconnected = "%{F${i3Config.barPrimary}}%ifname%%{F${i3Config.barDisabled}} disconnected";
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
