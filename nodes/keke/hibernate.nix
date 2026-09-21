{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
let
  # Calculated with `sudo btrfs inspect-internal map-swapfile /var/swapfile`
  swapOffset = 1582336;
in
{
  powerManagement = on;

  boot.resumeDevice = "/dev/disk/by-label/keke-root";

  boot.kernelParams = [
    "resume=${config.boot.resumeDevice}"
    "resume_offset=${toString swapOffset}"
  ];

  swapDevices = [{
    device = "/var/swapfile";
    size = 16 * 1024;
  }];

}
