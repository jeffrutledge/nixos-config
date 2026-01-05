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
    ./fonts.nix
    ./packages.nix
  ];
  home.stateVersion = "25.11";
}
