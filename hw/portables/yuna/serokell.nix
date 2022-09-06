{ pkgs, lib, ... }: {

  networking.wg-quick.interfaces."vpn-srk" = {
    autostart = false;
    configFile = "/secrets/vpn-srk.conf";
  };

  networking.wg-quick.interfaces."srk" = {
    autostart = false;
    privateKeyFile = "/secrets/wg-srk.ed25519.base64";
    address = [ "172.20.0.62" "fd73:7272:ed50::62" ];
    peers = [
      {
        publicKey = "sgLUARawWJejANs2CwuCptwJO55c4jkmnP0L14FNCyw=";
        allowedIPs = [ "172.20.0.1/32" "172.20.0.0/24" ];
        endpoint = "wasat.gemini.serokell.team:35944";
      }
    ];
  };

}
