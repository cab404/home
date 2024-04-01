{ config, lib, pkgs, ... }:
let
  local = "enp8s0";
  ext = "wlp7s0";
  router-usb = "enp10s0f3u1";
in
{

  networking = {
    useDHCP = false;

    vlans = {
      ext-vlan = {
        id = 10;
        interface = router-usb;
      };
      local-vlan = {
        id = 20;
        interface = router-usb;
      };
    };

    bridges = {
      local-br = {
        interfaces = [ "local-vlan" local ];
      };
      # ext-br = {
      #   interfaces = [ "ext-vlan" ];
      # };
    };

    # Conn settings

    interfaces."${ext}" = {
      useDHCP = true;
    };

    interfaces.ext-vlan.useDHCP = true;

    supplicant = { "${ext}" = { configFile.path = "/secrets/wpa.conf"; }; };
    nameservers = [ "1.1.1.1" "8.8.8.8" ];

    # LAN settings
    interfaces.local-br = {
      useDHCP = false;
      ipv4.addresses = [{
        address = "10.144.0.1";
        prefixLength = 16;
      }];
      ipv6.addresses = [{
        address = "fd00:aa:cafe::";
        prefixLength = 64;
      }];
    };

    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "${ext}";
      internalInterfaces = [ "local-br" ];
    };
    firewall.enable = false;
    dhcpcd.wait = "background";


  };

  services = {
    avahi = {
      enable = true;
      openFirewall = true;

      nssmdns = true;
      publish.enable = true;
      reflector = true;
      interfaces = [ "local-br" ];
    };

    dnsmasq.enable = true;

    radvd = {
      enable = true;
      config = ''
        interface local-br {
          AdvSendAdvert on;
          AdvManagedFlag on;
          AdvOtherConfigFlag on;

          prefix fd00:aa:cafe::/64 {
            AdvAutonomous off;
          };
        };
      '';
    };
    dhcpd4 = {
      enable = true;
      interfaces = [ "local-br" ];
      extraConfig = ''
        option domain-name "lan";
        option domain-name-servers 1.1.1.1, 8.8.8.8;
        option subnet-mask 255.255.0.0;
        subnet 10.144.0.0 netmask 255.255.0.0 {
          option broadcast-address 10.144.255.255;
          interface local-br;
          option routers 10.144.0.1;
          option broadcast-address 10.144.255.255;
          range 10.144.0.2 10.144.100.254;
        }
      '';
    };
    dhcpd6 = {
      enable = true;
      interfaces = [ "local-br" ];
      extraConfig = ''
        option dhcp6.domain-search "lan";
        subnet6 fd00:aa:cafe::/64 {
          interface local-br;
          range6 fd00:aa:cafe::2 fd00:aa:cafe::ffff;
        }
      '';
    };
  };

  boot.kernel.sysctl = {
    # if you use ipv4, this is all you need
    "net.ipv4.conf.all.forwarding" = true;

    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;

    # source: https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configuration.nix#L52
    # By default, not automatically configure any IPv6 addresses.
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.all.autoconf" = 0;
    "net.ipv6.conf.all.use_tempaddr" = 0;

    # On WAN, allow IPv6 autoconfiguration and tempory address use.
    "net.ipv6.conf.local-br.accept_ra" = 2;
    "net.ipv6.conf.local-br.autoconf" = 1;
  };

}
