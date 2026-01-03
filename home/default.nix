{ pkgs, ... }:
{
  imports = [
    ./sway.nix
    ./theme.nix
  ];
  home.stateVersion = "25.11";
}
