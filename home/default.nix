{ pkgs, ... }:
{
  imports = [
    ./sway.nix
    ./git
    ./rofi.nix
    ./theme.nix
    ./firefox.nix
    ./alacritty
    ./zsh
    ./starship.nix
    ./packages.nix
    ./waybar
  ];
  home.stateVersion = "25.11";
}
