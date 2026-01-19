# IPv6 Troubleshooting
I ended up disabling ipv6 to resolve some timeout issues.
```
boot.kernelParams = [ "ipv6.disable=1" ];
networking.enableIPv6 = false;
```

The alternate solution also made https://test-ipv6.com/ load quickly. With ipv6 disable the site still loads slowly but the curl returns quickly and I believe captive wifi portals will still work.


## Why
I was encountering some 20s timeouts when running
```
curl -s -X 'GET' "https://aviationweather.gov/api/data/taf?ids=KMIA" -H 'accept: */*'
```
This was resolved by adding `-4` to curl.
I also noticed slowness running tests at https://test-ipv6.com/.

## Alternate solution
This also resolved the slowness, but I believe forcing nameservers will break captive wifi portals.
```
networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
services.resolved = {
    enable = true;
};
```

## Tried but did not fix
- Try to fallback to reliable DNS servers without forcing them.
```
services.resolved = {
  enable = true;
  fallbackDns = [ "1.1.1.1" "9.9.9.9" ];
};
```
- Disable some resolved features
```
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

```
{
  networking.gaiConfig = ''
    precedence ::ffff:0:0/96  100
  '';
}
```
