{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
  };

  xdg.desktopEntries.yazi = {
    name = "Yazi";
    genericName = "File Manager";
    exec = "${pkgs.alacritty}/bin/alacritty -e ${pkgs.yazi}/bin/yazi %u";
    terminal = false;
    mimeType = [ "inode/directory" ];
    categories = [
      "System"
      "FileManager"
    ];
  };

  xdg.mimeApps.defaultApplications = {
    "inode/directory" = "yazi.desktop";
  };

  # xdg-desktop-portal-termfilechooser doesn't do Exec-key style %f/%u
  # substitution: it calls `cmd` with fixed positional args (see
  # xdg-desktop-portal-termfilechooser(5)) and writes the selection to the
  # path given as $5. The bundled yazi-wrapper.sh already handles that
  # protocol correctly, so reuse it instead of hand-rolling `cmd`.
  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
    env=TERMCMD=${pkgs.alacritty}/bin/alacritty --title termfilechooser -e
    default_dir=$HOME
  '';
}
