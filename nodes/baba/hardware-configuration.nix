{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; in
{

  imports = [
    # <modules/recipes/nvidia-tb.nix>
    # <modules/recipes/alvr.nix>
    # <modules/hw/framework-intel12.nix>
    # <modules/hw/lenovo-thinkpad-l13-yoga-g3.nix>
    # inputs.nixos-hw.nixosModules.dell-xps-15-9560-nvidia
    ./hibernate.nix
  ];

  boot.initrd.systemd.enable = true;

  boot.initrd.kernelModules = [ "r8169" ];
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.systemd.network = {
    enable = true;
    networks."10-enp42s0" = {
      matchConfig.Name = "enp42s0";
      networkConfig.DHCP = "ipv4";
    };
  };
  boot.initrd.network.ssh.authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
  boot.initrd.network.ssh.hostKeys = [ "/secrets/ssh_initrd_host_ed25519_key" ];

  # OpenCL stuff
  environment.systemPackages = [
    pkgs.clinfo
  ];

  services.hardware.openrgb.enable = true;
  hardware.cpu.intel.updateMicrocode = false;
  hardware.cpu.amd.updateMicrocode = true;

  hardware.graphics = on // {
    # driSupport = true;
    # driSupport32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      amf
      # nvidia-vaapi-driver
      # intel-compute-runtime
      intel-media-driver
      vulkan-loader
      level-zero # oneapi loader
    ];
  };

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.${config._.user}.extraGroups = [ "tss" ];

  nix.settings.system-features = [ "gccarch-znver3" "kvm" "nixos-test"  ];
  zramSwap = on;
  nixpkgs.config.allowUnfree = true;
  powerManagement = on;

  # Boot essentials
  boot.loader.systemd-boot = on;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_writeback_centisecs" = 6000;
    "vm.dirty_expire_centisecs" = 6000;
    "vm.swappiness" = 0;
  };

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
      options = [ "noatime" "ssd" "discard=async" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/baba-boot";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

}
