{ pkgs, ... }: {
  networking.wg-quick.interfaces.keter = {
    type = "amneziawg";
    configFile = "/secrets/keter.conf";
  };
  boot.kernelModules = [ "amneziawg" ];
  networking.firewall.allowedUDPPorts = [ 63333 ];
  environment.defaultPackages = [ pkgs.amneziawg-tools ];
}
