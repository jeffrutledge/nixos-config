{ pkgs, ... }:
{
  imports = [
    ./sway.nix
    ./git.nix
    ./rofi.nix
    ./theme.nix
    ./firefox.nix
    ./alacritty
    ./zsh
    ./packages.nix
  ];
  home.stateVersion = "25.11";
}
