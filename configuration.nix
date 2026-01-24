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

  # See [readme](README.md#ipv6-troubleshooting)
  boot.kernelParams = [ "ipv6.disable=1" ];
  networking.enableIPv6 = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services = {
    localtimed.enable = true;
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

    logind = {
      settings.Login = {
        IdleAction = "suspend-then-hibernate";
        IdleActionSec = "5m";
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchDocked = "suspend-then-hibernate";
      };
    };

  };

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=300
  '';

  security.polkit.enable = true;

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    zsh.enable = true;

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

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.symbols-only
      noto-fonts-color-emoji
    ];
    fontconfig.defaultFonts = {
      monospace = [
        "DejaVuSansM Nerd Font"
        "Symbols Nerd Font"
        "Noto Color Emoji"
      ];
      sansSerif = [ "DejaVu Sans" ];
      serif = [ "DejaVu Serif" ];
    };
  };

  system.stateVersion = "25.11";
}
