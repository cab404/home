{ config, lib, pkgs, prelude, inputs, ... }@args:
{

  environment.systemPackages = [
    pkgs.amdgpu_top
  ];

  nixpkgs.config.rocmSupport = true;

  services.lact.enable = true;

  hardware.amdgpu = {

    amdvlk = {
      enable = true;
      support32Bit.enable = true;
      supportExperimental.enable = true;
    };
    opencl.enable = true;
    overdrive.enable = true;
  };



}
