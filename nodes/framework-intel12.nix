{ config, lib, pkgs, inputs, ... }@args:
with import "${inputs.self}/lib.nix" args;
{

  services.tlp = on;
  services.blueman = on;

  boot.loader.systemd-boot = on;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.opengl = on // {
    driSupport = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      vulkan-loader
    ];
  };

  environment.systemPackages = [ pkgs.clinfo ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_testing;
  # These two are kinda interweaved
  boot.kernelParams = [ "intel_pstate=no_hwp" "enable_guc=3" "enable_gvt=0" ];
  boot.blacklistedKernelModules = [ "hid_sensor_hub" ];

  powerManagement = on // {
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.fprintd = on;

}
