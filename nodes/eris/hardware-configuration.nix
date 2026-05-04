{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    # <modules/recipes/nvidia-tb.nix>
    # <modules/recipes/amdgpu-tb.nix>
    # <modules/recipes/watchdog.nix>
    # <modules/recipes/alvr.nix>
    # <modules/hw/framework-intel12.nix>
    <modules/hw/lenovo-thinkpad-l13-yoga-g3.nix>
    ./hibernate.nix
  ];

  boot.initrd.systemd.enable = true;

  # --- Suspend / Hibernate fixes ---

  # Let systemd know which sleep states to use
  systemd.sleep.settings.Sleep = {
    AllowSuspend="yes";
    AllowHibernation="yes";
    AllowSuspendThenHibernate="yes";
    AllowHybridSleep="yes";
    SuspendState="mem";
    HibernateState="disk";
    HibernateMode="shutdown";
  };

  # OpenCL stuff
  environment.systemPackages = [
    pkgs.clinfo
  ];

  hardware.graphics = on // {
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      intel-compute-runtime
      intel-media-driver
      vulkan-loader
      level-zero # oneapi loader
    ];
  };

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.${config._.user}.extraGroups = [ "tss" ];

  nix.settings.system-features = [ "gccarch-alderlake" "kvm" "nixos-test" ];

  nixpkgs.config.allowUnfree = true;

  powerManagement = on;

  # Boot essentials
  boot.loader.systemd-boot = on;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.dirty_expire_centisecs" = 6000;
    "vm.swappiness" = 5;
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # For testing purposes, obvs
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=KR
  '';

  boot.initrd.luks.devices = {
    rootfs = {
      device = "/dev/disk/by-label/eris-enc-root";
      allowDiscards = true;
      bypassWorkqueues = true; # faster LUKS I/O, helps resume from hibernate
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/eris-root";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/eris-boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" "defaults" ];
  };

}
