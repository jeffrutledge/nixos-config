{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gemini-cli
    bottom
    fd
    tree
    ripgrep
    wl-clipboard
    material-design-icons
    font-awesome
    brightnessctl
    wireplumber
    playerctl
  ];
}
