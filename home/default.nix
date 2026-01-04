{ pkgs, ... }:
{
  imports = [
    ./sway.nix
    ./git.nix
    ./theme.nix
    ./firefox.nix
    ./alacritty.nix
    ./packages.nix
  ];
  home.stateVersion = "25.11";
}
