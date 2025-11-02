{ lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        ipc = false;
        exclusive = true;
        gtk-layer-shell  = true;
        layer = "top";
        position = "top";
        mode = "dock";
        height = 22;
        spacing = 0;
        margin-top = 0;
        margin-bottom = 0;

        modules-left = [
          "dwl/tags"
          "wlr/taskbar"
          "dwl/window"
        ];

        modules-right = [
          "custom/memory"
          "custom/separator1"
          "cpu"
          "custom/separator2"
          "temperature"
          "custom/separator3"
          "custom/network"
          "custom/separator4"
          "pulseaudio"
          "custom/separator5"
          "custom/playerctl"
          "custom/separator6"
          "clock"
          "tray"
        ];

        "dwl/tags" = {
          num-tags = 9;
          hide-vacant = true;
        };

        "wlr/taskbar" = {
          format = "{icon}";
          icon-size = 13;
          all-outputs = false;
          markup = true;
          on-click = "activate";
          on-click-right = "close";
          ignore-list = [
            "Rofi"
            "wofi"
          ];
        };

        "dwl/window".format = "{}";

        "custom/memory" = {
          format = " {output}";
          tooltip = false;
          interval = 30;
          exec = "${pkgs.procps}/bin/free -h | ${pkgs.gawk}/bin/awk '/Mem:/ {print $3}'";
        };

        "cpu" = {
          interval = 2;
          format = " {load}%";
        };

        "temperature" = {
          thermal-zone = 2;
          hwmon-path = "/sys/class/hwmon/hwmon1/temp1_input";
          critical-threshold = 10;
          format-critical = " {temperatureC}°C";
          format = "";
        };

        "custom/network" = {
          format = "󰈀 {output}";
          tooltip = false;
          interval = 5;
          exec = "${pkgs.iptables}/bin/ip -brief addr show dev $(${pkgs.iptables}/bin/ip route get 1 | ${pkgs.gawk}/bin/awk '{print $5; exit}') | ${pkgs.gawk}/bin/awk '{print $3}' | ${pkgs.coreutils}/bin/cut -d/ -f1)";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          tooltip = false;
          format-muted = " Muted";
          on-click = "pamixer -t";
          on-scroll-up = "pamixer -i 2";
          on-scroll-down = "pamixer -d 2";
          scroll-step = 5;
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
        };
        "custom/playerctl" = {
          format = "{icon} {output}";
          return-type = "json";
          exec = ''
            ${pkgs.playerctl}/bin/playerctl -p spotify metadata -F -f \
            '{"text":"{{markup_escape(title)}} - {{markup_escape(artist)}}","alt":"{{status}}"}'
          '';
          tooltip = false;
          on-click-middle = "${pkgs.playerctl}/bin/playerctl -p spotify previous";
          on-click = "${pkgs.playerctl}/bin/playerctl -p spotify play-pause";
          on-click-right = "${pkgs.playerctl}/bin/playerctl -p spotify next";
          on-scroll-up = "${pkgs.playerctl}/bin/playerctl -p spotify position 10+";
          on-scroll-down = "${pkgs.playerctl}/bin/playerctl -p spotify position 10-";
          format-icons = {
            Paused = "";
            Playing = "";
          };
        };

        "clock" = {
          format = "{:%b %d (%a) %I:%M:%S %p}";
          tooltip = false;
          interval = 1;
        };

        "tray".spacing = 6;

        "custom/separator1" = { format = ""; interval = "once"; tooltip = false; };
        "custom/separator2" = { format = ""; interval = "once"; tooltip = false; };
        "custom/separator3" = { format = ""; interval = "once"; tooltip = false; };
        "custom/separator4" = { format = ""; interval = "once"; tooltip = false; };
        "custom/separator5" = { format = ""; interval = "once"; tooltip = false; };
        "custom/separator6" = { format = ""; interval = "once"; tooltip = false; };
      };
    };

    style = pkgs.writeText "waybar-style.css" ''
      * {
        border: none;
        border-radius: 0;
        font-family: "RobotoMono Nerd Font";
        font-size: 13px;
        font-weight: 500;
      }

      window#waybar {
        background-color: 0F0F0F;
        color: #cdd6f4;
        border-bottom: 1px solid #0F0F0F;
      }

      #tags {
        margin-left: 4px;
        padding: 0 8px;
        background: rgba(40, 40, 40, 0.7);
        border-radius: 4px;
      }

      #tags button {
        border: none;
        background: none;
        color: #642cff;
        margin: 0 2px;
      }

      #tags button.focused {
        background-color: #642cff;
        color: #0F0F0F;
        border-radius: 3px;
        padding: 0 1px;
      }

      #tags button.occupied { color: #642cff; }
      #tags button.urgent { color: #ef5e5e; }
      #tags button:hover { color: #d79921; }

      #tray {
        margin-left: 2px;
        margin-right: 2px;
      }

      #custom-memory { color: #89b4fa; padding: 0 6px; }
      #cpu { color: #a6e3a1; padding: 0 6px; }
      #temperature { color: #a6e3a1; padding: 0 6px; }
      #custom-network { color: #94e2d5; padding: 0 6px; }
      #pulseaudio { color: #f38ba8; padding: 0 6px; }
      #custom-playerctl { color: #94e2d5; padding: 0 6px; }
      #clock { color: #cdd6f4; padding: 0 6px; }

      #custom-separator1,
      #custom-separator2,
      #custom-separator3,
      #custom-separator4,
      #custom-separator5,
      #custom-separator6 {
        color: #FFFFFF;
        padding: 0 2px;
      }

      #custom-memory:hover,
      #cpu:hover,
      #temperature:hover,
      #custom-network:hover,
      #pulseaudio:hover,
      #custom-playerctl:hover,
      #clock:hover {
        background: #0F0F0F;
        border-radius: 4px;
        transition: background-color 0.2s ease-in-out;
      }

      tooltip {
        background: #0F0F0F;
        color: #cdd6f4;
        border-radius: 5px;
      }
    '';
  };
}