{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    <modules/recipes/watchdog.nix>
  ];

  services.logind.settings.Login.HandlePowerKey = "ignore";
  services.logind.settings.Login.HandlePowerKeyLongPress = "reboot";

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  nixpkgs.config.rocmSupport = true;

  # too old!
  # services.xserver.videoDrivers = [ "amdgpu" ];

  environment.systemPackages = [ pkgs.zfs ];
  boot.initrd.availableKernelModules = [ "zfs" "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [
    "kernel.panic=1"
    "idle=nomwait"
    "amd_pstate=passive"
    "amd_prefcore=enable"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ zfs_2_3 ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/8fd4fb09-57d6-450f-9422-5df1b8d90cc1";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/F9BA-2B68";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" "defaults" ];
    };

  swapDevices = [{
    device = "/var/swapfile";
    size = 8 * 1024;
  }];

}
