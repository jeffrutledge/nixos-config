{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    # Pin the pre-25.11 default explicitly so behavior doesn't change out
    # from under us when home.stateVersion is eventually bumped.
    shellWrapperName = "yy";
    # Default keymap binds `d` to trash (recoverable) and `D` to permanent
    # delete. `d` is used far more often, so make it delete outright instead
    # of leaving files sitting in ~/.local/share/Trash.
    keymap.mgr.prepend_keymap = [
      {
        on = [ "d" ];
        run = "remove --permanently";
        desc = "Permanently delete the selected files";
      }
    ];
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
