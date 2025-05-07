{ config, lib, ... }:

let
  i3Config = import ./../../i3config.nix;
in {
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
          "DejaVu Sans Mono:size=12"
        ];
        foreground = i3Config.barForeground;
        line-size = "4pt";
        module-margin = 1;
        modules = {
          left = "xworkspaces xwindow";
          right = "cpu ram swap eth filesystem xkeyboard date pulseaudio systray";
        };
        padding = {
          left = 0;
          right = 0;
        };
        height = "24pt";
        radius = 8;
        separator = {
          text = "|";
          foreground = i3Config.barSecondary;
        };
        width = "100%";
        wm-restack = "i3";
      };
      "module/cpu" = {
        format.prefix = {
          text = "CPU ";
          foreground = i3Config.barPrimary;
        };
        interval = 2;
        label = "%percentage%%";
        type = "internal/cpu";
      };
      "module/date" = {
        date = "%Y-%m-%d%";
        interval = 1;
        label = "%time%";
        label-foreground = i3Config.barPrimary;
        time = "%H:%M:%S";
        type = "internal/date";
      };
      "module/eth" = {
        "inherit" = "network-base";
        interface.type = "wired";
        label.connected = "%{F${i3Config.barPrimary}}ETH%{F-} %local_ip%";
        label.disconnected = "%{F${i3Config.barPrimary}}ETH%{F${i3Config.barDisabled}} disconnected";
      };
      "module/filesystem" = {
        interval = 25;
        label = {
          mounted = {
            text = "%{F${i3Config.barPrimary}}%mountpoint%%{F-} %used%/%total% (%{F${i3Config.barPrimary}}%percentage_used%%%{F-})";
          };
          unmounted = {
            text = "%mountpoint% not mounted";
            foreground = i3Config.barDisabled;
          };
        };
        mount = [ "/" ];
        type = "internal/fs";
      };
      "module/pulseaudio" = {
        click.right = "pavucontrol &";
        #format = {
        #  prefix = {
        #    text = "VOL ";
        #    foreground = i3Config.barPrimary;
        #  };
        #  text = "<label-volume>";
        #};
        #label.muted = {
        #  text = "muted";
        #  foreground = i3Config.barDisabled;
        #};
        interval = 5;
        reverse-scroll = false;
        type = "internal/pulseaudio";
        use-ui-max = true;
      };
      "module/ram" = {
        format.prefix = {
          text = "RAM ";
          foreground = i3Config.barPrimary;
        };
        interval = 1;
        label = {
          text = "%gb_used%%{F${i3Config.barPrimary}}/%{F-}%gb_total% (%{F${i3Config.barPrimary}}%percentage_used%%%{F-})";
        };
        type = "internal/memory";
      };
      "module/swap" = {
        format.prefix = {
          text = "";
          foreground = i3Config.barPrimary;
        };
        interval = 3;
        label = {
          text = "%gb_swap_used%%{F${i3Config.barPrimary}}/%{F-}%gb_swap_total% (%{F${i3Config.barPrimary}}%percentage_swap_used%%%{F-})";
        };
        type = "internal/memory";
      };
      "module/systray" = {
        format.margin = "8pt";
        tray.spacing = "16pt";
        type = "internal/tray";
      };
      "module/xkeyboard" = {
        blacklist = [ "num lock" ];
        label = {
          indicator = {
            background = i3Config.barSecondary;
            foreground = i3Config.barBackground;
            margin = 1;
            padding = 2;
          };
          layout.text = "%layout%";
          layout.foreground = i3Config.barPrimary;
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