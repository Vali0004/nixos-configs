{ config, lib, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    extraConfig = {
	    disable-history = true;
      drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
      drun-url-launcher = "xdg-open";
      show-icons = true;
      window-format = "{w}    {c}   {t}";
    };
    location = "center";
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        accent-color = mkLiteral "#FEFEFE";
        background-color = mkLiteral "transparent";
        bg0 = mkLiteral "#252525";
        bg1 = mkLiteral "#202020";
        fg0 = mkLiteral "#FFFFFF";
        font = "FiraCode Nerd Font Medium 12";
        margin = 0;
        padding = 0;
        spacing = 0;
        text-color = mkLiteral "@fg0";
        urgent-color = mkLiteral "#EBCB8B";
      };
      "element" = {
        padding = mkLiteral "8px";
        spacing = mkLiteral "8px";
      };
      "element-icon" = {
        size = mkLiteral "0.8em";
      };
      "element-text" = {
        text-color = mkLiteral "inherit";
      };
      "element alternate active" = {
        text-color = mkLiteral "@accent-color";
      };
      "element normal normal" = {
        text-color = mkLiteral "@fg0";
      };
      "element normal urgent" = {
        text-color = mkLiteral "@urgent-color";
      };
      "element normal active" = {
        text-color = mkLiteral "@accent-color";
      };
      "element selected" = {
        text-color = mkLiteral "@bg0";
      };
      "element selected normal, element selected active" = {
        background-color = mkLiteral "@accent-color";
      };
      "element selected urgent" = {
        background-color = mkLiteral "@urgent-color";
      };
      "inputbar" = {
        background-color = mkLiteral "@bg1";
        padding = mkLiteral "8px";
        spacing = mkLiteral "8px";
      };
      "listview" = {
        padding = mkLiteral "4px 0";
        lines = 8;
        columns = 1;
        fixed-height = false;
      };
      "prompt, entry, element-icon, element-text" = {
        vertical-align = mkLiteral "0.5";
      };
      "prompt" = {
        text-color = mkLiteral "@accent-color";
      };
      "window" = {
        background-color = mkLiteral "@bg0";
        location = mkLiteral "center";
        width = 480;
      };
      "textbox" = {
        background-color = mkLiteral "@bg1";
        padding = mkLiteral "8px";
      };
    };
  };
}