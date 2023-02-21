args@{ pkgs, config, inputs, ... }:
with prelude; let __findFile = prelude.__findFile; in
{

    time.timeZone = "Europe/Amsterdam";
    networking.hostName = "tiferet";

    _.user = "cab";

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

    networking.interfaces.ens2.ipv6.addresses = [
      { address = "2001:bc8:1820:1943::1"; prefixLength = 64; }
    ];

    networking.interfaces.ens2.ipv6.routes = [
      { address = "::"; via = "2001:bc8:1820:1943::"; prefixLength = 0; }
    ];

    services.caddy = on // {
      virtualHosts = {
        "gtch.cab.moe" = {
          extraConfig = ''
            reverse_proxy 10.0.10.2
          '';
        };
        "gtch.cab404.pw" = {
          extraConfig = ''
            reverse_proxy 10.0.10.2
          '';
        };
        "nextcloud.cab.moe" = {
          extraConfig = ''
            reverse_proxy 10.0.10.2
          '';
        };
        "hs.cab.moe" = {
          extraConfig = ''
            reverse_proxy 127.0.0.1:8080
          '';
        };
      };
    };

    services.tailscale = on;
    services.headscale = on // {
      serverUrl = "https://hs.cab.moe";
      dns = {
        nameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
        baseDomain = "keter";
      };
    };

    environment.defaultPackages = with pkgs; [ headscale ];

    networking = {
      firewall = on // {
        allowedTCPPorts = [ 80 443 ];
        allowedUDPPorts = [ 41641 42232 61111 ];
        trustedInterfaces = [ "tailscale0" "keter" ];
      };
      nat = {
        enable = true;
        enableIPv6 = true;
        externalInterface = "ens2";
        internalIPs = [
          "10.0.10.0/24"
          "100.64.0.0/10"
        ];
        internalIPv6s = [
          "fd80:c4b4::/48"
        ];
      };
      networkmanager = off;
    };

    imports = [
      ../ssh.nix
      ../../../modules/core.nix
      ../../../modules/home-manager
    ];

}
