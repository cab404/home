{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
let
  # Calculated with btrfs_map_physical
  swapOffset = 6131420;
in
{
  powerManagement = on;

  boot.resumeDevice = "/dev/disk/by-uuid/2622a677-90ba-4182-9a66-845e72710533";

  boot.kernelParams = [
    "resume=${config.boot.resumeDevice}"
    "resume_offset=${toString swapOffset}"
  ];

  swapDevices = [{
    device = "/var/swapfile";
    size = 17 * 1024;
  }];

}
