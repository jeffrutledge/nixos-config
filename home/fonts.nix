{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.dejavu-sans-mono
  ];

  fonts.fontconfig.enable = true;
}
