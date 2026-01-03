{ lib, ... }:

{
  options.theme.colors = {
    base03 = lib.mkOption {
      type = lib.types.str;
      default = "#002b36";
    };
    base02 = lib.mkOption {
      type = lib.types.str;
      default = "#073642";
    };
    base01 = lib.mkOption {
      type = lib.types.str;
      default = "#586e75";
    };
    base00 = lib.mkOption {
      type = lib.types.str;
      default = "#657b83";
    };
    base0 = lib.mkOption {
      type = lib.types.str;
      default = "#839496";
    };
    base1 = lib.mkOption {
      type = lib.types.str;
      default = "#93a1a1";
    };
    base2 = lib.mkOption {
      type = lib.types.str;
      default = "#eee8d5";
    };
    base3 = lib.mkOption {
      type = lib.types.str;
      default = "#fdf6e3";
    };
    yellow = lib.mkOption {
      type = lib.types.str;
      default = "#b58900";
    };
    orange = lib.mkOption {
      type = lib.types.str;
      default = "#cb4b16";
    };
    red = lib.mkOption {
      type = lib.types.str;
      default = "#dc322f";
    };
    magenta = lib.mkOption {
      type = lib.types.str;
      default = "#d33682";
    };
    violet = lib.mkOption {
      type = lib.types.str;
      default = "#6c71c4";
    };
    blue = lib.mkOption {
      type = lib.types.str;
      default = "#268bd2";
    };
    cyan = lib.mkOption {
      type = lib.types.str;
      default = "#2aa198";
    };
    green = lib.mkOption {
      type = lib.types.str;
      default = "#859900";
    };
  };
}
