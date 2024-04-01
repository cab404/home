{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    # <modules/recipes/nvidia-tb.nix>
    <modules/recipes/alvr.nix>
    # <modules/hw/framework-intel12.nix>
    <modules/hw/lenovo-thinkpad-l13-yoga-g3.nix>
    ./hibernate.nix
    inputs.nixos-boot.nixosModules.default
  ];

  boot.initrd.systemd.enable = true;

  nixos-boot.enable = true;
  # OpenCL stuff
  environment.systemPackages = [ 
    pkgs.clinfo
  ];

  hardware.opengl = on // {
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      intel-compute-runtime
      intel-media-driver
      vulkan-loader
      level-zero # oneapi loader
    ];
  };

  nix.settings.system-features = [ "gccarch-alderlake" "kvm" "nixos-test" ];

  nixpkgs.config.allowUnfree = true;

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

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "nvidia" ];
  
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
