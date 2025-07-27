{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    # <modules/recipes/nvidia-tb.nix>
    #     <modules/recipes/alvr.nix>
    # <modules/hw/framework-intel12.nix>
    #     <modules/hw/lenovo-thinkpad-l13-yoga-g3.nix>
    inputs.nixos-hw.nixosModules.dell-xps-15-9560-nvidia
    ./hibernate.nix
  ];

  boot.initrd.systemd.enable = true;

  # OpenCL stuff
  environment.systemPackages = [
    pkgs.clinfo
  ];

  hardware.graphics = on // {
    # driSupport = true;
    # driSupport32Bit = true;
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

  boot.kernelParams = [
    "quiet"
    "splash"

    "mitigations=off"

    "i915.enable_fbc=1"
    "i915.enable_psr=2"
    # "i915.enable_gvt=1"
    "mem_sleep_default=s2idle" # faster faster
  ];
  # TODO: Move to «manual power management» or smth like that
  # systemd.sleep.extraConfig = ''
  #   AllowSuspend=yes
  #   AllowHibernation=yes
  #   AllowSuspendThenHibernate=yes
  #   AllowHybridSleep=yes

  #   SuspendState=mem
  #   HibernateState=disk
  #   HibernateDelaySec=30m
  # '';
  powerManagement = on;
  # powerManagement = on // { cpuFreqGovernor = "schedutil"; };

  # Boot essentials
  boot.loader.systemd-boot = on;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" "nvidia" ];

  boot.initrd.luks.devices = {
    rootfs = {
      device = "/dev/disk/by-label/baba-crypt";
      allowDiscards = true;
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/baba-root";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/baba-boot";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

}
