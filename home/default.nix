{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.custom.nixosConfigPath = lib.mkOption {
    type = lib.types.str;
    default = "~/nixos/nixos-config";
    description = "Path to the nixos-config repository checkout";
  };

  imports = [
    ./sway
    ./git
    ./rofi.nix
    ./theme.nix
    ./firefox
    ./alacritty
    ./zsh.nix
    ./starship.nix
    ./packages.nix
    ./waybar
    ./neovim
    ./dunst.nix
    ./zathura.nix
    ./direnv.nix
  ];

  config = {
    fonts.fontconfig.enable = true;
    home.stateVersion = "25.11";
  };
}
