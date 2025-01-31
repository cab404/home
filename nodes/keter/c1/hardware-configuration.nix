{ config, lib, pkgs, ... }: {

  services.logind.powerKey = "ignore";
  services.logind.powerKeyLongPress = "reboot";

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  # too old!
  # services.xserver.videoDrivers = [ "amdgpu" ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [
    "processor.max_cstate=1"
    # "initcall_blacklist=acpi_cpufreq_init"
    # "amd_pstate=passive"
    # "amd_prefcore=enable"
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/8fd4fb09-57d6-450f-9422-5df1b8d90cc1";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/F9BA-2B68";
      fsType = "vfat";
    };

  # fileSystems."/var/lib/nextcloud" =
  #   {
  #     device = "/dev/disk/by-uuid/f05d3fa0-9b83-4c15-a742-fbe0100c004a";
  #     options = [ "nofail" ];
  #   };

  swapDevices = [ ];

}
