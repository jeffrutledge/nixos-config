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
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
      nixosModules.default = {
        imports = [
          inputs.disko.nixosModules.disko
          ./disko-config.nix
          ./configuration.nix
          ./theme.nix
          inputs.home-manager.nixosModules.home-manager
          ./home.nix
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
