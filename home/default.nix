{ pkgs, ... }:
{
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
  ];
  fonts.fontconfig.enable = true;
  home.stateVersion = "25.11";
}
