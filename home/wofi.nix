{ pkgs, config, ... }:
let
  c = config.theme.colors;
in
{
  programs.wofi = {
    enable = true;
    style = ''
      window {
        background-color: ${c.base02};
        color: ${c.base1};
        font-family: "DejaVu Sans Mono";
        font-size: 14px;
      }

      #input {
        background-color: ${c.base02};
        color: ${c.base1};
        border: none;
      }

      #entry {
        background-color: ${c.base02};
        color: ${c.base1};
      }

      #entry:selected {
        background-color: ${c.blue};
        color: ${c.base3};
      }
    '';
  };
}
