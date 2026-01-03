{ pkgs, ... }:
{
  imports = [
    ./sway.nix
    ./theme.nix
    ./firefox.nix
  ];
  home.stateVersion = "25.11";
}
