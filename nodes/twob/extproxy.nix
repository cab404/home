{ config, lib, pkgs, ... }:
let
  local = "enp8s0";
  wifi = "wlp7s0";
in {

  networking = {
    useDHCP = false;
    dhcpcd.persistent = true;
    dhcpcd.wait = "background";

    vlans = {
      ext-vlan = {
        id = 10;
        interface = local;
      };
      local-vlan = {
        id = 20;
        interface = local;
      };
    };

    # Conn settings
    interfaces.${wifi}.useDHCP = true;
    # Conn settings
    interfaces.${local}.useDHCP = true;
    firewall.enable = false;

  };

  containers = {
    vpn-enclave = {
      interfaces = [ "ext-vlan" "local-vlan" ];
      config = { ... }: {
        networking = {
          firewall.enable = false;
          nameservers = [ "1.1.1.1" "8.8.8.8" ];
          interfaces = {
            ext-vlan = {
              ipv4.addresses = [{
                address = "192.168.1.220";
                prefixLength = 24;
              }];
            };
            local-vlan = {

            };
          };
          nat = {
            enable = true;
            enableIPv6 = true;
            externalInterface = "ext-vlan";
            internalInterfaces = [ "local-vlan" ];
          };
        };

      };
    };
  };

  # boot.kernel.sysctl = {
  #   # if you use ipv4, this is all you need
  #   "net.ipv4.conf.all.forwarding" = true;

  #   # If you want to use it for ipv6
  #   "net.ipv6.conf.all.forwarding" = true;

  #   # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52
  #   # By default, not automatically configure any IPv6 addresses.
  #   "net.ipv6.conf.all.accept_ra" = 0;
  #   "net.ipv6.conf.all.autoconf" = 0;
  #   "net.ipv6.conf.all.use_tempaddr" = 0;

  #   # On WAN, allow IPv6 autoconfiguration and tempory address use.
  #   "net.ipv6.conf.local-br.accept_ra" = 2;
  #   "net.ipv6.conf.local-br.autoconf" = 1;
  # };

}
