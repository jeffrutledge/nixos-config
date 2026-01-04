{ pkgs, ... }:
{
  imports = [
    ./sway.nix
    ./git.nix
    ./rofi.nix
    ./theme.nix
    ./firefox.nix
    ./alacritty.nix
    ./packages.nix
  ];
  home.stateVersion = "25.11";
}
