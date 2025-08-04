{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
  {
    nixosConfigurations.mistyfjord = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.disko.nixosModules.disko
        inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series1
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
  };
}
