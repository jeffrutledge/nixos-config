{ pkgs, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jrutledge = {
      xsession = {
        enable = true;
        windowManager.i3 = {
          enable = true;
          config = {
            modifier = "Mod4";
            terminal = "alacritty";
            keybindings =
              let
                modifier = "Mod4";
              in
              pkgs.lib.mkOptionDefault {
                "${modifier}+p" = "exec ${pkgs.dmenu}/bin/dmenu_run";
              };
          };
        };
      };
    };
  };
}
