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
      vulkan-loader
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # These two are kinda interweaved
  boot.kernelParams = [ "intel_pstate=no_hwp" ];
  powerManagement = on // {
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.fprintd = on // {
    tod = on // {
      driver = forgiveMeStallman pkgs.libfprint-2-tod1-goodix;
    };
  };

}
