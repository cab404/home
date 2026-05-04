args@{ inputs, prelude, lib, config, pkgs, ... }:
with prelude; let __findFile = prelude.__findFile; in
{
    services.tailscale = on;
    networking.firewall = {
      checkReversePath = "loose";
    };
    # just in case
    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
}
