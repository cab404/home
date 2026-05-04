{ config, pkgs, prelude, ... }@args:
let
  on = { enable = true; };
  # iface = "enp0s18u1u1";
  conf = builtins.toFile "KlipperConfig.conf" ''
    [printer Plumbus]
    moonraker_host: localhost
    moonraker_port: 7125
  '';
in
# Klipper and stuff around it.
{
  services.cage = {
    enable = false;
    user = "klipper";
    extraArguments = [ "-s" "-d" ];
    program = "${pkgs.klipperscreen}/bin/KlipperScreen -c ${conf}";
  };
}
