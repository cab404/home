args@{ config, lib, pkgs, ... }:
with import ../lib.nix args; {

  services = {

    udev.packages = with pkgs; [
      (writeTextDir "/etc/udev/rules.d/42-oculus.rules" ''
        # Oculus Quest 2
        ATTR{idVendor}=="2833", ATTR{idProduct}=="0137", GROUP="dialout"
      '')
    ];

  };
}
