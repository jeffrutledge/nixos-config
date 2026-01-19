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
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
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
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
      devShells.${system}.default = pkgs.mkShell {
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
