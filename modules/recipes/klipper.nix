{ config, pkgs, lib, ... }: let
  on = { enable = true; };
in

# Klipper and stuff around it.
# For now this only supports one printer connected, klipper needs to be a parametrized service to support more.
#
{

  options = with lib; with types; let
    printer = {
      fwBuildConfig = mkOption {
        description = "Path to klipper firmware build config";
        default = null;
        type = path;
      };
      configFile = mkOption {
        description = "Path to initial printer klipper config";
        default = null;
        type = path;
      };
      serial = mkOption {
        description = "Path to printer device, e.g /dev/serial/by-id/something";
        default = null;
        type = path;
      };
    };
  in {
    printing.klipper = {
      enable = mkEnableOption "klipper prining";
      printer = mkOption {
        description = "Printer configuration";
        default = {};
        type = submodule { options = printer; };
      };
    };
  };

  config = let conf = config.printing.klipper; in lib.mkIf conf.enable {

    users.users.klipper = {
      isSystemUser = true;
      group = "klipper";
    };
    users.groups.klipper = { };

    security.polkit = on;
    services.klipper = on // {
      user = "klipper";
      group = "klipper";
      configFile = conf.printer.configFile;
      mutableConfig = true;
      mutableConfigFolder = "/var/lib/klipper/config";
      firmwares.printer = {
        enable = true;
        enableKlipperFlash = true;
        inherit (conf.printer) serial;
        configFile = conf.printer.fwBuildConfig;
      };
    };

    services.moonraker = on // {
      user = "klipper";
      group = "klipper";
      address = "0.0.0.0";
      allowSystemControl = true;
      stateDir = "/var/lib/klipper";
      settings = {
        authorization = {
          cors_domains = [
            "http://${config.networking.hostName}"
            "http://${config.networking.hostName}.lan"
            "http://${config.networking.hostName}.local"
            "http://localhost"
            "http://app.fluidd.xyz"
            "http://my.mainsail.xyz"
          ];
          trusted_clients = [ "0.0.0.0/0" ];
        };
        file_manager = {
          enable_object_processing = "False";
        };
        octoprint_compat = { };
      };
    };
    services.fluidd = on // {
      nginx.extraConfig = ''
        client_max_body_size 1G;
      '';
      nginx.locations."/webcam".proxyPass = "http://127.0.0.1:7000/stream";
    };

    systemd.services.klippercam = {
      script = "${pkgs.ustreamer}/bin/ustreamer -f 15 -s 0 -p 7000";
      enable = true;
      after = [ "network.target" ];
    };

  };
}
