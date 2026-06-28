{ config, lib, pkgs, prelude, inputs, ... }@args:
{

  environment.systemPackages = with pkgs; [
    amdgpu_top
    memtest_vulkan
  ];

  nixpkgs.config.rocmSupport = true;

  services.lact.enable = true;

  hardware.amdgpu = {
    initrd.enable = true;

    # For whatever reason it breaks all vulkan
    # zluda.enable = true;
    opencl.enable = true;

    overdrive.enable = true;
  };

}
