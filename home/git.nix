{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = "Jeffrey Rutledge";
      email = "misc@jeffrut.com";
    };
  };
}
