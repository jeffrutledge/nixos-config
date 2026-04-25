{ pkgs, ... }:
{
  home.packages = with pkgs; [
    gemini-cli
    claude-code
    bottom
    fd
    tree
    ripgrep
    wl-clipboard
    material-design-icons
    font-awesome
    brightnessctl
    wireplumber
    pavucontrol
    blueman
    playerctl
    vlc
    loupe
    zip
    unzip
    python3
    qpdf
    pdftk
  ];
}
