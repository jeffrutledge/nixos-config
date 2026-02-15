{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      directory = {
        fish_style_pwd_dir_length = 1;
      };
    };
  };
}
