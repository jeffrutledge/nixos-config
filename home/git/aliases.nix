{ pkgs, ... }:
{
  programs.zsh.shellAliases = {
    glog = "git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative";
    gp = "git push origin HEAD";
    gd = "git diff";
    gds = "git diff --staged";
    gc = "git commit -m";
    gs = "git status -sb";
    gac = "git add -A && git commit -m";
    guc = "git add -u && git commit -m";
  };
}
