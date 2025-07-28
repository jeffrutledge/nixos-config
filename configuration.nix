{
  modulesPath,
  lib,
  pkgs,
  ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disko-config.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
  };

  services.userborn = {
    enable = true;
  };

  users.users.jrutledge = {
    isNormalUser = true;
    shell = pkgs.zsh;
    password = "1234";
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
