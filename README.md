# NixOS Config Module

I use this module to configure my personal computers. This is a module instead
of a standalone configuration because that allows me to keep some private parts
of the configuration in a separate location and reference this public module.

## Usage

Import this module in a nixos configuration. Somthing like this:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-config = {
      url = "github:jeffrutledge/nixos-config";
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
      nixosConfigurations.YourCfgName = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          inputs.nixos-config.nixosModules.default
          ./hardware-configuration.nix
          ./configuration.nix
        ];
      };
    };
}
```

## Troubleshooting

### IPv6 Troubleshooting

I ended up disabling ipv6 to resolve some timeout issues.

```nix
boot.kernelParams = [ "ipv6.disable=1" ];
networking.enableIPv6 = false;
```

The alternate solution also made <https://test-ipv6.com/> load quickly. With
ipv6 disable the site still loads slowly but the curl returns quickly and I
believe captive wifi portals will still work.

#### Why

I was encountering some 20s timeouts when running

```sh
curl -s -X 'GET' "https://aviationweather.gov/api/data/taf?ids=KMIA" -H 'accept: */*'
```

This was resolved by adding `-4` to curl.
I also noticed slowness running tests at <https://test-ipv6.com/>.

#### Alternate solution

This also resolved the slowness, but I believe forcing nameservers will break
captive wifi portals.

```nix
networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
services.resolved = {
    enable = true;
};
```

#### Tried but did not fix

- Try to fallback to reliable DNS servers without forcing them.

```nix
services.resolved = {
  enable = true;
  fallbackDns = [ "1.1.1.1" "9.9.9.9" ];
};
```

- Disable some resolved features

```nix
{
  services.resolved = {
    enable = true;
    dnssec = "false";
    extraConfig = ''
      DNSOverTLS=no
    '';
  };
  networking.tempAddresses = "disabled";
}

```

- Prefer ipv4 addresses

```nix
{
  networking.gaiConfig = ''
    precedence ::ffff:0:0/96  100
  '';
}
```
