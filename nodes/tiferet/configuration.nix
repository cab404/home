args@{ pkgs, config, inputs, prelude, ... }:
with prelude; let __findFile = prelude.__findFile; in
{

  imports =
    [
      <modules/recipes/ssh.nix>
      <modules/recipes/ssh-persist.nix>
      <modules/recipes/substituters.nix>
      <modules/recipes/tailscale.nix>
      <modules/barecore.nix>
      <modules/home-manager>
      <modules/podman.nix>

      ./mail.nix
      ./heisenbridge.nix
      ./tailscale.nix

      <modules/keter/wg.nix>
      # inputs.gtch.nixosModules.default
    ];

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  services.iodine.server = {
    enable = true;
    domain = "tuna.cab.moe";
    passwordFile = "/secrets/iodine-password";
    ip = "10.234.44.1/24";
  };

  # services.gtch = on // {
  #   listenAddress = "10.0.10.1";
  #   webSettingsFile = "/secrets/gtch_settings.json";
  # };

  services.resolved = {
    enable = true;
    fallbackDns = [
      "8.8.8.8"
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
  };

  _.user = "cab";
  time.timeZone = "Europe/Amsterdam";
  networking.hostName = "tiferet";

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  services.caddy = on // {
    virtualHosts = {
      "gtch.cab.moe" = {
        extraConfig = ''
          reverse_proxy c1:8011
        '';
      };
      "eris.cab.moe" = {
        extraConfig = ''
          reverse_proxy eris:6006
        '';
      };
      "pretix.cab.moe" = {
        extraConfig = ''
          reverse_proxy twob:8345
        '';
      };
      "immich.cab.moe" = {
        extraConfig = ''
          reverse_proxy c1:2283
        '';
      };
      "paperless.cab.moe" = {
        extraConfig = ''
          reverse_proxy c1:8000
        '';
      };
      "static.cab.moe" = {
        extraConfig = ''
          root * /var/lib/moe
          file_server browse
        '';
      };
      # "ocapn.cab.moe" = {
      #   extraConfig = ''
      #     reverse_proxy http://c1.keter:7000
      #   '';
      # };
      # "nextcloud.cab.moe" = {
      #   extraConfig = ''
      #     @webdav {
      #       path_regexp N /.well-known/(card|cal)dav
      #     }
      #     rewrite @webdav /remote.php/dav/
      #     reverse_proxy http://c1.keter:80
      #   '';
      # };
      # "nextcloud.cab404.ru" = {
      #   extraConfig = ''
      #     @webdav {
      #       path_regexp N /.well-known/(card|cal)dav
      #     }
      #     rewrite @webdav /remote.php/dav/
      #     reverse_proxy http://c1.keter:80
      #   '';
      # };
      "hs.cab.moe" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8080
        '';
      };
    };
  };

  networking = {
    firewall = on // {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 53 41641 42232 61111 ];
      trustedInterfaces = [ "tailscale0" "keter" ];
    };
    nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "ens2";
      internalIPs = [
        "10.0.10.0/24" # wireguard
        "100.64.0.0/10" # tailscale
        "10.234.44.0/24" # iodine
      ];
      internalIPv6s = [
        "fd7a:115c:a1e0::/48"
      ];
    };
    networkmanager = off;
  };

}
