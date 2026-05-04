{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelParams = [
      "console=ttyS0,115200"          # allows certain forms of remote access, if the hardware is setup right
      "panic=30" "boot.panic_on_fail" # reboot the machine upon fatal boot issues
    ];
  };

  networking.useDHCP = false;
  networking.interfaces.ens2.useDHCP = true;

}
