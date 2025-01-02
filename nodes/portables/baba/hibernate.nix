{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
let
  # Calculated with btrfs_map_physical
  swapOffset = 533760;
in
{
  powerManagement = on;

  boot.resumeDevice = "/dev/disk/by-label/baba-root";

  boot.kernelParams = [
    "resume=${config.boot.resumeDevice}"
    "resume_offset=${toString swapOffset}"
  ];

  swapDevices = [{
    device = "/var/swapfile";
    size = 16 * 1024;
  }];

}
