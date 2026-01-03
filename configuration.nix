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

  networking = {
    hostName = "misty";
    networkmanager = {
      enable = true;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services = {
    userborn.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    kanata = {
      enable = true;
      keyboards.default = {
        config = ''
          (defsrc caps)
          (deflayer default esc)
        '';
      };
    };
  };

  programs.zsh.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  users.users.jrutledge = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  environment.systemPackages =
    with pkgs;
    map lib.lowPrio [
      curl
      gitMinimal
    ];

  system.stateVersion = "25.11";
}
