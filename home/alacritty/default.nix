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

      hints = {
        enabled = [
          {
            # Restore the default URL-opening hint (Ctrl+Shift+O), since
            # defining `hints.enabled` replaces Alacritty's built-in default.
            command = "xdg-open";
            hyperlinks = true;
            post_processing = true;
            persist = false;
            mouse.enabled = true;
            binding = {
              key = "O";
              mods = "Control|Shift";
            };
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^ \t\n\"'<>^`\\\\]+";
          }
          {
            # tmux-fingers style: hint words/paths and insert the pick at the cursor.
            action = "Paste";
            post_processing = false;
            persist = false;
            mouse.enabled = false;
            binding = {
              key = "P";
              mods = "Control|Shift";
            };
            regex = "[a-zA-Z0-9_@:./~-]{2,}";
          }
        ];
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
