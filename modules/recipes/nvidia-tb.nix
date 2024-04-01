{ config, lib, pkgs, prelude, inputs, ... }@args:
with prelude; let __findFile = prelude.__findFile; 
  modulePackage = config.boot.kernelPackages.nvidia_x11_vulkan_beta;
in
{
  # This one uses open driver with experimental vulkan support, so there are some parts copied over from nvidia.nix
  boot.blacklistedKernelModules = [ "nouveau" "nvidiafb" ];
  boot.extraModprobeConfig = ''
    softdep nvidia post: nvidia-uvm
  '';

  boot.extraModulePackages = [ 
    modulePackage
  ];
  
  environment.systemPackages = [
    modulePackage
    pkgs.cudatoolkit    
  ];

  hardware.opengl = on // {
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      vulkan-loader
      modulePackage.out
      cudatoolkit
    ];
    extraPackages32 = with pkgs; [
      nvidia-vaapi-driver
      modulePackage.out
    ];
  };
}
