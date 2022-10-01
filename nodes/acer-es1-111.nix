{ config, lib, pkgs, ... }:

{

  boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" "sd_mod" "sdhci_acpi" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/82c37f83-6405-43b3-8c99-afd81e58c18b";
      fsType = "btrfs";
    };

  swapDevices = [ ];

  nix.settings.max-jobs = lib.mkDefault 2;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware.enableRedistributableFirmware = lib.mkDefault true;
}
