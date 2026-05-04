{ config, pkgs, prelude, ... }@args:
let
  on = { enable = true; };
in

# Klipper and stuff around it.

{

  users.users.klipper = {
    isSystemUser = true;
    group = "klipper";
  };
  users.groups.klipper = { };

  security.polkit = on;

  nixpkgs.overlays = [
    (super: self: {
      klipper = self.klipper.overrideAttrs {
        version = "master-master";
        src = pkgs.fetchFromGitHub {
          owner = "klipper3d";
          repo = "klipper";
          rev = "5eb07966b5d7e1534aa40df3b0ea305f5c6d9ae2";
          hash = "sha256-AUK0vGhz1ZvVtEpVto/Qlp4+3PGsjOTBzj8Ik8sfmRQ=";
        };
      };
    })
  ];

  systemd.services.canconfig = {
    wantedBy = [ "sys-subsystem-net-devices-can0.device" ];
    path = [ pkgs.iproute2 ];
    script = ''
      ip link set can0 type can bitrate 1000000
      ip link set can0 txqueuelen 128
      ip link set can0 up
    '';
  };

  services.klipper = on // {
    user = "klipper";
    group = "klipper";
    configFile = ./printer.cfg;
    mutableConfig = true;
    configDir = "/var/lib/klipper/config";
    firmwares = {
      plumbus = {
        # enable = true;
        # enableKlipperFlash = true;
        serial = "/dev/serial/by-id/usb-Klipper_sam4e8e_003230533750414D3135303336303534-if00";
        configFile = ./plumbus.cfg;
      };
      ebb = {
        # enable = true;
        # enableKlipperFlash = true;
        serial = "/dev/serial/by-id/usb-Klipper_sam4e8e_003230533750414D3135303336303534-if00";
        configFile = ./ebb.cfg;
      };
    };
  };

  services.moonraker = on // {
    user = "klipper";
    group = "klipper";
    address = "0.0.0.0";
    allowSystemControl = true;
    stateDir = "/var/lib/klipper";
    # analysis.enable = true;

    settings = {
      authorization = {
        cors_domains = [
          "http://${config.networking.hostName}"
          "http://${config.networking.hostName}.lan"
          "http://${config.networking.hostName}.local"
          "http://${config.networking.hostName}.keter"
          "http://localhost"
          "http://app.fluidd.xyz"
          "http://my.mainsail.xyz"
          "http://le-fail.lan"
          "http://printer-plumbus.lan"
        ];
        trusted_clients = [ "0.0.0.0/0" "::0/0" ];
      };

      file_manager = {
        enable_object_processing = "False";
      };
      octoprint_compat = { };

      # "update_manager Klipper-Adaptive-Meshing-Purging" = {
      #   type = "git_repo";
      #   channel = "dev";
      #   path = "~/Klipper-Adaptive-Meshing-Purging";
      #   origin = "https://github.com/kyleisah/Klipper-Adaptive-Meshing-Purging.git";
      #   managed_services = "klipper";
      #   primary_branch = "main";
      # };
    };
  };
  services.fluidd = on // {
    nginx = {
      extraConfig = ''
        client_max_body_size 1G;
      '';
      locations."/webcam".proxyPass = "http://127.0.0.1:8080/stream";
    };
  };

  systemd.services.klipper = {
    after = [ "network.target" ];
  };

  systemd.services.klippercam = {
    script = "${pkgs.ustreamer}/bin/ustreamer -f 15 -s 0";
    enable = true;
    after = [ "network.target" ];
  };



}
