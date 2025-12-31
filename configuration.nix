{
  lib,
  pkgs,
  ...
}:
{
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  networking.wireless = {
    enable = true;
    userControlled.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.userborn.enable = true;

  programs.zsh.enable = true;

  users.users.jrutledge = {
    isNormalUser = true;
    shell = pkgs.zsh;
    password = "12345";
    extraGroups = [
      "wheel"
    ];
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  system.stateVersion = "25.11";
}
