{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile;
  modulePackage = config.boot.kernelPackages.nvidiaPackages.latest;
in
{

  # hardware.nvidia.enabled = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = modulePackage;
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.open = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # This one uses open driver with experimental vulkan support, so there are some parts copied over from nvidia.nix
  # boot.blacklistedKernelModules = [ "nouveau" ];
  # boot.extraModprobeConfig = ''
  #   softdep nvidia post: nvidia-uvm
  # '';

  boot.extraModulePackages = [
    modulePackage
  ];

  environment.systemPackages = [
    modulePackage
    pkgs.cudatoolkit
  ];

  hardware.graphics = on // {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      vulkan-loader
      # modulePackage.out
      cudatoolkit
    ];
    extraPackages32 = with pkgs; [
      nvidia-vaapi-driver
      # modulePackage.out
    ];
  };
}
