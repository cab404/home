{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%
  imports =
    [
      <modules/recipes/ssh.nix>
      <modules/recipes/ssh-persist.nix>
      <modules/recipes/substituters.nix>
      <modules/recipes/tailscale.nix>
      <modules/core.nix>
      <modules/home-manager>
      <modules/podman.nix>
      <modules/awg>
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.services."NetworkManager-wait-online".wantedBy = lib.mkForce [];

  # redirect tailscale server traffic through localhost
  networking.hosts = {
    "10.0.10.1" = [ "hs.cab.moe" ];
  };

  services.resolved = {
    enable = true;
  };

  # fun part — act as a default DNS so to resolve self-refferential addresses back at us.
  # TBH we need to have something that would detect our public address and rewrite with a local one
  services.bind = {
    enable = true;
    listenOn = [ "192.168.1.0/24" ];
    cacheNetworks = [ "192.168.1.0/24" ];
    zones.rpz = {
      master = true;
      file = builtins.toFile "db.rpz" ''
        $TTL 60
        @            IN    SOA  localhost. root.localhost.  (
                                  2015112501   ; serial
                                  1h           ; refresh
                                  30m          ; retry
                                  1w           ; expiry
                                  30m)         ; minimum
                           IN     NS    localhost.

        localhost       A   127.0.0.1
        hs.cab.moe      A   192.168.1.76
      '';
    };
    extraOptions = ''
      response-policy { zone "rpz"; };
    '';
  };

  networking.hostName = "c1";
  _.user = "cab";

  boot.loader.timeout = 0;
  boot.kernelPackages = pkgs.linuxPackages;

  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    vim
    cryptsetup
    docker-compose
    btrfs-progs
    thin-provisioning-tools
    hexedit
    git
    screen
    zellij
  ];

  services.cron.enable = true;

  networking = {
    firewall = on // {
      allowedTCPPorts = [ 80 443 7000 ];
      allowedUDPPorts = [ 53 41641 42232 61111 ];
      trustedInterfaces = [ "tailscale0" "keter" ];
    };
    # constant disconnects and weird internets are the reason i use nm.
    # it's really versatile, and aims to just get the client to the internet no matter what
    # and that's what I want with this machine
    networkmanager = on;
  };

  nix.settings.system-features = [ "gccarch-alderlake" "benchmark" "big-parallel" "kvm" "nixos-test" ];
  services.caddy = on // {
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/porkbun@v0.3.1" ];
      hash = "sha256-aVSE8y9Bt+XS7+M27Ua+ewxRIcX51PuFu4+mqKbWFwo=";
    };
    environmentFile = "/secrets/caddy.env";
    globalConfig = ''
      email acme+c1@cab.moe
      acme_dns porkbun {
        api_key {$PB_API_KEY}
        api_secret_key {$PB_API_SECRET}
      }
    '';
    virtualHosts = {
      "gtch.ru.cab.moe" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:8011
        '';
      };
      # Retranslation from main instance through AWG.
      "hs.cab.moe" = {
        extraConfig = ''
          reverse_proxy 10.0.10.1:8080
        '';
      };
    };
  };

  services.tor = {
    # enable = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      BandwidthBurst = 800 * 1024;
      BandwidthRate = 500 * 1024;
      Nickname = "mnfrdmcx";
      Address = "cab404.ru";
      ORPort = 143;
    };
  };

  services.fail2ban.enable = true;

  users.users = {
    "${config._.user}" = {
      extraGroups = [ "docker" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

}
