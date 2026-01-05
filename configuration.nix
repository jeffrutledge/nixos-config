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

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
          user = "greeter";
        };
      };
    };
  };

  security.polkit.enable = true;

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    zsh.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    gnupg.agent.enable = true;
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

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      nerd-fonts.dejavu-sans-mono
    ];
    fontconfig.defaultFonts = {
      monospace = [ "DejaVuSansM Nerd Font" ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
    };
  };

  system.stateVersion = "25.11";
}
