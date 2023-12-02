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

      ./mail.nix
      ./heisenbridge.nix
      ./tailscale.nix

      (import <nodes/keter/wgbond.nix>).defaults
      (import <nodes/keter/wgbond.nix>).tiferet
      inputs.gtch.nixosModules.default
    ];

  services.journald.extraConfig = ''
    SystemMaxUse=500M
  '';

  services.gtch = on // {
    listenAddress = "10.0.10.1";
    webSettings = {
      DEBUG = false;

      STATIC_URL = "/static/";
      ALLOWED_HOSTS = [ "gtch.cab.moe" "10.0.10.1" ];

      EMAIL_HOST = "smtp.yandex.com";
      EMAIL_PORT = 465;
      EMAIL_USE_SSL = true;
      EMAIL_HOST_USER = "mail@unitycon.ru";
      EMAIL_HOST_PASSWORD = ''jtbrjgkwvjdldjtr'';

    };
  };

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
          handle_path /static/* {
            root * ${inputs.gtch.packages.x86_64-linux.static}
            file_server
          }
          reverse_proxy 100.64.0.1:8000
        '';
      };
      "eris.cab.moe" = {
        extraConfig = ''
          reverse_proxy eris-taxguywu.cab.keter:6006
        '';
      };
      "gtch.cab404.pw" = {
        extraConfig = ''
          handle_path /static/* {
            root * ${inputs.gtch.packages.x86_64-linux.static}
            file_server
          }
          reverse_proxy 100.64.0.1:8000
        '';
      };
      "nextcloud.cab.moe" = {
        extraConfig = ''
          @webdav {
            path_regexp N /.well-known/(card|cal)dav
          }
          rewrite @webdav /remote.php/dav/
          reverse_proxy http://100.64.0.9:80
        '';
      };
      "nextcloud.cab404.ru" = {
        extraConfig = ''
          @webdav {
            path_regexp N /.well-known/(card|cal)dav
          }
          rewrite @webdav /remote.php/dav/
          reverse_proxy http://100.64.0.9:80
        '';
      };
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

}
