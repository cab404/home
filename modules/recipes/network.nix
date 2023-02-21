args@{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in {
  networking = {
    networkmanager.dns = "systemd-resolved";
    networkmanager.wifi.backend = "iwd";
    networkmanager.wifi.powersave = false;
    firewall = on // {
      checkReversePath = "loose";
    };
  };
  services.resolved = {
    enable = true;
    fallbackDns = [
      "8.8.8.8" "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"
    ];
  };
  services.tailscale.enable = true;
}
