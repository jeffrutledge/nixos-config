{ pkgs, config, ... }:
let
  c = config.theme.colors;
  f = config.theme.font;
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;
    font = "${f.family} ${toString f.size}";
    extraConfig = {
      modi = "drun";
      kb-row-up = "Up,Control+k";
      kb-row-down = "Down,Control+j";
      kb-remove-to-eol = "";
      kb-accept-entry = "Control+m,Return,KP_Enter";
    };
    theme = {
      "*" = {
        background-color = mkLiteral c.base02;
        text-color = mkLiteral c.base1;
      };
      "window" = {
        border = mkLiteral "1px";
        padding = mkLiteral "5px";
        border-color = mkLiteral c.blue;
      };
      "mainbox" = {
        spacing = mkLiteral "10px";
        children = map mkLiteral [
          "inputbar"
          "listview"
        ];
      };
      "inputbar" = {
        children = map mkLiteral [
          "prompt"
          "entry"
        ];
        spacing = mkLiteral "10px";
      };
      "prompt" = {
        background-color = mkLiteral c.blue;
        text-color = mkLiteral c.base3;
        padding = mkLiteral "2px 5px";
      };
      "entry" = {
        background-color = mkLiteral c.base03;
        text-color = mkLiteral c.base0;
        padding = mkLiteral "2px 5px";
      };
      "listview" = {
        lines = 10;
        columns = 1;
        spacing = mkLiteral "2px";
      };
      "element" = {
        padding = mkLiteral "1px";
        children = map mkLiteral [
          "element-icon"
          "element-text"
        ];
      };
      "element selected" = {
        background-color = mkLiteral c.blue;
        text-color = mkLiteral c.base3;
      };
      "element-text" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
        vertical-align = mkLiteral "0.5";
      };
      "element-icon" = {
        size = mkLiteral "1.0em";
        background-color = mkLiteral "inherit";
      };
    };
  };
}
