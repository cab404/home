{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in {

  imports = [
    <modules/core.nix>
    <modules/home-manager>
    <modules/recipes/substituters.nix>
    <modules/recipes/klipper.nix>
    <modules/recipes/ssh.nix>
  ];

  networking.hostName = "fudemonix";
  _.user = "cab";

  environment.systemPackages = [ pkgs.avrdude ];

  printing.klipper = on // {
    printer = {
      fwBuildConfig = ./buildconfig.ini;
      configFile = ./printer.cfg;
      serial = "/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0";
    };
  };

  networking.firewall.enable = false;
  systemd.network.wait-online.enable = false;
  networking.supplicant.wlan0 = {
    configFile = {
      path = "/etc/wifi.conf";
      writable = true;
    };
    userControlled.enable = true;
  };
  
  # networking.networkmanager.enable = true;


}
