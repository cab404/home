{ pkgs, inputs, ... }:{

  imports = [
      inputs.hydra.nixosModules.hydra
  ];
  nix = {
    buildMachines = [
       { hostName = "localhost";
         systems = ["builtin" "aarch64-linux" "x86_64-linux" "i686-linux"];
         maxJobs = 20;
       }
    ];
    settings = {
      max-jobs = 20;
      trusted-users = [ "builder" ];
      auto-optimise-store = true;
    };

    gc.automatic = true;
  };

  # services.postgresql.package = pkgs.postgresql_9_6;

  # services.hydra = {
  #   enable = true;
  #   hydraURL = "https://hydra.cab.moe";
  #   listenHost = "127.0.0.1";
  #   notificationSender = "hydra@cab.moe";
  #   useSubstitutes = true;
  #   extraConfig = ''
  #      store_uri = file:///var/lib/hydra/cache?secret-key=/etc/nix/cache.gnunet-hs.wldhx.me-1/secret
      #  binary_cache_secret_key_file = /etc/nix/cache.gnunet-hs.wldhx.me-1/secret
  #   '';
  # };


  services.nginx.enable = true;
  services.nginx.virtualHosts."cache" = {
    listen = [ { addr = "127.0.0.1"; port = 5000; ssl = false; } ];
    root = "/var/lib/hydra/cache"; # FIXME: permissions; stopgap 755 /var/lib/hydra
  };

  users.users.nginx.extraGroups = [ "hydra" ];

  users.users = {

    wldhx = {
      isNormalUser = true;
      extraGroups = [ "docker" "wheel" ];
      openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsyd0v60tMBYM6cRIYozZWn74U516mV9LatJz0yJRqc"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOeDZHzYxf6fGkgSVurFfxM4LYfpexLPQfScOv8YO7hf"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB13WWYhpU15m59f+9Vq7FhNfZ3D9SKhPux/RjxnIppq"
      ];
    };

    builder = {
      isNormalUser = true;
      extraGroups = [ ];
    };

  };
}
