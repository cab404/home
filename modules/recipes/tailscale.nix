args@{ inputs, prelude, lib, config, pkgs, ... }:
with prelude; let __findFile = prelude.__findFile; in
{
    services.tailscale = on;
    networking.firewall = {
      checkReversePath = "loose";
    };
}
