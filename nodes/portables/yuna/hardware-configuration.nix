{ inputs, prelude, lib, config, pkgs, ... }: with prelude; let __findFile = prelude.__findFile; in { # %%MODULE_HEADER%%
  imports = [
    <modules/hw/dell-latitude-5400.nix>

  ];

  # From 'not-detected.nix'
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "nvme" "dm-snapshot" "usb_storage" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "mitigations=off" ];

  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  # tailscale
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  boot.initrd.luks.gpgSupport = true;
  boot.initrd.luks.devices = {
    rootfs = {
      gpgCard = {
        gracePeriod = 1; # needs some time to connect
        encryptedPass = ./luks.asc;
        publicKey = ./pubkey.asc;
      };
      device = "/dev/disk/by-label/yuna-root";
      preLVM = true;
      allowDiscards = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/0/yuna-root";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/yuna-boot";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/var/swapfile";
    size = 2 * 1024;
  }];

}
