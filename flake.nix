{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
        programs.nixfmt.enable = true;
        programs.stylua = {
          enable = true;
          settings = {
            indent_type = "Spaces";
            indent_width = 2;
          };
        };
      };
      pre-commit-check = inputs.git-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          treefmt = {
            enable = true;
            package = treefmtEval.config.build.wrapper;
          };
          flake-check = {
            enable = true;
            name = "nix flake check";
            entry = "nix flake check";
            language = "system";
            pass_filenames = false;
            stages = [ "pre-push" ];
          };
        };
      };
    in
    {
      nixosModules.default = {
        imports = [
          inputs.disko.nixosModules.disko
          ./disko-config.nix
          ./configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit inputs; };
              users.jrutledge = import ./home;
            };
          }
        ];
      };
      formatter.${system} = treefmtEval.config.build.wrapper;
      devShells.${system}.default = pkgs.mkShell {
        inherit (pre-commit-check) shellHook;
        packages = [
          (pkgs.callPackage ./home/waybar/scripts/metar.nix { })
          (pkgs.callPackage ./home/waybar/scripts/duplicati.nix { })
          (pkgs.callPackage ./home/waybar/scripts/timew.nix { })
          (pkgs.callPackage ./home/waybar/scripts/wifi-status.nix { })
          (pkgs.callPackage ./home/sway/external-display.nix {
            internal = "eDP-1";
            external = "DP-1";
          })
        ];
      };
      nixosConfigurations.check-target = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.default
        ];
      };

    };
}
