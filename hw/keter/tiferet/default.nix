{ config, ... }: {

    time.timeZone = "Europe/Amsterdam";

    _.user = "cab";

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

    networking.interfaces.ens2.ipv6.addresses = [
      { address = "2001:bc8:1820:1943::1"; prefixLength = 64; }
    ];

    networking.interfaces.ens2.ipv6.routes = [
      { address = "::"; via = "2001:bc8:1820:1943::"; prefixLength = 0; }
    ];

    networking.firewall.allowedUDPPorts = [ 61111 ];

    imports = [
      ../ssh.nix
      ../../scaleway
      ../../../modules/core.nix
      ../../../modules/home-manager
    ];

}
