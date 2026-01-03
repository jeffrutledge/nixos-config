{ pkgs, ... }:
{
  imports = [
    ./i3.nix
    ./theme.nix
  ];
  home.stateVersion = "25.11";
}
