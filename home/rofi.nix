{ pkgs, config, ... }:
let
  c = config.theme.colors;
  inherit (config.lib.formats.rasi) mkLiteral;
in
{
  programs.rofi = {
    enable = true;
    font = "DejaVu Sans Mono 10";
    extraConfig = {
      modi = "drun";
      kb-row-up = "Control+k";
      kb-row-down = "Control+j";
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
      "listview" = {
        lines = 10;
        columns = 1;
      };
      "element" = {
        padding = mkLiteral "1px";
      };
      "element selected" = {
        background-color = mkLiteral c.blue;
        text-color = mkLiteral c.base3;
      };
    };
  };
}
