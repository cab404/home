{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    inputs.nixos-hw.nixosModules.framework-12th-gen-intel
    ./hibernate.nix
  ];

  # nixpkgs.overlays = [
  #   (self: super: {
  #     iio-sensor-proxy = self.runCommand "iio-sensor-fixed" { sp = super.iio-sensor-proxy; } ''
  #       cp -r $sp $out
  #       chmod -R +rw $out
  #       mkdir $out/share
  #       mv $out/etc/dbus-1 $out/share/dbus-1
  #     '';
      
  #   })
    
  # ];

  systemd.services.iio-sensor-proxy.environment = {
    G_MESSAGES_DEBUG = "all";    
  };

  hardware.sensor.iio.enable = true;

  # Well, otherwise it's unbearable
  services.xserver.libinput.touchpad.tapping = lib.mkForce true;

  # OpenCL stuff
  environment.systemPackages = [ pkgs.clinfo ];
  hardware.opengl = on // {
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver
      vulkan-loader
    ];
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernate=yes
    AllowSuspendThenHibernate=yes
    AllowHybridSleep=yes

    SuspendState=mem
    HibernateState=disk
    HibernateDelaySec=30m
  '';

  powerManagement = on // { cpuFreqGovernor = "schedutil"; };

  # Boot essentials
  boot.loader.systemd-boot = on;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.kernelParams = [
    "mitigations=off"
    # "intel_pstate=no_hwp"
    # "i915.enable_guc=3"
    "i915.enable_fbc=1"
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
