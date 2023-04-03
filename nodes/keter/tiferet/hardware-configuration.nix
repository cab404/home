args@{ pkgs, config, inputs, prelude, ... }:
with prelude; let __findFile = prelude.__findFile; in
{

  networking.interfaces.ens2.ipv6.addresses = [
    { address = "2001:bc8:1820:1943::1"; prefixLength = 64; }
  ];

  networking.interfaces.ens2.ipv6.routes = [
    { address = "::"; via = "2001:bc8:1820:1943::"; prefixLength = 0; }
  ];
  
  imports = [
    <nodes/scaleway>
  ];
}
