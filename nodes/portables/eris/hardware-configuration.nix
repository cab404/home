{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    inputs.nixos-hw.nixosModules.framework-12th-gen-intel
    ./hibernate.nix
  ];

  # hardware.sensor.iio.enable = true;

  # Well, otherwise it's unbearable
  services.xserver.libinput.touchpad.tapping = lib.mkForce true;

  # OpenCL stuff
  environment.systemPackages = [ pkgs.clinfo ];
  hardware.opengl = on // {
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      nvidia-vaapi-driver
      intel-media-driver
      vulkan-loader
    ];
  };

  nix.settings.system-features = [ "gccarch-alderlake" ];

  # For external GPU
  # services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];
  
  # I am using it with external GPU
  # Video out doesn't work, framerates are worse than integrated
  # But it can run cuda workloads
  # hardware.nvidia.open = true;

  # Superhot
  services.thermald = on // {
    # debug = true;
  };


  nixpkgs.config.allowUnfree = true;

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowSuspendThenHibernate=yes
    AllowHybridSleep=yes

    SuspendState=mem
    HibernateState=disk
    HibernateDelaySec=30m
  '';

  # powerManagement = on // { cpuFreqGovernor = "schedutil"; };

  # Boot essentials
  boot.loader.systemd-boot = on;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  # Should fix FN keys dying in after a suspend
  boot.blacklistedKernelModules = [ "cros_ec_lpcs" ];

  boot.kernelParams = [
    "mitigations=off"
    # "intel_pstate=no_hwp"
    # "i915.enable_guc=3"
    "i915.enable_fbc=1"
    "iwlwifi.amsdu_size=3"
    "enable_psr2_sel_fetch=1"
    "i915.enable_psr=2"
    "i915.fastboot=1"
    "i915.enable_gvt=1"
    "mem_sleep_default=s2idle" # faster faster
  ];

  # services.cpupower-gui = on;

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

}
