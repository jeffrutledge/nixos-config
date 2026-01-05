{ config, pkgs, ... }:

let
  c = config.theme.colors;
  f = config.theme.font;
in
{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 2;
          y = 2;
        };
      };

      font = {
        size = f.size;
        normal = {
          family = f.family;
          style = "Regular";
        };
      };


      colors = {
        primary = {
          background = c.base03;
          foreground = c.base0;
        };

        cursor = {
          text = c.base03;
          cursor = c.base1;
        };

        normal = {
          black = c.base02;
          red = c.red;
          green = c.green;
          yellow = c.yellow;
          blue = c.blue;
          magenta = c.magenta;
          cyan = c.cyan;
          white = c.base2;
        };

        bright = {
          black = c.base03;
          red = c.orange;
          green = c.base01;
          yellow = c.base00;
          blue = c.base0;
          magenta = c.violet;
          cyan = c.base1;
          white = c.base3;
        };
      };
    };
  };
}
