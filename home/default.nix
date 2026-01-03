{ pkgs, ... }:
{
  imports = [
    ./sway.nix
    ./theme.nix
    ./firefox.nix
    ./alacritty.nix
  ];
  home.stateVersion = "25.11";
}
