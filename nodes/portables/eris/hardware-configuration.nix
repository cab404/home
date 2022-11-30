{ config, lib, pkgs, inputs, ... }@args:
with import "${inputs.self}/lib.nix" args;
let
  # Calculated with btrfs_map_physical
  swapOffset = 6131420;
in
{

  hardware.sensor.iio.enable = true;

  # Well, otherwise it's unbearable
  services.xserver.libinput.touchpad.tapping = lib.mkForce true;

  # OpenCL stuff
  environment.systemPackages = [ pkgs.clinfo ];
  hardware.opengl = on // {
    driSupport = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      vulkan-loader
    ];
  };

  # Power management tweaks
  services.tlp = {
    enable = true;
    settings = {
      CPU_BOOST_ON_BAT = 0;
      CPU_SCALING_GOVERNOR_ON_BATTERY = "schedutil";
      START_CHARGE_THRESH_BAT0 = 90;
      STOP_CHARGE_THRESH_BAT0 = 97;
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  # magic schedulers!
  powerManagement = on // {
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };

  services.logind = {
    lidSwitch = "suspend-then-hibernate";
    extraConfig = ''
      HandlePowerKey=suspend-then-hibernate
      IdleAction=suspend-then-hibernate
      IdleActionSec=2m
    '';
  };

  systemd.sleep.extraConfig = "HibernateDelaySec=30m";

  # Boot essentials
  #
  boot.loader.systemd-boot = on;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_testing;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.resumeDevice = "/dev/disk/by-uuid/2622a677-90ba-4182-9a66-845e72710533";
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "resume=${config.boot.resumeDevice}"
    "resume_offset=${toString swapOffset}"
    "intel_pstate=no_hwp"
    "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "i915.enable_psr=1"
    "i915.enable_gvt=1"
    "nvme.noacpi=1"
  ];


  boot.initrd.luks.devices = {
    rootfs = {
      device = "/dev/disk/by-label/eris-enc-root";
      allowDiscards = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/eris-root";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/eris-boot";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/var/swapfile";
    size = 17 * 1024;
  }];

}
